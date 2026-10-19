-- ============================================
-- PAINEL v25 - FARM OTIMIZADO / SEM LAG
-- ============================================
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local VirtualUser      = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G
local ADMIN_PASSWORD = "admin123"

-- Config do farm
local CANDY_FOLDERS  = {"HalloweenCandiesLocal", "CandysTemplate"}
local CANDY_WAIT     = 0.35   -- espera após pegar cada doce
local RETRY_AFTER    = 8      -- segundos antes de tentar o mesmo doce de novo
local MAX_PER_CYCLE  = 15     -- doces por ciclo antes de re-escanear
local MAP_TP_WAIT    = 1.0

-- Estado (declarado cedo para o cleanup enxergar)
local farmToken, isFarming = 0, false
local isStalking, currentTarget = false, nil
local alignPos, attachPart, att0, stalkConn
local isInvisible, origTransp = false, {}
local stopStalk, setInvisible

-- Limpa versão anterior
if env.PinkPanelCleanup then pcall(env.PinkPanelCleanup) end
if env.PinkPanelGui then pcall(function() env.PinkPanelGui:Destroy() end) end

local locations = {
    Vector3.new(-241.42, 2.44, 669.50), Vector3.new(-420.68, 19.17, 270.95),
    Vector3.new(-171.58, 2.77, -261.09), Vector3.new(-380.24, 5.95, -414.02),
    Vector3.new(347.10, 23.21, -377.64), Vector3.new(609.80, 2.28, 10.63),
    Vector3.new(420.49, 30.71, 196.22), Vector3.new(302.75, 13.96, 575.04),
    Vector3.new(224.29, 4.44, 1034.41), Vector3.new(11.99, 2.40, 834.86),
    Vector3.new(-84.31, 5.34, 687.68), Vector3.new(-114.36, 23.64, 568.91),
    Vector3.new(-21.33, 11.65, 305.46), Vector3.new(101.01, 4.27, 185.55),
    Vector3.new(266.05, 29.58, 246.06), Vector3.new(333.54, 29.13, 401.32),
    Vector3.new(113.40, 26.55, 75.11), Vector3.new(23.84, 13.19, -151.98),
    Vector3.new(-32.49, 53.84, -110.31), Vector3.new(-436.67, 17.89, 113.28),
    Vector3.new(-697.01, 8.01, -29.37), Vector3.new(-596.79, 6.04, -330.12),
    Vector3.new(-690.92, 24.55, 468.41), Vector3.new(-388.16, 5.85, 1023.50),
    Vector3.new(-121.28, 15.16, 1039.57), Vector3.new(88.14, 6.49, 1017.44),
    Vector3.new(100.07, 2.70, 815.04),
}

local Theme = {
    Bg = Color3.fromRGB(14, 14, 18), TopBar = Color3.fromRGB(24, 24, 30), Row = Color3.fromRGB(28, 28, 35),
    Stroke = Color3.fromRGB(50, 50, 58), Off = Color3.fromRGB(55, 55, 64), Pink = Color3.fromRGB(255, 105, 180),
    Text = Color3.fromRGB(255, 255, 255), TextGray = Color3.fromRGB(165, 165, 175),
    Green = Color3.fromRGB(80, 200, 120), Red = Color3.fromRGB(220, 60, 60), Yellow = Color3.fromRGB(255, 200, 50),
}

