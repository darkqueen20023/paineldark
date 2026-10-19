-- ============================================
-- PAINEL ROSA E PRETO v2 - DESIGN PREMIUM
-- Abas • Busca • Toggle • Notificações • Mobile
-- ============================================
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local VirtualUser      = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

-- ============================================
-- CONFIG (edite aqui)
-- ============================================
local Config = {
    ToggleKey  = Enum.KeyCode.RightShift, -- esconde/mostra o painel
    MaxItems   = 80,                      -- máximo de itens exibidos na lista
    SearchTags = {"coin", "item", "drop", "loot", "money", "gem", "chest", "doces", "candy", "moeda", "doce", "pickup", "collect"},
}

-- Evita duplicar (limpa a versão anterior)
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
    PinkDark   = Color3.fromRGB(200, 70, 140),
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
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
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
    return new("UIStroke", {
        Color = color, Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local orderCounters = {}
local function nextOrder(parent)
    orderCounters[parent] = (orderCounters[parent] or 0) + 1
    return orderCounters[parent]
end

-- ============================================
-- GUI BASE
-- ============================================
local ScreenGui = new("ScreenGui", {
    Name = "PinkAutomationPanel",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})
local okParent = pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not okParent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
env.PinkPanelGui = ScreenGui

local afkConn
local function destroyPanel()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    if afkConn then pcall(function() afkConn:Disconnect() end) end
    pcall(function() ScreenGui:Destroy() end)
    env.PinkPanelCleanup = nil
end
env.PinkPanelCleanup = destroyPanel

local FULL_SIZE = UDim2.new(0, 400, 0, 460)
local MINI_SIZE = UDim2.new(0, 400, 0, 46)

local MainFrame = new("Frame", {
    Size = FULL_SIZE,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, ScreenGui)
round(MainFrame, 12)
stroke(MainFrame, Theme.Pink, 1.5)

-- animação de abertura
local uiScale = new("UIScale", {Scale = 0.85}, MainFrame)
TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

-- ============================================
-- TOPBAR
-- ============================================
local TopBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Theme.TopBar,
    BorderSizePixel = 0,
}, MainFrame)
round(TopBar, 12)
new("Frame", { -- tampa os cantos de baixo da topbar
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = Theme.TopBar,
    BorderSizePixel = 0,
}, TopBar)

local pinkLine = new("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 46),
    BackgroundColor3 = Theme.Pink,
    BorderSizePixel = 0,
}, MainFrame)
new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.PinkDark),
        ColorSequenceKeypoint.new(0.5, Theme.Pink),
        ColorSequenceKeypoint.new(1, Theme.PinkDark),
    }),
}, pinkLine)

new("TextLabel", {
    Size = UDim2.new(1, -110, 0, 24),
    Position = UDim2.new(0, 16, 0, 5),
    BackgroundTransparency = 1,
    Text = "🌸 Painel Dark",
    TextColor3 = Theme.Pink,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

new("TextLabel", {
    Size = UDim2.new(1, -110, 0, 14),
    Position = UDim2.new(0, 17, 0, 27),
    BackgroundTransparency = 1,
    Text = "v2.0  •  " .. Config.ToggleKey.Name .. " esconde/mostra",
    TextColor3 = Theme.TextGray,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

local function topButton(text, xOffset, hoverColor)
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
    connect(b.MouseEnter, function() tween(b, {BackgroundColor3 = hoverColor, TextColor3 = Theme.Background}) end)
    connect(b.MouseLeave, function() tween(b, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.Pink}) end)
    return b
end

local CloseBtn = topButton("✕", -38, Theme.Pink)
local MinBtn   = topButton("–", -72, Theme.Pink)

-- Arrastar (mouse + touch)
do
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
end

-- ============================================
-- NOTIFICAÇÕES (toast)
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
    task.delay(2.2, function()
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
    Position = UDim2.new(0, 10, 0, 56),
    BackgroundTransparency = 1,
}, MainFrame)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, TabBar)

local Body = new("Frame", {
    Size = UDim2.new(1, -20, 1, -106),
    Position = UDim2.new(0, 10, 0, 98),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
}, MainFrame)

local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do
        local active = (n == name)
        tween(b, {
            BackgroundColor3 = active and Theme.Pink or Theme.TopBar,
            TextColor3 = active and Theme.Background or Theme.TextGray,
        })
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
    new("UIPadding", {PaddingBottom = UDim.new(0, 6)}, page)
    pages[name] = page
    return page
end

-- ============================================
-- COMPONENTES
-- ============================================
local function makeLabel(parent, text, color, size, height)
    return new("TextLabel", {
        Size = UDim2.new(1, -6, 0, height or 22),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Theme.Pink,
        Font = Enum.Font.GothamBold,
        TextSize = size or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = nextOrder(parent),
    }, parent)
end

local function makeButton(parent, text, callback, opts)
    opts = opts or {}
    local btn = new("TextButton", {
        Size = UDim2.new(1, -6, 0, opts.height or 38),
        BackgroundColor3 = opts.color or Theme.Row,
        Text = "  " .. text,
        TextColor3 = Theme.Text,
        Font = opts.font or Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = opts.order or nextOrder(parent),
    }, parent)
    round(btn, 8)
    local s = stroke(btn, Theme.Stroke)
    local base = opts.color or Theme.Row
    connect(btn.MouseEnter, function()
        tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Background})
        tween(s, {Color = Theme.Pink})
    end)
    connect(btn.MouseLeave, function()
        tween(btn, {BackgroundColor3 = base, TextColor3 = Theme.Text})
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
        LayoutOrder = nextOrder(parent),
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
        LayoutOrder = nextOrder(parent),
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
        afkConn = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
        notify("✅ Anti-AFK ativado")
    else
        if afkConn then afkConn:Disconnect() afkConn = nil end
        notify("⛔ Anti-AFK desativado")
    end
end)

