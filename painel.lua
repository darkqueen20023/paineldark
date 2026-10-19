-- ============================================
-- PAINEL MOBILE & PC - v6 (ORGANIZADO)
-- Abas: Utilidades | Jogadores | Auto-Farm | Config
-- ============================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.PinkPanelCleanup then pcall(env.PinkPanelCleanup) end
if env.PinkPanelGui then pcall(function() env.PinkPanelGui:Destroy() end) end

-- ============================================
-- TEMA
-- ============================================
local Theme = {
    Bg = Color3.fromRGB(14, 14, 18),
    TopBar = Color3.fromRGB(24, 24, 30),
    Row = Color3.fromRGB(28, 28, 35),
    Stroke = Color3.fromRGB(50, 50, 58),
    Off = Color3.fromRGB(55, 55, 64),
    Pink = Color3.fromRGB(255, 105, 180),
    Text = Color3.fromRGB(255, 255, 255),
    TextGray = Color3.fromRGB(165, 165, 175),
    Green = Color3.fromRGB(80, 200, 120)
}

local conns = {}
local function connect(signal, fn) local c = signal:Connect(fn); table.insert(conns, c); return c end
local function tween(obj, props, t) TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end
local function new(class, props, parent) local inst = Instance.new(class); for k, v in pairs(props) do inst[k] = v end; if parent then inst.Parent = parent end; return inst end
local function round(parent, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, parent) end
local function stroke(parent, color, thickness) return new("UIStroke", {Color = color, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent) end

task.wait(1)

-- ============================================
-- GUI PRINCIPAL
-- ============================================
local ScreenGui = new("ScreenGui", {Name = "PinkAutomationPanel", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999})
local okParent = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not okParent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
env.PinkPanelGui = ScreenGui

-- BOTÃO FLUTUANTE (Para abrir no celular)
local FloatBtn = new("TextButton", {
    Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25),
    BackgroundColor3 = Theme.Pink, Text = "🌸", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 24,
    BorderSizePixel = 0, AutoButtonColor = false, Active = false, Visible = true, ZIndex = 1000
}, ScreenGui)
round(FloatBtn, 25); stroke(FloatBtn, Theme.Bg, 2)

-- Tamanho adaptável: Menor no mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local pSize = isMobile and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 400, 0, 480)

local MainFrame = new("Frame", {
    Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true, Visible = false
}, ScreenGui)
round(MainFrame, 12); stroke(MainFrame, Theme.Pink, 1.5)

-- Barra Superior
local TopBar = new("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, MainFrame)
round(TopBar, 12)
new("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0}, TopBar)
new("TextLabel", {Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "🌸 Painel Mobile/PC", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, TopBar)

local CloseBtn = new("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -38, 0.5, -14), BackgroundColor3 = Theme.Bg, Text = "✕", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false, Active = false}, TopBar)
round(CloseBtn, 6)
connect(CloseBtn.MouseButton1Click, function() MainFrame.Visible = false; FloatBtn.Visible = true end)

-- Arrastar Suave (Mobile e PC)
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

-- NOTIFICAÇÕES
local function notify(text)
    local t = new("TextLabel", {Size = UDim2.new(0, 280, 0, 38), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 50), BackgroundColor3 = Theme.TopBar, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, ZIndex = 1000}, ScreenGui)
    round(t, 10); stroke(t, Theme.Pink, 1.2)
    tween(t, {Position = UDim2.new(0.5, 0, 1, -30)}, 0.3)
    task.delay(2.5, function() if not t.Parent then return end; tween(t, {Position = UDim2.new(0.5, 0, 1, 50)}, 0.3); task.wait(0.35); t:Destroy() end)
end

-- ABAS
local TabBar = new("Frame", {Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 55), BackgroundTransparency = 1}, MainFrame)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, TabBar)
local Body = new("Frame", {Size = UDim2.new(1, -20, 1, -100), Position = UDim2.new(0, 10, 0, 95), BackgroundTransparency = 1, ClipsDescendants = true}, MainFrame)
local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do
        local active = (n == name)
        tween(b, {BackgroundColor3 = active and Theme.Pink or Theme.TopBar, TextColor3 = active and Theme.Bg or Theme.TextGray})
    end
end

local function makePage(name, label, order)
    local b = new("TextButton", {Size = UDim2.new(1/4, -3, 1, 0), BackgroundColor3 = Theme.TopBar, Text = label, TextColor3 = Theme.TextGray, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, AutoButtonColor = false, Active = false, LayoutOrder = order}, TabBar)
    round(b, 6)
    connect(b.MouseButton1Click, function() selectTab(name) end)
    tabButtons[name] = b
    local page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Pink, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, Body)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    pages[name] = page
    return page
