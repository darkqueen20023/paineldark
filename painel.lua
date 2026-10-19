-- ============================================
-- PAINEL v27 - COMANDO DE VOZ ADM
-- ============================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G
local ADMIN_PASSWORD = "admin123"

if env.PinkPanelCleanup then pcall(env.PinkPanelCleanup) end
if env.PinkPanelGui then pcall(function() env.PinkPanelGui:Destroy() end) end

local Theme = {
    Bg = Color3.fromRGB(14, 14, 18), TopBar = Color3.fromRGB(24, 24, 30), Row = Color3.fromRGB(28, 28, 35),
    Stroke = Color3.fromRGB(50, 50, 58), Off = Color3.fromRGB(55, 55, 64), Pink = Color3.fromRGB(255, 105, 180),
    Text = Color3.fromRGB(255, 255, 255), TextGray = Color3.fromRGB(165, 165, 175), Green = Color3.fromRGB(80, 200, 120), Red = Color3.fromRGB(220, 60, 60)
}

local function tween(obj, props) TweenService:Create(obj, TweenInfo.new(0.2), props):Play() end
local function new(class, props, parent) local inst = Instance.new(class); for k, v in pairs(props) do inst[k] = v end; if parent then inst.Parent = parent end; return inst end
local function round(p, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, p) end
local function stroke(p, c, t) return new("UIStroke", {Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p) end

task.wait(1)

-- GUI BASE
local ScreenGui = new("ScreenGui", {Name = "PinkPanel", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999999})
local ok = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
env.PinkPanelGui = ScreenGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local pSize = isMobile and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 400, 0, 480)

local FloatBtn = new("TextButton", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), BackgroundColor3 = Theme.Pink, Text = "🌸", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 24, BorderSizePixel = 0, AutoButtonColor = false}, ScreenGui)
round(FloatBtn, 25); stroke(FloatBtn, Theme.Bg, 2)

local MainFrame = new("Frame", {Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false, ClipsDescendants = true}, ScreenGui)
round(MainFrame, 12); stroke(MainFrame, Theme.Pink, 1.5)

local TopBar = new("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, MainFrame)
round(TopBar, 12)
new("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0}, TopBar)
new("TextLabel", {Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "🌸 Painel v27", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, TopBar)

local CloseBtn = new("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -38, 0.5, -14), BackgroundColor3 = Theme.Bg, Text = "✕", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, TopBar)
round(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatBtn.Visible = true end)
FloatBtn.MouseButton1Click:Connect(function() FloatBtn.Visible = false; MainFrame.Visible = true; tween(MainFrame, {Size = pSize}) end)

-- Arrastar
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Notificações
local function notify(text)
    local t = new("TextLabel", {Size = UDim2.new(0, 260, 0, 36), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 50), BackgroundColor3 = Theme.TopBar, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, ZIndex = 999999}, ScreenGui)
    round(t, 10); stroke(t, Theme.Pink, 1.2)
    tween(t, {Position = UDim2.new(0.5, 0, 1, -30)})
    task.delay(2, function() if t.Parent then tween(t, {Position = UDim2.new(0.5, 0, 1, 50)}); task.wait(0.3); t:Destroy() end end)
end

-- Abas
local TabBar = new("Frame", {Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 55), BackgroundTransparency = 1}, MainFrame)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, TabBar)
local Body = new("Frame", {Size = UDim2.new(1, -20, 1, -100), Position = UDim2.new(0, 10, 0, 95), BackgroundTransparency = 1}, MainFrame)
local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do tween(b, {BackgroundColor3 = (n==name) and Theme.Pink or Theme.TopBar, TextColor3 = (n==name) and Theme.Bg or Theme.TextGray}) end
end

local function makePage(name, label, order)
    local b = new("TextButton", {Size = UDim2.new(1/7, -3, 1, 0), BackgroundColor3 = Theme.TopBar, Text = label, TextColor3 = Theme.TextGray, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = order}, TabBar)
    round(b, 6); b.MouseButton1Click:Connect(function() selectTab(name) end); tabButtons[name] = b
    local page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Pink, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Active = true, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable}, Body)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, page)
    pages[name] = page; return page
end