-- ============================================
-- HELPERS
-- ============================================
local conns = {}
local function connect(sig, fn) local c = sig:Connect(fn); table.insert(conns, c); return c end
local function tween(obj, props) TweenService:Create(obj, TweenInfo.new(0.2), props):Play() end
local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end
local function round(p, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, p) end
local function stroke(p, c, t) return new("UIStroke", {Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p) end
local counters = {}
local function nextOrder(p) counters[p] = (counters[p] or 0) + 1; return counters[p] end
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

task.wait(0.5)

-- ============================================
-- GUI BASE
-- ============================================
local ScreenGui = new("ScreenGui", {Name = "PinkPanel", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999999})
local ok = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
env.PinkPanelGui = ScreenGui

local function cleanup()
    isFarming = false; farmToken += 1
    if stopStalk then pcall(stopStalk) end
    if isInvisible and setInvisible then pcall(setInvisible, false) end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    if env.AntiAFK_Conn then pcall(function() env.AntiAFK_Conn:Disconnect() end); env.AntiAFK_Conn = nil end
    pcall(function() ScreenGui:Destroy() end)
    env.PinkPanelCleanup = nil
end
env.PinkPanelCleanup = cleanup

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local pSize = isMobile and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 400, 0, 480)

local FloatBtn = new("TextButton", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), BackgroundColor3 = Theme.Pink, Text = "🌸", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 24, BorderSizePixel = 0, AutoButtonColor = false}, ScreenGui)
round(FloatBtn, 25); stroke(FloatBtn, Theme.Bg, 2)

local MainFrame = new("Frame", {Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false, ClipsDescendants = true}, ScreenGui)
round(MainFrame, 12); stroke(MainFrame, Theme.Pink, 1.5)

local TopBar = new("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, MainFrame)
round(TopBar, 12)
new("Frame", {Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, TopBar)
new("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0}, MainFrame)
new("TextLabel", {Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "🌸 Painel v25", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, TopBar)

local CloseBtn = new("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -38, 0.5, -14), BackgroundColor3 = Theme.Bg, Text = "✕", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, TopBar)
round(CloseBtn, 6)
connect(CloseBtn.MouseButton1Click, function() MainFrame.Visible = false; FloatBtn.Visible = true end)
connect(FloatBtn.MouseButton1Click, function() FloatBtn.Visible = false; MainFrame.Visible = true end)

-- Arrastar
do
    local dragging, dragStart, startPos
    connect(TopBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Notificações
local function notify(text)
    local t = new("TextLabel", {Size = UDim2.new(0, 260, 0, 36), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 50), BackgroundColor3 = Theme.TopBar, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, ZIndex = 999999}, ScreenGui)
    round(t, 10); stroke(t, Theme.Pink, 1.2)
    tween(t, {Position = UDim2.new(0.5, 0, 1, -30)})
    task.delay(2, function()
        if t.Parent then tween(t, {Position = UDim2.new(0.5, 0, 1, 50)}); task.wait(0.3); t:Destroy() end
    end)
end

-- Abas
local TabBar = new("Frame", {Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 55), BackgroundTransparency = 1}, MainFrame)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, TabBar)
local Body = new("Frame", {Size = UDim2.new(1, -20, 1, -100), Position = UDim2.new(0, 10, 0, 95), BackgroundTransparency = 1, ClipsDescendants = true}, MainFrame)
local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do
        tween(b, {BackgroundColor3 = (n == name) and Theme.Pink or Theme.TopBar, TextColor3 = (n == name) and Theme.Bg or Theme.TextGray})
    end
end

local function makePage(name, emoji, label, order)
    local b = new("TextButton", {Size = UDim2.new(1/6, -4, 1, 0), BackgroundColor3 = Theme.TopBar, Text = isMobile and emoji or (emoji .. " " .. label), TextColor3 = Theme.TextGray, Font = Enum.Font.GothamBold, TextSize = isMobile and 16 or 11, BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = order}, TabBar)
    round(b, 6)
    connect(b.MouseButton1Click, function() selectTab(name) end)
    tabButtons[name] = b
    local page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Pink, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Active = true, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable}, Body)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, page)
    pages[name] = page
    return page
end