end

-- COMPONENTES UI
local function makeLabel(parent, text, color, height)
    return new("TextLabel", {Size = UDim2.new(1, -6, 0, height or 22), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, parent)
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = Theme.Row, Text = "  " .. text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutoButtonColor = false, Active = false}, parent)
    round(btn, 8); local s = stroke(btn, Theme.Stroke)
    connect(btn.MouseEnter, function() tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Bg}); tween(s, {Color = Theme.Pink}) end)
    connect(btn.MouseLeave, function() tween(btn, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text}); tween(s, {Color = Theme.Stroke}) end)
    connect(btn.MouseButton1Click, callback)
    return btn
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local row = new("TextButton", {Size = UDim2.new(1, -6, 0, 42), BackgroundColor3 = Theme.Row, Text = "", BorderSizePixel = 0, AutoButtonColor = false, Active = false}, parent)
    round(row, 8); stroke(row, Theme.Stroke)
    new("TextLabel", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local track = new("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = Theme.Off, BorderSizePixel = 0}, row)
    round(track, 10)
    local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.Text, BorderSizePixel = 0}, track)
    round(knob, 7)
    local function render() tween(track, {BackgroundColor3 = state and Theme.Pink or Theme.Off}); tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}) end
    render()
    connect(row.MouseButton1Click, function() state = not state; render(); callback(state) end)
end

local function makeSearch(parent, placeholder, onChange)
    local box = new("TextBox", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Theme.Row, PlaceholderText = "🔎  " .. placeholder, PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left}, parent)
    round(box, 8); local s = stroke(box, Theme.Stroke)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, box)
    connect(box.Focused, function() tween(s, {Color = Theme.Pink}) end)
    connect(box.FocusLost, function() tween(s, {Color = Theme.Stroke}) end)
    connect(box:GetPropertyChangedSignal("Text"), function() onChange(box.Text) end)
    return box
end

-- ============================================
-- ABA 1: UTILIDADES
-- ============================================
local pageUtil = makePage("util", "⚙️ Util", 1)
makeLabel(pageUtil, "— Utilidades —")
makeToggle(pageUtil, "🔄 Anti-AFK", false, function(on)
    if on then
        env.AntiAFK_Conn = LocalPlayer.Idled:Connect(function() pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end)
        notify("✅ Anti-AFK ativado")
    else
        if env.AntiAFK_Conn then env.AntiAFK_Conn:Disconnect(); env.AntiAFK_Conn = nil end
        notify("⛔ Anti-AFK desativado")
    end
end)

-- ============================================
-- ABA 2: JOGADORES (TP e Dupla)
-- ============================================
local pagePlayers = makePage("players", "👥 Players", 2)
local playerFilter = ""
local duoTarget = nil
local playerListFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, pagePlayers)
new("UIListLayout", {Padding = UDim.new(0, 4)}, playerListFrame)

local function forceTeleport(hrp, targetPos)
    if not hrp or not targetPos then return end
    for i = 1, 5 do pcall(function() hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0)) end); task.wait(0.02) end
end

