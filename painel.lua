-- ============================================
-- PAINEL DE AUTOMAÇÃO - SCRIPT ÚNICO (LUA/LUAU)
-- ============================================
local Players            = game:GetService("Players")
local CoreGui            = game:GetService("CoreGui")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local VirtualInputManager= game:GetService("VirtualInputManager")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local VirtualUser        = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

-- Evita duplicar
if env.Panel_Loaded and env.PanelGui then
    pcall(function() env.PanelGui:Destroy() end)
end
env.Panel_Loaded = true

-- ============================================
-- GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutomationPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui
env.PanelGui = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 360)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 130, 255)
stroke.Thickness = 1.5
stroke.Parent = MainFrame

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚙️ Painel de Automação"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -33, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
local clsC = Instance.new("UICorner")
clsC.CornerRadius = UDim.new(0, 6)
clsC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    env.Panel_Loaded = false
end)

-- Scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 130, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

-- ============================================
-- UTILITÁRIOS DE UI
-- ============================================
local function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = Scroll
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6); c.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 78)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 58)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(130, 180, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = Scroll
    return l
end

local function makeToggle(text, defaultValue, callback)
    local state = defaultValue or false
    local holder = Instance.new("TextButton")
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    holder.Text = ""
    holder.BorderSizePixel = 0
    holder.AutoButtonColor = false
    holder.Parent = Scroll
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6); c.Parent = holder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 40, 0, 20)
    indicator.Position = UDim2.new(1, -52, 0.5, -10)
    indicator.BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(70, 70, 85)
    indicator.BorderSizePixel = 0
    indicator.Parent = holder
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(1, 0); ic.Parent = indicator

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    knob.BorderSizePixel = 0
    knob.Parent = indicator
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

    local function setState(newState)
        state = newState
        TweenService:Create(indicator, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(70, 70, 85)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then callback(state) end
    end

    holder.MouseButton1Click:Connect(function() setState(not state) end)
    return {setState = setState, getState = function() return state end}
end

-- ============================================
-- ANTI-AFK
-- ============================================
makeLabel("— Utilidades —")
makeButton("🔄 Ativar Anti-AFK", function()
    if env.AntiAFK_Loaded then
        print("[Painel] Anti-AFK já ativo")
        return
    end
    env.AntiAFK_Loaded = true
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
    print("[Painel] Anti-AFK ativado")
end)

-- ============================================
-- TELEPORT PARA PLAYER
-- ============================================
makeLabel("— Teleport para Player —")

local function tpToPlayer(target)
    local char = LocalPlayer.Character
    if not char then return false, "Sem personagem" end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "Sem HRP" end
    local tChar = target.Character
    if not tChar then return false, "Alvo sem personagem" end
    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
    if not tHRP then return false, "Alvo sem HRP" end
    hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
    return true
end

local listHolder = Instance.new("Frame")
listHolder.Size = UDim2.new(1, 0, 0, 0)
listHolder.BackgroundTransparency = 1
listHolder.Parent = Scroll

local ll = Instance.new("UIListLayout")
ll.Padding = UDim.new(0, 4)
ll.SortOrder = Enum.SortOrder.LayoutOrder
ll.Parent = listHolder

local function rebuildPlayerList()
    for _, child in ipairs(listHolder:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            count += 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 30)
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
            b.Text = "  ➤ " .. plr.Name
            b.TextColor3 = Color3.fromRGB(220, 220, 220)
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Parent = listHolder
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 6); c.Parent = b
            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 78)
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
            end)
            b.MouseButton1Click:Connect(function()
                local ok, err = tpToPlayer(plr)
                if not ok then warn("[TP] " .. tostring(err)) end
            end)
        end
    end

    if count == 0 then
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 28)
        l.BackgroundTransparency = 1
        l.Text = "  (nenhum outro player)"
        l.TextColor3 = Color3.fromRGB(150, 150, 150)
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = listHolder
    end

    listHolder.Size = UDim2.new(1, 0, 0, ll.AbsoluteContentSize.Y)
end

makeButton("🔃 Atualizar lista de players", rebuildPlayerList)
Players.PlayerAdded:Connect(rebuildPlayerList)
Players.PlayerRemoving:Connect(function()
    task.wait(0.2)
    rebuildPlayerList()
end)
rebuildPlayerList()

-- ============================================
-- MOEDAS (placeholder - adapte ao jogo)
-- ============================================
makeLabel("— Moedas —")
makeToggle("💰 Auto-Coletar Moedas", false, function(state)
    if state then
        print("[Painel] Auto-coletar ATIVADO")
        -- Adapte aqui: hook de RemoteEvent, loop em workspace.Coins, etc.
        -- Exemplo genérico:
        -- env.CoinThread = task.spawn(function()
        --     while env.Panel_Loaded do
        --         local coins = workspace:FindFirstChild("Coins")
        --         if coins then
        --             for _, coin in ipairs(coins:GetChildren()) do
        --                 pcall(function() coin.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end)
        --             end
        --         end
        --         task.wait(0.5)
        --     end
        -- end)
    else
        print("[Painel] Auto-coletar DESATIVADO")
        if env.CoinThread then
            pcall(function() task.cancel(env.CoinThread) end)
            env.CoinThread = nil
        end
    end
end)

print("[Painel] Carregado com sucesso ✅")