-- Componentes
local function makeLabel(parent, text, color, height)
    return new("TextLabel", {Size = UDim2.new(1, -6, 0, height or 22), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, LayoutOrder = nextOrder(parent)}, parent)
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = Theme.Row, Text = "  " .. text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = nextOrder(parent)}, parent)
    round(btn, 8); local s = stroke(btn, Theme.Stroke)
    connect(btn.MouseEnter, function() tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Bg}); tween(s, {Color = Theme.Pink}) end)
    connect(btn.MouseLeave, function() tween(btn, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text}); tween(s, {Color = Theme.Stroke}) end)
    connect(btn.MouseButton1Click, callback)
    return btn
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local row = new("TextButton", {Size = UDim2.new(1, -6, 0, 42), BackgroundColor3 = Theme.Row, Text = "", BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = nextOrder(parent)}, parent)
    round(row, 8); stroke(row, Theme.Stroke)
    new("TextLabel", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local track = new("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = Theme.Off, BorderSizePixel = 0}, row)
    round(track, 10)
    local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.Text, BorderSizePixel = 0}, track)
    round(knob, 7)
    local function render()
        tween(track, {BackgroundColor3 = state and Theme.Pink or Theme.Off})
        tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
    end
    render()
    connect(row.MouseButton1Click, function() state = not state; render(); callback(state) end)
end

local function makeSearch(parent, placeholder, onChange)
    local box = new("TextBox", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Theme.Row, PlaceholderText = "🔎  " .. placeholder, PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(parent)}, parent)
    round(box, 8); stroke(box, Theme.Stroke)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, box)
    connect(box:GetPropertyChangedSignal("Text"), function() onChange(box.Text) end)
    return box
end

-- ============================================
-- STALKER E INVISIBILIDADE
-- ============================================
stopStalk = function()
    isStalking = false
    if stalkConn then stalkConn:Disconnect(); stalkConn = nil end
    if alignPos then pcall(function() alignPos:Destroy() end); alignPos = nil end
    if att0 then pcall(function() att0:Destroy() end); att0 = nil end
    if attachPart then pcall(function() attachPart:Destroy() end); attachPart = nil end
end

local function startStalk(target)
    local myHRP = getHRP()
    local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP or not targetHRP then return end
    stopStalk()
    attachPart = new("Part", {Size = Vector3.new(1, 1, 1), Transparency = 1, CanCollide = false, Anchored = true, CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)}, workspace)
    att0 = new("Attachment", {}, myHRP)
    local att1 = new("Attachment", {}, attachPart)
    alignPos = new("AlignPosition", {Attachment0 = att0, Attachment1 = att1, MaxForce = myHRP.AssemblyMass * workspace.Gravity * 10, Responsiveness = 25}, myHRP)
    isStalking = true
    -- atualiza a posição do alvo (antes ficava parado no ponto inicial)
    stalkConn = RunService.Heartbeat:Connect(function()
        local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if tHRP and attachPart then attachPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) end
    end)
    notify("👣 Grudando em " .. target.Name)
end

setInvisible = function(state)
    isInvisible = state
    if state then
        task.spawn(function()
            while isInvisible and ScreenGui.Parent do
                local char = LocalPlayer.Character
                if char then
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                            if origTransp[v] == nil then origTransp[v] = v.Transparency end
                            v.Transparency = 1
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        for v, t in pairs(origTransp) do
            if v.Parent then pcall(function() v.Transparency = t end) end
        end
        table.clear(origTransp)
    end
end

-- ============================================
-- ABA 1: JOGADORES
-- ============================================
local targetDisplay -- definido na aba Stalker
local pagePlayers = makePage("players", "👥", "Players", 1)
local playerFilter = ""
local playerFrame = new("Frame", {Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 100}, pagePlayers)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, playerFrame)