-- Componentes UI
local function makeLabel(parent, text, color, height)
    return new("TextLabel", {Size = UDim2.new(1, -6, 0, height or 22), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, parent)
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = Theme.Row, Text = "  " .. text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutoButtonColor = false, Active = false, Selectable = false}, parent)
    round(btn, 8); stroke(btn, Theme.Stroke)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Bg}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text}) end)
    btn.MouseButton1Click:Connect(callback); return btn
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local row = new("TextButton", {Size = UDim2.new(1, -6, 0, 42), BackgroundColor3 = Theme.Row, Text = "", BorderSizePixel = 0, AutoButtonColor = false, Active = false, Selectable = false}, parent)
    round(row, 8); stroke(row, Theme.Stroke)
    new("TextLabel", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local track = new("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = Theme.Off, BorderSizePixel = 0}, row)
    round(track, 10)
    local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.Text, BorderSizePixel = 0}, track)
    round(knob, 7)
    local function render() tween(track, {BackgroundColor3 = state and Theme.Pink or Theme.Off}); tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}) end
    render(); row.MouseButton1Click:Connect(function() state = not state; render(); callback(state) end)
end

local function makeSearch(parent, placeholder, onChange)
    local box = new("TextBox", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Theme.Row, PlaceholderText = "🔎  " .. placeholder, PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, Active = true}, parent)
    round(box, 8); stroke(box, Theme.Stroke)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, box)
    box:GetPropertyChangedSignal("Text"):Connect(function() onChange(box.Text) end)
    return box
end

-- ============================================
-- FUNÇÕES DE SISTEMA (FARM, STALKER, ETC)
-- ============================================
local currentTarget = nil
local isStalking = false
local isInvisibleServer = false
local alignPos, attachPart

local function stopStalk()
    isStalking = false
    if alignPos then pcall(function() alignPos.Enabled = false; alignPos.MaxForce = 0 end); task.wait(0.05); pcall(function() alignPos:Destroy() end); alignPos = nil end
    if attachPart then pcall(function() attachPart:Destroy() end); attachPart = nil end
end

local function startStalk(target)
    if not target.Character then return end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    attachPart = new("Part", {Size = Vector3.new(1,1,1), Transparency = 1, CanCollide = false, Anchored = true, CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)}, workspace)
    local force = myHRP.AssemblyMass * workspace.Gravity * 10
    alignPos = new("AlignPosition", {Attachment0 = new("Attachment", {Parent = myHRP}), Attachment1 = new("Attachment", {Parent = attachPart}), Mode = Enum.PositionAlignmentMode.OneAttachment, MaxForce = force, Responsiveness = 25}, myHRP)
    isStalking = true
    notify("👣 Grudando em " .. target.Name)
end

local function setInvisible(state)
    isInvisibleServer = state
    task.spawn(function()
        while isInvisibleServer and ScreenGui.Parent do
            if LocalPlayer.Character then
                for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.Transparency = state and 1 or 0; v.CanCollide = not state
                    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = state and 1 or 0 end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- Farm
local isFarming = false
local farmingThread = nil
local candyWaitTime = 0.2

local function getAllCandies()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("candy", 1, true) and (obj:IsA("BasePart") or obj:IsA("Model")) then
            table.insert(list, obj)
        end
    end
    return list
end

local function safeTeleport(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local distance = (targetPos - hrp.Position).Magnitude
    if distance > 50 then
        local direction = (targetPos - hrp.Position).Unit
        for i = 1, 3 do hrp.CFrame = hrp.CFrame + (direction * (distance / 4)); task.wait(0.1) end
    end
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    hrp.AssemblyLinearVelocity = Vector3.zero
end

local function startFarmLoop()
    farmingThread = task.spawn(function()
        while isFarming and ScreenGui.Parent do
            local candies = getAllCandies()
            if #candies > 0 then
                local targetCandy = candies[1]
                if targetCandy and targetCandy.Parent then
                    local pos = targetCandy:IsA("BasePart") and targetCandy.Position or targetCandy:GetPivot().Position
                    safeTeleport(pos)
                    local pickupRemote = nil
                    pcall(function() pickupRemote = ReplicatedStorage.Features.HalloweenCandy.Remotes.Pickup end)
                    if pickupRemote then
                        pcall(function()
                            local id = targetCandy:GetAttribute("CandyId") or targetCandy.Name
                            pickupRemote:InvokeServer(id)
                        end)
                    end
                    task.wait(candyWaitTime)
                end
            else task.wait(1) end
            task.wait(0.1)
        end
    end)
end

-- ============================================
-- ABA 1: JOGADORES
-- ============================================
local pagePlayers = makePage("players", "👥 Players", 1)
local playerFilter = ""
local playerFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, pagePlayers)
new("UIListLayout", {Padding = UDim.new(0, 4)}, playerFrame)

local function rebuildPlayers()
    for _, c in ipairs(playerFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, plr in ipairs(Players:GetChildren()) do
        if plr ~= LocalPlayer then
            local display = plr.DisplayName; local username = plr.Name
            if playerFilter == "" or username:lower():find(playerFilter, 1, true) or display:lower():find(playerFilter, 1, true) then
                local row = makeButton(playerFrame, "➤ " .. display .. " (@" .. username .. ")", function()
                    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); notify("📍 TP: " .. username) end
                end)
                local targetBtn = new("TextButton", {Size = UDim2.new(0, 30, 1, -4), Position = UDim2.new(1, -32, 0, 2), BackgroundColor3 = Theme.Pink, Text = "🎯", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false, Active = false}, row)
                round(targetBtn, 6)
                targetBtn.MouseButton1Click:Connect(function() currentTarget = plr; notify("🎯 Alvo: " .. username); selectTab("stalker") end)
            end
        end
    end
end
makeSearch(pagePlayers, "Buscar @nome...", function(txt) playerFilter = txt:lower(); rebuildPlayers() end)
makeButton(pagePlayers, "🔃 Atualizar Lista", rebuildPlayers)
rebuildPlayers()

-- ============================================
-- ABA 2: STALKER
-- ============================================
local pageStalker = makePage("stalker", "🕵️ Stalker", 2)
makeLabel(pageStalker, "— Alvo Atual —")
makeLabel(pageStalker, "Nenhum alvo", Theme.TextGray, 22)

makeButton(pageStalker, "📍 Teleportar para o Alvo", function()
    if currentTarget and currentTarget.Character then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tHRP = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); notify("📍 TP: " .. currentTarget.Name) end
    else notify("⚠️ Selecione um alvo") end
end)