makeLabel(pageUtil, "— Dicas —")
makeLabel(pageUtil, "• Arraste pela barra de cima para mover", Theme.TextGray, 12)
makeLabel(pageUtil, "• Botão – minimiza, ✕ fecha o painel", Theme.TextGray, 12)
makeLabel(pageUtil, "• " .. Config.ToggleKey.Name .. " esconde/mostra rapidamente", Theme.TextGray, 12)

-- ============================================
-- ABA 2: JOGADORES
-- ============================================
local pagePlayers = makePage("players", "👥 Jogadores", 2)

local function tpToPlayer(target)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if hrp and tHRP then
        hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
        notify("📍 Teleportado para " .. target.DisplayName)
    else
        notify("⚠️ Não foi possível teleportar")
    end
end

local playerFilter = ""
local playerRows = {}
local playerStatus

local function rebuildPlayers()
    for _, r in ipairs(playerRows) do r:Destroy() end
    table.clear(playerRows)

    local list = Players:GetPlayers()
    table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)

    local total, shown = 0, 0
    for _, plr in ipairs(list) do
        if plr ~= LocalPlayer then
            total += 1
            local label = plr.DisplayName .. "  (@" .. plr.Name .. ")"
            if playerFilter == "" or label:lower():find(playerFilter, 1, true) then
                shown += 1
                local row = makeButton(pagePlayers, "➤ " .. label, function() tpToPlayer(plr) end, {
                    height = 34, font = Enum.Font.Gotham, order = 1000 + shown,
                })
                table.insert(playerRows, row)
            end
        end
    end
    playerStatus.Text = ("%d jogador(es) • mostrando %d"):format(total, shown)
end

makeSearch(pagePlayers, "Buscar jogador...", function(txt)
    playerFilter = txt:lower()
    rebuildPlayers()
end)
makeButton(pagePlayers, "🔃 Atualizar Lista", rebuildPlayers, {height = 34})
playerStatus = makeLabel(pagePlayers, "", Theme.TextGray, 11, 18)
rebuildPlayers()

-- atualiza sozinho quando alguém entra/sai
connect(Players.PlayerAdded, function() task.defer(rebuildPlayers) end)
connect(Players.PlayerRemoving, function() task.defer(rebuildPlayers) end)

-- ============================================
-- ABA 3: ITENS
-- ============================================
local pageItems = makePage("items", "📦 Itens", 3)

local lowerTags = {}
for _, t in ipairs(Config.SearchTags) do table.insert(lowerTags, t:lower()) end

local function isItem(inst)
    local n = inst.Name:lower()
    for _, tag in ipairs(lowerTags) do
        if n:find(tag, 1, true) then return true end
    end
    return inst:FindFirstChildOfClass("ClickDetector") ~= nil
        or inst:FindFirstChildOfClass("ProximityPrompt") ~= nil