local function rebuildPlayers()
    for _, c in ipairs(playerFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local display, username = plr.DisplayName, plr.Name
            if playerFilter == "" or username:lower():find(playerFilter, 1, true) or display:lower():find(playerFilter, 1, true) then
                local row = makeButton(playerFrame, "➤ " .. display .. " (@" .. username .. ")", function()
                    local myHRP = getHRP()
                    local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and tHRP then
                        myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
                        notify("📍 TP: " .. username)
                    end
                end)
                local targetBtn = new("TextButton", {Size = UDim2.new(0, 30, 1, -6), Position = UDim2.new(1, -34, 0, 3), BackgroundColor3 = Theme.Pink, Text = "🎯", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, row)
                round(targetBtn, 6)
                targetBtn.MouseButton1Click:Connect(function()
                    currentTarget = plr
                    if targetDisplay then targetDisplay.Text = "🎯 " .. display .. " (@" .. username .. ")" end
                    notify("🎯 Alvo: " .. username)
                    selectTab("stalker")
                end)
            end
        end
    end
end
makeSearch(pagePlayers, "Buscar @nome...", function(txt) playerFilter = txt:lower(); rebuildPlayers() end)
makeButton(pagePlayers, "🔃 Atualizar Lista", rebuildPlayers)
rebuildPlayers()
connect(Players.PlayerAdded, function() task.defer(rebuildPlayers) end)
connect(Players.PlayerRemoving, function() task.defer(rebuildPlayers) end)

-- ============================================
-- ABA 2: STALKER
-- ============================================
local pageStalker = makePage("stalker", "🕵️", "Stalker", 2)
makeLabel(pageStalker, "— Alvo Atual —")
targetDisplay = makeLabel(pageStalker, "Nenhum alvo", Theme.TextGray, 22)

makeButton(pageStalker, "📍 Teleportar para o Alvo", function()
    local myHRP = getHRP()
    local tHRP = currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and tHRP then
        myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
        notify("📍 TP: " .. currentTarget.Name)
    else
        notify("⚠️ Selecione um alvo")
    end
end)

-- (corrigido: o botão precisa ser declarado ANTES para poder se referenciar dentro do callback)
local btnStalkToggle
btnStalkToggle = makeButton(pageStalker, "👣 Grudar (Stalker)", function()
    if isStalking then
        stopStalk()
        btnStalkToggle.Text = "  👣 Grudar (Stalker)"
        notify("⛔ Parou")
    else
        if not currentTarget or not currentTarget.Character then return notify("⚠️ Selecione um alvo") end
        startStalk(currentTarget)
        btnStalkToggle.Text = "  ⏹️ Parar de Grudar"
    end
end)

local btnInvis
btnInvis = makeButton(pageStalker, "👻 Ficar Invisível", function()
    setInvisible(not isInvisible)
    btnInvis.Text = isInvisible and "  👁️ Ficar Visível" or "  👻 Ficar Invisível"
end)

-- ============================================
-- ABA 3: UTIL
-- ============================================
local pageUtil = makePage("util", "⚙️", "Util", 3)
makeToggle(pageUtil, "🔄 Anti-AFK", false, function(on)
    if on then
        env.AntiAFK_Conn = LocalPlayer.Idled:Connect(function()
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
        end)
    elseif env.AntiAFK_Conn then
        env.AntiAFK_Conn:Disconnect(); env.AntiAFK_Conn = nil
    end
end)

-- ============================================
-- ABA 4: FARM (OTIMIZADO)
-- ============================================
local pageFarm = makePage("farm", "🍬", "Farm", 4)
local currentLocationIndex = 1
local tried = setmetatable({}, {__mode = "k"})   -- doce -> última tentativa
local fallbackCache, fallbackTime = {}, 0

-- Pega só os filhos diretos (e subpastas), não GetDescendants:
-- antes cada peça do modelo do doce virava um "doce" e era coletada várias vezes.
local function addCandidates(container, out, depth)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("BasePart") or child:IsA("Model") then
            table.insert(out, child)
        elseif child:IsA("Folder") and depth < 3 then
            addCandidates(child, out, depth + 1)
        end
    end
end

-- Varredura completa do mapa: pesada, então roda no máximo a cada 5s e cede o frame
local function fallbackScan()
    if os.clock() - fallbackTime < 5 then return fallbackCache end
    fallbackTime = os.clock()
    local out = {}
    for i, item in ipairs(workspace:GetDescendants()) do
        if (item:IsA("BasePart") or item:IsA("Model")) and item.Name:lower():find("candy", 1, true) then
            local p = item.Parent
            if not (p and p:IsA("Model") and p.Name:lower():find("candy", 1, true)) then
                table.insert(out, item)
            end
        end
        if i % 3000 == 0 then task.wait() end
    end
    fallbackCache = out
    return out
end

local function getCandies()
    local list = {}
    for _, name in ipairs(CANDY_FOLDERS) do
        local f = workspace:FindFirstChild(name)
        if f then addCandidates(f, list, 0) end
    end
    if #list == 0 then list = fallbackScan() end
    return list
end

local function candyPos(candy)
    if candy:IsA("BasePart") then return candy.Position end
    local ok2, cf = pcall(function() return candy:GetPivot() end)
    return ok2 and cf.Position or nil
end

local function findPickupRemote()
    local ok2, r = pcall(function() return ReplicatedStorage.Features.HalloweenCandy.Remotes.Pickup end)
    return ok2 and r or nil
end

local function collectCandy(candy)
    local hrp = getHRP()
    if not hrp or not candy.Parent then return end
    local pos = candyPos(candy)
    if not pos then return end

    tried[candy] = os.clock()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 0.2, 0))

    -- reforça o toque / prompt, se o executor suportar
    local part = candy:IsA("BasePart") and candy or candy:FindFirstChildWhichIsA("BasePart", true)
    if part then
        if firetouchinterest then
            pcall(function() firetouchinterest(hrp, part, 0); firetouchinterest(hrp, part, 1) end)
        end
        local prompt = candy:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and fireproximityprompt then pcall(fireproximityprompt, prompt) end
        local cd = candy:FindFirstChildWhichIsA("ClickDetector", true)
        if cd and fireclickdetector then pcall(fireclickdetector, cd) end
    end

    -- IMPORTANTE: InvokeServer trava a thread se o servidor não responder.
    -- Rodando em task.spawn o farm nunca fica preso esperando.
    local remote = findPickupRemote()
    if remote then
        local id = candy:GetAttribute("CandyId") or candy.Name
        task.spawn(function()
            pcall(function()
                if remote:IsA("RemoteFunction") then remote:InvokeServer(id)
                elseif remote:IsA("RemoteEvent") then remote:FireServer(id) end
            end)
        end)
    end
    task.wait(CANDY_WAIT)