local btnStalkToggle = makeButton(pageStalker, "👣 Grudar (Stalker)", function()
    if not currentTarget or not currentTarget.Character then return notify("⚠️ Selecione um alvo") end
    if isStalking then stopStalk(); btnStalkToggle.Text = "  👣 Grudar (Stalker)"; notify("⛔ Parou")
    else startStalk(currentTarget); btnStalkToggle.Text = "  ⏹️ Parar de Grudar" end
end)

local btnInvis = makeButton(pageStalker, "👻 Invisibilidade Server-Side", function()
    setInvisible(not isInvisibleServer)
    btnInvis.Text = isInvisibleServer and "  👁️ Ficar Visível" or "  👻 Invisibilidade Server-Side"
end)

-- ============================================
-- ABA 3: UTIL
-- ============================================
local pageUtil = makePage("util", "⚙️ Util", 3)
makeToggle(pageUtil, "🔄 Anti-AFK", false, function(on)
    if on then env.AntiAFK_Conn = LocalPlayer.Idled:Connect(function() pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end)
    else if env.AntiAFK_Conn then env.AntiAFK_Conn:Disconnect(); env.AntiAFK_Conn = nil end end
end)

-- ============================================
-- ABA 4: FARM
-- ============================================
local pageFarm = makePage("farm", "🍬 Farm", 4)
makeToggle(pageFarm, "🍬 Auto-Farm (Pegar de Longe)", false, function(on)
    isFarming = on
    if on then notify("🍬 Farm de Longa Distância Ativado"); startFarmLoop()
    else notify("⛔ Farm Desativado"); if farmingThread then pcall(function() task.cancel(farmingThread) end) end end
end)

-- ============================================
-- ABA 5: INFO
-- ============================================
local pageInfo = makePage("info", "🩺 Info", 5)
makeLabel(pageInfo, "— Servidor —")
local serverInfo = makeLabel(pageInfo, "Carregando...", Theme.TextGray, 60)
serverInfo.TextWrapped = true; serverInfo.TextXAlignment = Enum.TextXAlignment.Left
makeLabel(pageInfo, "— Performance —")
local fpsLabel = makeLabel(pageInfo, "FPS: ...", Theme.Green, 22)
local pingLabel = makeLabel(pageInfo, "Ping: ...", Theme.Green, 22)

task.spawn(function()
    while ScreenGui.Parent do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        if fps > 50 then fpsLabel.TextColor3 = Theme.Green; fpsLabel.Text = "FPS: " .. fps .. " (Ótimo)" 
        elseif fps > 30 then fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 50); fpsLabel.Text = "FPS: " .. fps .. " (Médio)"
        else fpsLabel.TextColor3 = Theme.Red; fpsLabel.Text = "FPS: " .. fps .. " (Ruim)" end
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        if ping < 100 then pingLabel.TextColor3 = Theme.Green; pingLabel.Text = "Ping: " .. ping .. " ms (Bom)"
        elseif ping < 200 then pingLabel.TextColor3 = Color3.fromRGB(255, 200, 50); pingLabel.Text = "Ping: " .. ping .. " ms (Médio)"
        else pingLabel.TextColor3 = Theme.Red; pingLabel.Text = "Ping: " .. ping .. " ms (Ruim)" end
        serverInfo.Text = string.format("Place ID: %s\nJob ID: %s\nJogadores: %d/%d", tostring(game.PlaceId), game.JobId ~= "" and game.JobId:sub(1,8).."..." or "N/A", #Players:GetPlayers(), Players.MaxPlayers)
        task.wait(1)
    end
end)

