-- ============================================
-- PAINEL v23 - EMERGÊNCIA VISUAL
-- ============================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G
local ADMIN_PASSWORD = "admin123"

-- Limpeza
if env.PinkPanelCleanup then pcall(env.PinkPanelCleanup) end
if env.PinkPanelGui then pcall(function() env.PinkPanelGui:Destroy() end) end

-- Cores
local Theme = {
    Bg = Color3.fromRGB(14, 14, 18), TopBar = Color3.fromRGB(24, 24, 30), Row = Color3.fromRGB(28, 28, 35),
    Stroke = Color3.fromRGB(50, 50, 58), Pink = Color3.fromRGB(255, 105, 180),
    Text = Color3.fromRGB(255, 255, 255), TextGray = Color3.fromRGB(165, 165, 175), Green = Color3.fromRGB(80, 200, 120)
}

-- Funções auxiliares
local function tween(obj, props) TweenService:Create(obj, TweenInfo.new(0.2), props):Play() end
local function new(class, props, parent) local inst = Instance.new(class); for k, v in pairs(props) do inst[k] = v end; if parent then inst.Parent = parent end; return inst end
local function round(p, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, p) end
local function stroke(p, c, t) return new("UIStroke", {Color = c, Thickness = t or 1}, p) end

task.wait(1)

-- ============================================
-- FORÇAR CRIAÇÃO DA GUI (MÉTODO DE EMERGÊNCIA)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PinkPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647 -- Força estar acima de TUDO
ScreenGui.IgnoreGuiInset = true

-- Tenta colocar no CoreGui, se der erro, vai para PlayerGui
local sucesso = pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or CoreGui
end)
if not sucesso or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
env.PinkPanelGui = ScreenGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local pSize = isMobile and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 400, 0, 480)

-- BOTÃO FLUTUANTE (Se não aparecer, o script falhou)
local FloatBtn = new("TextButton", {
    Size = UDim2.new(0, 50, 0, 50), 
    Position = UDim2.new(0, 20, 0.5, -25), 
    BackgroundColor3 = Theme.Pink, 
    Text = "🌸", TextColor3 = Theme.Bg, 
    Font = Enum.Font.GothamBold, TextSize = 24, 
    BorderSizePixel = 0, AutoButtonColor = false,
    ZIndex = 2147483647
}, ScreenGui)
round(FloatBtn, 25); stroke(FloatBtn, Theme.Bg, 2)

-- JANELA PRINCIPAL
local MainFrame = new("Frame", {
    Size = pSize, 
    AnchorPoint = Vector2.new(0.5, 0.5), 
    Position = UDim2.new(0.5, 0, 0.5, 0), 
    BackgroundColor3 = Theme.Bg, 
    BorderSizePixel = 0, 
    Visible = false, 
    ClipsDescendants = true,
    ZIndex = 2147483646
}, ScreenGui)
round(MainFrame, 12); stroke(MainFrame, Theme.Pink, 1.5)

local TopBar = new("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, MainFrame)
round(TopBar, 12)
new("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0}, TopBar)
new("TextLabel", {Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "🌸 Painel v23", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, TopBar)

local CloseBtn = new("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -38, 0.5, -14), BackgroundColor3 = Theme.Bg, Text = "✕", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, TopBar)
round(CloseBtn, 6)

-- Lógica de Abrir/Fechar
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

-- ============================================
-- SISTEMA DE ABAS E COMPONENTES
-- ============================================
local TabBar = new("Frame", {Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 55), BackgroundTransparency = 1}, MainFrame)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, TabBar)
local Body = new("Frame", {Size = UDim2.new(1, -20, 1, -100), Position = UDim2.new(0, 10, 0, 95), BackgroundTransparency = 1}, MainFrame)
local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do tween(b, {BackgroundColor3 = (n==name) and Theme.Pink or Theme.TopBar, TextColor3 = (n==name) and Theme.Bg or Theme.TextGray}) end
end

local function makePage(name, label, order)
    local b = new("TextButton", {Size = UDim2.new(1/5, -3, 1, 0), BackgroundColor3 = Theme.TopBar, Text = label, TextColor3 = Theme.TextGray, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = order}, TabBar)
    round(b, 6); b.MouseButton1Click:Connect(function() selectTab(name) end); tabButtons[name] = b
    local page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Pink, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, Body)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, page)
    pages[name] = page; return page
end

local function makeLabel(parent, text, color, height)
    return new("TextLabel", {Size = UDim2.new(1, -6, 0, height or 22), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, parent)
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = Theme.Row, Text = "  " .. text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutoButtonColor = false}, parent)
    round(btn, 8); stroke(btn, Theme.Stroke)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Bg}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text}) end)
    btn.MouseButton1Click:Connect(callback); return btn
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local row = new("TextButton", {Size = UDim2.new(1, -6, 0, 42), BackgroundColor3 = Theme.Row, Text = "", BorderSizePixel = 0, AutoButtonColor = false}, parent)
    round(row, 8); stroke(row, Theme.Stroke)
    new("TextLabel", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local track = new("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, row)
    round(track, 10)
    local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.Text, BorderSizePixel = 0}, track)
    round(knob, 7)
    local function render() tween(track, {BackgroundColor3 = state and Theme.Pink or Theme.TopBar}); tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}) end
    render(); row.MouseButton1Click:Connect(function() state = not state; render(); callback(state) end)
end

-- ============================================
-- ABA 1: JOGADORES (Lógica simplificada para garantir que abra)
-- ============================================
local pagePlayers = makePage("players", "👥 Players", 1)
makeLabel(pagePlayers, "— Lista de Jogadores —")
local playerFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, pagePlayers)
new("UIListLayout", {Padding = UDim.new(0, 4)}, playerFrame)

local function rebuildPlayers()
    for _, c in ipairs(playerFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, plr in ipairs(Players:GetChildren()) do
        if plr ~= LocalPlayer then
            makeButton(playerFrame, "➤ " .. plr.Name, function()
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) end
            end)
        end
    end
end
makeButton(pagePlayers, "🔃 Atualizar Lista", rebuildPlayers)
rebuildPlayers()

-- ============================================
-- ABA 2: FARM E OUTRAS FUNÇÕES (Exemplo básico)
-- ============================================
local pageFarm = makePage("farm", "🍬 Farm", 2)
makeLabel(pageFarm, "— Farm de Doces —")
makeToggle(pageFarm, "Ativar Auto-Farm (Lógica do Carlão)", false, function(on)
    if on then print("Farm Ligado") else print("Farm Desligado") end
end)

-- ============================================
-- ABA 3: ADM
-- ============================================
local pageAdmin = makePage("admin", "🔐 ADM", 3)
makeLabel(pageAdmin, "Senha: admin123")
local passBox = new("TextBox", {Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = Theme.Row, PlaceholderText = "Senha...", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, BorderSizePixel = 0}, pageAdmin)
round(passBox, 8)
makeButton(pageAdmin, "Entrar", function()
    if passBox.Text == ADMIN_PASSWORD then print("Logado") end
end)

selectTab("players")
print("[Painel] v23 - EMERGÊNCIA CARREGADA! Se você vê isso, o script funcionou.")