local function rebuildPlayers()
    for _, child in ipairs(playerListFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local label = plr.DisplayName .. " (@" .. plr.Name .. ")"
            if playerFilter == "" or label:lower():find(playerFilter, 1, true) then
                local row = makeButton(playerListFrame, "➤ " .. label, function()
                    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and tHRP then forceTeleport(myHRP, tHRP.Position); notify("📍 TP: " .. plr.Name) end
                end)
                local duoBtn = new("TextButton", {Size = UDim2.new(0, 30, 1, -4), Position = UDim2.new(1, -32, 0, 2), BackgroundColor3 = Theme.TopBar, Text = "🤝", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false, Active = false}, row)
                round(duoBtn, 6)
                connect(duoBtn.MouseButton1Click, function() duoTarget = plr; notify("🤝 " .. plr.Name .. " na dupla!") end)
            end
        end
    end
end

makeSearch(pagePlayers, "Buscar jogador...", function(txt) playerFilter = txt:lower(); rebuildPlayers() end)
makeButton(pagePlayers, "🔃 Atualizar Lista", rebuildPlayers)
makeButton(pagePlayers, "🤝 Puxar Dupla para Perto", function()
    if duoTarget and duoTarget.Character then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local duoHRP = duoTarget.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and duoHRP then duoHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3); notify("🤝 Parceiro puxado!") end
    else notify("⚠️ Selecione a dupla primeiro") end
end)
rebuildPlayers()

-- ============================================
-- ABA 3: AUTO-FARM DOCES
-- ============================================
local pageFarm = makePage("farm", "🍬 Farm", 3)
local isFarmingCandy = false

makeToggle(pageFarm, "🍬 Auto-Farmar Doces (Candy)", false, function(on)
    isFarmingCandy = on
    if on then
        notify("🍬 Auto-Farm ATIVADO")
        env.CandyFarmLoop = task.spawn(function()
            while isFarmingCandy and ScreenGui.Parent do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(1) else
                    local candies = {}
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:lower():find("candy", 1, true) and (obj:IsA("BasePart") or obj:IsA("Model")) then table.insert(candies, obj) end
                    end
                    if #candies > 0 then
                        local closestCandy, closestDist = nil, math.huge
                        for _, candy in ipairs(candies) do
                            local pos = candy:IsA("Model") and (candy.PrimaryPart or candy:FindFirstChildWhichIsA("BasePart")).Position or candy.Position
                            if pos then local dist = (pos - hrp.Position).Magnitude; if dist < closestDist then closestDist = dist; closestCandy = pos end end
                        end
                        if closestCandy then forceTeleport(hrp, closestCandy); task.wait(0.1) else task.wait(0.5) end
                    else task.wait(1) end
                end
            end
        end)
    else
        notify("⛔ Auto-Farm DESATIVADO")
        if env.CandyFarmLoop then pcall(function() task.cancel(env.CandyFarmLoop) end); env.CandyFarmLoop = nil end
    end
end)

makeLabel(pageFarm, "— Teleporte Manual p/ Doce —")
local foundCandies = {}
local candyFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, pageFarm)
new("UIListLayout", {Padding = UDim.new(0, 4)}, candyFrame)

makeButton(pageFarm, "🔍 Escanear Doces", function()
    for _, child in ipairs(candyFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    table.clear(foundCandies)
    task.spawn(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("candy", 1, true) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                table.insert(foundCandies, obj)
                makeButton(candyFrame, "📦 " .. obj.Name, function()
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then forceTeleport(hrp, obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")).Position or obj.Position) end
                end)
            end
        end
        notify(("🔍 %d doces encontrados"):format(#foundCandies))
    end)
end)

-- ============================================
-- ABA 4: CONFIGURAÇÕES (Fechar / Abrir)
-- ============================================
local pageConfig = makePage("config", "⚙️ Config", 4)
makeLabel(pageConfig, "— Painel —")
makeButton(pageConfig, "❌ Fechar Painel", function() MainFrame.Visible = false; FloatBtn.Visible = true end)
makeLabel(pageConfig, "— Créditos —", Theme.TextGray, 22)
makeLabel(pageConfig, "Feito para Mobile & PC", Theme.TextGray, 20)
makeLabel(pageConfig, "Sistema v6.0", Theme.TextGray, 20)

-- ============================================
-- LÓGICA DO BOTÃO FLUTUANTE
-- ============================================
connect(FloatBtn.MouseButton1Click, function()
    FloatBtn.Visible = false
    MainFrame.Visible = true
    -- Animação de abrir
    MainFrame.Size = isMobile and UDim2.new(0, 300, 0, 400) or UDim2.new(0, 380, 0, 460)
    tween(MainFrame, {Size = pSize}, 0.3)
end)

selectTab("util")
print("[Painel] v6 Mobile/PC carregado com sucesso! 🌸")
