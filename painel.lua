-- ============================================
-- PAINEL ROSA E PRETO v3 - ESTÁVEL E LEVE
-- (Sem crash, abas funcionais, busca e teleporte)
-- ============================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

-- Evita duplicar o painel
if env.PinkPanelCleanup then pcall(env.PinkPanelCleanup) end
if env.PinkPanelGui then pcall(function() env.PinkPanelGui:Destroy() end) end

-- ============================================
-- TEMA
-- ============================================
local Theme = {
    Background = Color3.fromRGB(14, 14, 18),
    TopBar     = Color3.fromRGB(24, 24, 30),
    Row        = Color3.fromRGB(28, 28, 35),
    Stroke     = Color3.fromRGB(50, 50, 58),
    Off        = Color3.fromRGB(55, 55, 64),
    Pink       = Color3.fromRGB(255, 105, 180),
    Text       = Color3.fromRGB(255, 255, 255),
    TextGray   = Color3.fromRGB(165, 165, 175),
}

-- ============================================
-- HELPERS
-- ============================================
local conns = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(conns, c)
    return c
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function round(parent, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r)}, parent)
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {Color = color, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
end

-- ============================================
-- CRIAÇÃO DA GUI
-- ============================================
-- Espera 1 segundo para o jogo carregar antes de abrir a tela (evita crash)
task.wait(1)

local ScreenGui = new("ScreenGui", {
    Name = "PinkAutomationPanel",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})
local okParent = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not okParent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
env.PinkPanelGui = ScreenGui

local MainFrame = new("Frame", {
    Size = UDim2.new(0, 400, 0, 480),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, ScreenGui)
round(MainFrame, 12)
stroke(MainFrame, Theme.Pink, 1.5)

-- ============================================
-- TOPBAR
-- ============================================
local TopBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = Theme.TopBar,
    BorderSizePixel = 0,
}, MainFrame)
round(TopBar, 12)

local pinkLine = new("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Theme.Pink,
    BorderSizePixel = 0,
}, TopBar)

new("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "🌸 Painel Dark",
    TextColor3 = Theme.Pink,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

local function topButton(text, xOffset)
    local b = new("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, xOffset, 0.5, -14),
        BackgroundColor3 = Theme.Background,
        Text = text,
        TextColor3 = Theme.Pink,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, TopBar)
    round(b, 6)
    connect(b.MouseEnter, function() tween(b, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Background}) end)
    connect(b.MouseLeave, function() tween(b, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.Pink}) end)
    return b
end

local CloseBtn = topButton("✕", -38)
local MinBtn = topButton("–", -72)

-- Arrastar (Mouse e Touch)
local dragging, dragStart, startPos
connect(TopBar.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ============================================
-- NOTIFICAÇÕES (TOAST)
-- ============================================
local function notify(text)
    local t = new("TextLabel", {
        Size = UDim2.new(0, 280, 0, 38),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 50),
        BackgroundColor3 = Theme.TopBar,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        ZIndex = 100,
    }, ScreenGui)
    round(t, 10)
    stroke(t, Theme.Pink, 1.2)
    tween(t, {Position = UDim2.new(0.5, 0, 1, -30)}, 0.3)
    task.delay(2.5, function()
        if not t.Parent then return end
        tween(t, {Position = UDim2.new(0.5, 0, 1, 50)}, 0.3)
        task.wait(0.35)
        t:Destroy()
    end)
end

-- ============================================
-- ABAS
-- ============================================
local TabBar = new("Frame", {
    Size = UDim2.new(1, -20, 0, 34),
    Position = UDim2.new(0, 10, 0, 55),
    BackgroundTransparency = 1,
}, MainFrame)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, TabBar)

local Body = new("Frame", {
    Size = UDim2.new(1, -20, 1, -100),
    Position = UDim2.new(0, 10, 0, 95),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
}, MainFrame)

local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do
        local active = (n == name)
        tween(b, {BackgroundColor3 = active and Theme.Pink or Theme.TopBar, TextColor3 = active and Theme.Background or Theme.TextGray})
    end
end

local function makePage(name, label, order)
    local b = new("TextButton", {
        Size = UDim2.new(1/3, -4, 1, 0),
        BackgroundColor3 = Theme.TopBar,
        Text = label,
        TextColor3 = Theme.TextGray,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = order,
    }, TabBar)
    round(b, 8)
    connect(b.MouseButton1Click, function() selectTab(name) end)
    tabButtons[name] = b

    local page = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Pink,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, Body)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    pages[name] = page
    return page
end

-- ============================================
-- COMPONENTES
-- ============================================
local function makeLabel(parent, text, color, height)
    return new("TextLabel", {
        Size = UDim2.new(1, -6, 0, height or 22),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Theme.Pink,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {
        Size = UDim2.new(1, -6, 0, 36),
        BackgroundColor3 = Theme.Row,
        Text = "  " .. text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, parent)
    round(btn, 8)
    local s = stroke(btn, Theme.Stroke)
    connect(btn.MouseEnter, function()
        tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Background})
        tween(s, {Color = Theme.Pink})
    end)
    connect(btn.MouseLeave, function()
        tween(btn, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text})
        tween(s, {Color = Theme.Stroke})
    end)
    connect(btn.MouseButton1Click, callback)
    return btn
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local row = new("TextButton", {
        Size = UDim2.new(1, -6, 0, 42),
        BackgroundColor3 = Theme.Row,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, parent)
    round(row, 8)
    stroke(row, Theme.Stroke)
    new("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    
    local track = new("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = Theme.Off,
        BorderSizePixel = 0,
    }, row)
    round(track, 10)
    local knob = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
    }, track)
    round(knob, 7)

    local function render()
        tween(track, {BackgroundColor3 = state and Theme.Pink or Theme.Off})
        tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
    end
    render()
    connect(row.MouseButton1Click, function()
        state = not state
        render()
        callback(state)
    end)