end

local function startFarm()
    farmToken += 1
    local myToken = farmToken -- só o loop mais recente roda (evita loops duplicados)
    task.spawn(function()
        local function alive() return isFarming and farmToken == myToken and ScreenGui.Parent end
        while alive() do
            local hrp = getHRP()
            if not hrp then
                task.wait(1)
            else
                local now = os.clock()
                local pending = {}
                for _, c in ipairs(getCandies()) do
                    if c.Parent and not (tried[c] and now - tried[c] < RETRY_AFTER) then
                        local p = candyPos(c)
                        if p then table.insert(pending, {c, (p - hrp.Position).Magnitude}) end
                    end
                end
                table.sort(pending, function(a, b) return a[2] < b[2] end) -- mais próximos primeiro

                if #pending > 0 then
                    for i = 1, math.min(#pending, MAX_PER_CYCLE) do
                        if not alive() then break end
                        if pending[i][1].Parent then collectCandy(pending[i][1]) end
                    end
                else
                    local targetPos = locations[currentLocationIndex]
                    if targetPos then
                        hrp.CFrame = CFrame.new(targetPos)
                        currentLocationIndex = (currentLocationIndex % #locations) + 1
                    end
                    task.wait(MAP_TP_WAIT)
                end
            end
            task.wait(0.1)
        end
    end)
end

makeToggle(pageFarm, "🍬 Auto-Farm", false, function(on)
    isFarming = on
    if on then
        notify("🍬 Farm ativado")
        startFarm()
    else
        farmToken += 1
        notify("⛔ Farm desativado")
    end
end)

makeButton(pageFarm, "🎯 Pegar Doce Mais Próximo (Manual)", function()
    local hrp = getHRP()
    if not hrp then return end
    local closest, dist = nil, math.huge
    for _, c in ipairs(getCandies()) do
        local p = c.Parent and candyPos(c)
        if p then
            local d = (p - hrp.Position).Magnitude
            if d < dist then dist = d; closest = c end
        end
    end
    if closest then collectCandy(closest); notify("📦 Doce coletado!") else notify("⚠️ Nenhum doce no mapa") end
end)

-- ============================================
-- ABA 5: INFO (leve: atualiza 1x por segundo)
-- ============================================
local pageInfo = makePage("info", "🩺", "Info", 5)
makeLabel(pageInfo, "— Servidor —")
local serverInfo = makeLabel(pageInfo, "Carregando...", Theme.TextGray, 60)
makeLabel(pageInfo, "— Performance —")
local fpsLabel = makeLabel(pageInfo, "FPS: ...", Theme.Green, 22)
local pingLabel = makeLabel(pageInfo, "Ping: ...", Theme.Green, 22)

local frames, lastT = 0, os.clock()
connect(RunService.Heartbeat, function() frames += 1 end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        local now = os.clock()
        local fps = math.floor(frames / math.max(now - lastT, 0.001) + 0.5)
        frames, lastT = 0, now
        if pages.info.Visible and MainFrame.Visible then
            local col, txt = Theme.Red, "Ruim"
            if fps > 50 then col, txt = Theme.Green, "Ótimo" elseif fps > 30 then col, txt = Theme.Yellow, "Médio" end
            fpsLabel.TextColor3 = col; fpsLabel.Text = ("FPS: %d (%s)"):format(fps, txt)

            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local pcol, ptxt = Theme.Red, "Ruim"
            if ping < 100 then pcol, ptxt = Theme.Green, "Bom" elseif ping < 200 then pcol, ptxt = Theme.Yellow, "Médio" end
            pingLabel.TextColor3 = pcol; pingLabel.Text = ("Ping: %d ms (%s)"):format(ping, ptxt)

            serverInfo.Text = ("Place ID: %s\nJob ID: %s\nJogadores: %d/%d"):format(
                tostring(game.PlaceId), game.JobId ~= "" and game.JobId:sub(1, 8) .. "..." or "N/A", #Players:GetPlayers(), Players.MaxPlayers)
        end
    end
end)

-- ============================================
-- ABA 6: ADM
-- ============================================
local pageAdmin = makePage("admin", "🔐", "ADM", 6)
local loginFrame = new("Frame", {Size = UDim2.new(1, -6, 0, 200), BackgroundTransparency = 1, LayoutOrder = 1}, pageAdmin)
local contentFrame = new("Frame", {Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false, LayoutOrder = 2}, pageAdmin)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, contentFrame)

local passBox = new("TextBox", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Theme.Row, PlaceholderText = "Digite a senha...", PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = true, BorderSizePixel = 0}, loginFrame)
round(passBox, 8); stroke(passBox, Theme.Stroke)
local loginBtn = new("TextButton", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 50), BackgroundColor3 = Theme.Pink, Text = "Entrar", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, loginFrame)
round(loginBtn, 8)
local autoLoginBtn = new("TextButton", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 100), BackgroundColor3 = Theme.Green, Text = "⚡ Entrar Automaticamente", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, loginFrame)
round(autoLoginBtn, 8)

local function doLogin() loginFrame.Visible = false; contentFrame.Visible = true; notify("✅ Login ADM feito!") end
connect(loginBtn.MouseButton1Click, function()
    if passBox.Text == ADMIN_PASSWORD then doLogin() else notify("❌ Senha incorreta!") end
end)
connect(autoLoginBtn.MouseButton1Click, doLogin)

makeButton(contentFrame, "📋 Copiar Place ID", function()
    if setclipboard then setclipboard(tostring(game.PlaceId)); notify("📋 Copiado!") end
end)

selectTab("players")
print("[Painel] v25 - Farm otimizado 🌸")