end

local function inPlayerCharacter(inst)
    local p = inst.Parent
    while p do
        if p:IsA("Model") and Players:GetPlayerFromCharacter(p) then return true end
        p = p.Parent
    end
    return false
end

local function getPos(obj)
    local ok, cf = pcall(function() return obj:GetPivot() end)
    return ok and cf.Position or nil
end

local function myPos()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or nil, hrp
end

local foundItems = {}
local itemFilter = ""
local itemRows = {}
local itemStatus
local scanning = false

local function tpToItem(obj)
    local _, hrp = myPos()
    if not hrp then return notify("⚠️ Personagem não encontrado") end
    if not obj.Parent then return notify("⚠️ Esse item não existe mais") end
    local pos = getPos(obj)
    if not pos then return notify("⚠️ Sem posição válida") end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    notify("📦 Teleportado para " .. obj.Name)
end

local function sortedItems()
    local me = myPos()
    local list = {}
    for _, obj in ipairs(foundItems) do
        if obj.Parent then
            local pos = getPos(obj)
            if pos then
                local name = obj.Name
                if itemFilter == "" or name:lower():find(itemFilter, 1, true) then
                    table.insert(list, {obj = obj, name = name, dist = me and (pos - me).Magnitude or 0})
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

local function renderItems()
    for _, r in ipairs(itemRows) do r:Destroy() end
    table.clear(itemRows)

    local list = sortedItems()
    for i = 1, math.min(#list, Config.MaxItems) do
        local entry = list[i]
        local row = makeButton(pageItems, ("📦 %s  •  %dm"):format(entry.name, math.floor(entry.dist)),
            function() tpToItem(entry.obj) end,
            {height = 34, font = Enum.Font.Gotham, order = 1000 + i})
        table.insert(itemRows, row)
    end

    if #list == 0 then
        itemStatus.Text = "Nenhum item encontrado"
    elseif #list > Config.MaxItems then
        itemStatus.Text = ("%d itens • mostrando os %d mais próximos"):format(#list, Config.MaxItems)
    else
        itemStatus.Text = ("%d item(ns) • ordenados por distância"):format(#list)
    end
end

local function scanItems()
    if scanning then return end
    scanning = true
    itemStatus.Text = "⏳ Escaneando o mapa..."
    table.clear(foundItems)

    task.spawn(function()
        local all = workspace:GetDescendants()
        for i, obj in ipairs(all) do
            if not ScreenGui.Parent then return end
            if (obj:IsA("BasePart") or obj:IsA("Model")) and isItem(obj) then
                local parent = obj.Parent
                local parentIsItem = parent and (parent:IsA("Model") or parent:IsA("BasePart")) and isItem(parent)
                if not parentIsItem and not inPlayerCharacter(obj) then
                    table.insert(foundItems, obj)
                end
            end
            if i % 1500 == 0 then task.wait() end -- evita travar o jogo
        end
        scanning = false
        renderItems()
        notify(("🔍 %d item(ns) encontrado(s)"):format(#foundItems))
    end)
end

makeSearch(pageItems, "Filtrar itens por nome...", function(txt)
    itemFilter = txt:lower()
    renderItems()
end)
makeButton(pageItems, "🔍 Escanear Itens no Mapa", scanItems, {height = 36})
makeButton(pageItems, "⚡ Teleportar ao Item Mais Próximo", function()
    local list = sortedItems()
    if #list == 0 then return notify("⚠️ Escaneie primeiro ou ajuste o filtro") end
    tpToItem(list[1].obj)
end, {height = 36})
itemStatus = makeLabel(pageItems, "Clique em escanear para começar", Theme.TextGray, 11, 18)

-- ============================================
-- MINIMIZAR / FECHAR / TECLA
-- ============================================
local minimized = false
connect(MinBtn.MouseButton1Click, function()
    minimized = not minimized
    TabBar.Visible = not minimized
    Body.Visible = not minimized
    pinkLine.Visible = true
    tween(MainFrame, {Size = minimized and MINI_SIZE or FULL_SIZE}, 0.25)
    MinBtn.Text = minimized and "+" or "–"
end)

connect(CloseBtn.MouseButton1Click, destroyPanel)

connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == Config.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- aba inicial
selectTab("util")
print("[Painel] Rosa e Preto v2 carregado com sucesso! 🌸")