end

local function makeSearch(parent, placeholder, onChange)
    local box = new("TextBox", {
        Size = UDim2.new(1, -6, 0, 34),
        BackgroundColor3 = Theme.Row,
        PlaceholderText = "🔎  " .. placeholder,
        PlaceholderColor3 = Theme.TextGray,
        Text = "",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    round(box, 8)
    local s = stroke(box, Theme.Stroke)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, box)
    connect(box.Focused, function() tween(s, {Color = Theme.Pink}) end)
    connect(box.FocusLost, function() tween(s, {Color = Theme.Stroke}) end)
    connect(box:GetPropertyChangedSignal("Text"), function() onChange(box.Text) end)
    return box
end

-- ============================================
-- ABA 1: UTILIDADES
-- ============================================
local pageUtil = makePage("util", "⚙️ Utilidades", 1)
makeLabel(pageUtil, "— Geral —")
makeToggle(pageUtil, "🔄 Anti-AFK", false, function(on)
    if on then
        env.AntiAFK_Conn = LocalPlayer.Idled:Connect(function()
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
        end)
        notify("✅ Anti-AFK ativado")
    else
        if env.AntiAFK_Conn then env.AntiAFK_Conn:Disconnect() env.AntiAFK_Conn = nil end
        notify("⛔ Anti-AFK desativado")
    end
end)

-- ============================================
-- ABA 2: JOGADORES
-- ============================================
local pagePlayers = makePage("players", "👥 Jogadores", 2)
local playerFilter = ""
local playerListFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, pagePlayers)
new("UIListLayout", {Padding = UDim.new(0, 4)}, playerListFrame)

local function rebuildPlayers()
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local label = plr.DisplayName .. " (@" .. plr.Name .. ")"
            if playerFilter == "" or label:lower():find(playerFilter, 1, true) then
                makeButton(playerListFrame, "➤ " .. label, function()
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and tHRP then
                        hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
                        notify("📍 Teleportado para " .. plr.Name)
                    end
                end)
            end
        end
    end
end

makeSearch(pagePlayers, "Buscar jogador...", function(txt)
    playerFilter = txt:lower()
    rebuildPlayers()
end)
makeButton(pagePlayers, "🔃 Atualizar Lista", rebuildPlayers)
rebuildPlayers()

-- ============================================
-- ABA 3: ITENS
-- ============================================
local pageItems = makePage("items", "📦 Itens", 3)
local foundItems = {}
local itemFilter = ""
local itemListFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, pageItems)
new("UIListLayout", {Padding = UDim.new(0, 4)}, itemListFrame)

local searchTags = {"coin", "item", "drop", "loot", "money", "gem", "chest", "doces", "candy", "moeda", "doce"}
local function isItem(inst)
    local n = inst.Name:lower()
    for _, tag in ipairs(searchTags) do if n:find(tag, 1, true) then return true end end
    return inst:FindFirstChildOfClass("ClickDetector") ~= nil or inst:FindFirstChildOfClass("ProximityPrompt") ~= nil
end

local function getPos(obj)
    local ok, cf = pcall(function() return obj:GetPivot() end)
    return ok and cf.Position or nil
end

local function renderItems()
    for _, child in ipairs(itemListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    local list = {}
    for _, obj in ipairs(foundItems) do
        if obj.Parent then
            local pos = getPos(obj)
            if pos then
                local name = obj.Name
                if itemFilter == "" or name:lower():find(itemFilter, 1, true) then
                    local dist = myHRP and (pos - myHRP.Position).Magnitude or 0
                    table.insert(list, {obj = obj, name = name, dist = dist})
                end
            end
        end
    end
    
    table.sort(list, function(a, b) return a.dist < b.dist end)
    
    for i = 1, math.min(#list, 80) do -- Limite de 80 itens para não lagar
        local entry = list[i]
        makeButton(itemListFrame, ("📦 %s • %dm"):format(entry.name, math.floor(entry.dist)), function()
            if myHRP and entry.obj.Parent then
                myHRP.CFrame = CFrame.new(getPos(entry.obj) + Vector3.new(0, 3, 0))
                notify("📦 Teleportado para " .. entry.name)
            end
        end)
    end
end

local function scanItems()
    notify("⏳ Escaneando o mapa...")
    table.clear(foundItems)
    task.spawn(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and isItem(obj) then
                table.insert(foundItems, obj)
            end
        end
        renderItems()
        notify(("🔍 %d item(ns) encontrado(s)"):format(#foundItems))
    end)
end

makeSearch(pageItems, "Buscar item por nome...", function(txt)
    itemFilter = txt:lower()
    renderItems()
end)
makeButton(pageItems, "🔍 Escanear Itens no Mapa", scanItems)

-- ============================================
-- MINIMIZAR / FECHAR
-- ============================================
local minimized = false
connect(MinBtn.MouseButton1Click, function()
    minimized = not minimized
    TabBar.Visible = not minimized
    Body.Visible = not minimized
    tween(MainFrame, {Size = minimized and UDim2.new(0, 400, 0, 45) or UDim2.new(0, 400, 0, 480)})
    MinBtn.Text = minimized and "+" or "–"
end)
connect(CloseBtn.MouseButton1Click, function()
    ScreenGui:Destroy()
    env.PinkPanelGui = nil
end)

-- Ativa a primeira aba ao abrir
selectTab("util")
print("[Painel] Carregado com sucesso! 🌸")