-- ============================================
-- ABA 6: ADM (LOGIN + EXTRATOR + VOZ)
-- ============================================
local pageAdmin = makePage("admin", "🔐 ADM", 6)
local loginFrame = new("Frame", {Size = UDim2.new(1, -6, 0, 220), BackgroundTransparency = 1}, pageAdmin)
local contentFrame = new("Frame", {Size = UDim2.new(1, -6, 0, 0), BackgroundTransparency = 1, Visible = false}, pageAdmin)
new("UIListLayout", {Padding = UDim.new(0, 6)}, contentFrame)

makeLabel(loginFrame, "Senha: admin123", Theme.Green, 30)
local passBox = new("TextBox", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = Theme.Row, PlaceholderText = "Digite a senha...", PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = true, BorderSizePixel = 0}, loginFrame)
round(passBox, 8); stroke(passBox, Theme.Stroke)

local loginBtn = new("TextButton", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 95), BackgroundColor3 = Theme.Pink, Text = "Entrar", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, loginFrame)
round(loginBtn, 8)

local autoLoginBtn = new("TextButton", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 145), BackgroundColor3 = Theme.Green, Text = "⚡ Entrar Automaticamente", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, loginFrame)
round(autoLoginBtn, 8)

local function doLogin()
    loginFrame.Visible = false; contentFrame.Visible = true
    notify("✅ Login ADM feito!")
end
loginBtn.MouseButton1Click:Connect(function()
    if passBox.Text == ADMIN_PASSWORD then doLogin() else notify("❌ Senha incorreta! Use: admin123") end
end)
autoLoginBtn.MouseButton1Click:Connect(doLogin)

-- ============================================
-- ABA 7: VOZ (ALTERAR NOME)
-- ============================================
local pageVoice = makePage("voice", "🎙️ Voz", 7)
makeLabel(pageVoice, "— Alterar Nome de Voz —", Theme.Green)
makeLabel(pageVoice, "Digite o nome exato que o evento do jogo espera ouvir:", Theme.TextGray, 20)

local voiceBox = new("TextBox", {Size = UDim2.new(1, -6, 0, 40), BackgroundColor3 = Theme.Row, PlaceholderText = "Ex: 'abrir' ou 'candy'", PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = true, BorderSizePixel = 0}, pageVoice)
round(voiceBox, 8); stroke(voiceBox, Theme.Stroke)

makeButton(pageVoice, "▶️ Ativar Escuta de Comando", function()
    if voiceBox.Text ~= "" then
        local comando = voiceBox.Text
        notify("🎙️ Escutando: " .. comando)
        
        -- Tenta usar a API de voz se existir
        local success, err = pcall(function()
            local VoiceChatService = game:GetService("VoiceChatService")
            if VoiceChatService then
                -- Aqui você pode colocar a lógica de Voice Chat do seu jogo
                -- Por enquanto, simulamos que ele "ouve"
                print("[Voz] Pronto para ouvir: " .. comando)
            end
        end)
        
        if not success then
            notify("⚠️ Este jogo não suporta API de Voz (ou não configurado).")
        end
        
        -- Testar comando de voz via chat (simulação)
        local Chat = game:GetService("Chat")
        if Chat then
            pcall(function()
                -- Simula um evento de chat se o jogo tiver
                local RemoteEvent = ReplicatedStorage:FindFirstChild("VoiceEvent")
                if RemoteEvent then
                    RemoteEvent:FireServer(comando)
                end
            end)
        end
    else
        notify("⚠️ Digite uma palavra primeiro.")
    end
end)

makeButton(pageVoice, "🔊 Testar Comando no Jogo", function()
    local Remote = ReplicatedStorage:FindFirstChild("VoiceEvent") or ReplicatedStorage:FindFirstChild("CommandEvent")
    if Remote then
        pcall(function() Remote:FireServer(voiceBox.Text) end)
        notify("✅ Comando '" .. voiceBox.Text .. "' enviado.")
    else
        notify("⚠️ Nenhum evento de voz encontrado. Verifique na aba ADM.")
    end
end)

selectTab("players")
print("[Painel] v27 - Comando de Voz Carregado! 🌸")
