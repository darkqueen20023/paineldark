-- ============================================
-- PAINEL v31 — Completo
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LogService = game:GetService("LogService")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G
local ADMIN_PASSWORD = "admin123"

if env.PinkPanelCleanup then pcall(env.PinkPanelCleanup) end
if env.PinkPanelGui then pcall(function() env.PinkPanelGui:Destroy() end) end

local Theme = {
    Bg = Color3.fromRGB(30, 26, 46), TopBar = Color3.fromRGB(45, 38, 70),
    Row = Color3.fromRGB(58, 50, 88), Stroke = Color3.fromRGB(120, 100, 200),
    Off = Color3.fromRGB(70, 65, 95), Pink = Color3.fromRGB(255, 120, 200),
    Text = Color3.fromRGB(255, 245, 255), TextGray = Color3.fromRGB(200, 190, 220),
    Green = Color3.fromRGB(120, 230, 150), Red = Color3.fromRGB(255, 90, 110),
    Yellow = Color3.fromRGB(255, 220, 100), Shadow = Color3.fromRGB(10, 8, 20),
}

local conns = {}
local function track(c) conns[#conns + 1] = c; return c end
local function tween(o, p) TweenService:Create(o, TweenInfo.new(0.2), p):Play() end
local function new(c, p, par) local i = Instance.new(c); for k, v in pairs(p) do i[k] = v end; if par then i.Parent = par end; return i end
local function round(p, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, p) end
local function stroke(p, c, t) return new("UIStroke", {Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p) end

task.wait(1)

-- GUI
local ScreenGui = new("ScreenGui", {Name = "PinkPanel", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999999}, LocalPlayer:WaitForChild("PlayerGui"))
env.PinkPanelGui = ScreenGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local pSize = isMobile and UDim2.new(0, 380, 0, 560) or UDim2.new(0, 540, 0, 660)

local shadow = new("Frame", {Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 8, 0.5, 8), BackgroundColor3 = Theme.Shadow, BorderSizePixel = 0, Visible = false, ZIndex = 1}, ScreenGui)
round(shadow, 16)

local FloatBtn = new("TextButton", {Size = UDim2.new(0, 62, 0, 62), Position = UDim2.new(0, 20, 0.5, -31), BackgroundColor3 = Theme.Pink, Text = "🌸", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBlack, TextSize = 28, BorderSizePixel = 0, AutoButtonColor = false}, ScreenGui)
round(FloatBtn, 31); stroke(FloatBtn, Theme.Bg, 3)

local MainFrame = new("Frame", {Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false, ClipsDescendants = true, ZIndex = 2}, ScreenGui)
round(MainFrame, 16); stroke(MainFrame, Theme.Pink, 3)

local TopBar = new("Frame", {Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, MainFrame)
round(TopBar, 16)
new("Frame", {Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -1.5), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0}, TopBar)
new("TextLabel", {Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 18, 0, 0), BackgroundTransparency = 1, Text = "🌸 Painel v31", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBlack, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left}, TopBar)

local CloseBtn = new("TextButton", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -42, 0.5, -16), BackgroundColor3 = Theme.Bg, Text = "✕", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBlack, TextSize = 16, BorderSizePixel = 0, AutoButtonColor = false}, TopBar)
round(CloseBtn, 10); stroke(CloseBtn, Theme.Pink, 2)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; shadow.Visible = false; FloatBtn.Visible = true end)
FloatBtn.MouseButton1Click:Connect(function() FloatBtn.Visible = false; MainFrame.Visible = true; shadow.Visible = true end)

-- Arrastar
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X + 8, startPos.Y.Scale, startPos.Y.Offset + d.Y + 8)
    end
end))

-- Notificações
local function notify(text)
    local t = new("TextLabel", {Size = UDim2.new(0, 300, 0, 42), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 60), BackgroundColor3 = Theme.TopBar, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, TextWrapped = true, ZIndex = 999999}, ScreenGui)
    round(t, 12); stroke(t, Theme.Pink, 2)
    tween(t, {Position = UDim2.new(0.5, 0, 1, -30)})
    task.delay(2, function() if t.Parent then tween(t, {Position = UDim2.new(0.5, 0, 1, 60)}); task.wait(0.3); t:Destroy() end end)
end

local function clip(s)
    local f = setclipboard or toclipboard
    if f then pcall(f, s); notify("📋 Copiado!") else notify("⚠️ Sem setclipboard") end
end

-- Abas
local TabBar = new("ScrollingFrame", {Size = UDim2.new(1, -20, 0, 42), Position = UDim2.new(0, 10, 0, 66), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Pink, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollingDirection = Enum.ScrollingDirection.X}, MainFrame)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, TabBar)
local Body = new("Frame", {Size = UDim2.new(1, -20, 1, -120), Position = UDim2.new(0, 10, 0, 116), BackgroundTransparency = 1}, MainFrame)
local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do tween(b, {BackgroundColor3 = (n == name) and Theme.Pink or Theme.TopBar, TextColor3 = (n == name) and Theme.Bg or Theme.TextGray}) end
end

local function makePage(name, label, order)
    local b = new("TextButton", {Size = UDim2.new(0, 96, 0, 32), BackgroundColor3 = Theme.TopBar, Text = label, TextColor3 = Theme.TextGray, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = order}, TabBar)
    round(b, 10); stroke(b, Theme.Stroke, 2)
    b.MouseButton1Click:Connect(function() selectTab(name) end); tabButtons[name] = b
    local page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Pink, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Active = true}, Body)
    new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, page)
    pages[name] = page; return page
end

local function makeLabel(parent, text, color, height)
    return new("TextLabel", {Size = UDim2.new(1, -6, 0, height or 24), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true}, parent)
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {Size = UDim2.new(1, -6, 0, 44), BackgroundColor3 = Theme.Row, Text = "  " .. text, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutoButtonColor = false}, parent)
    round(btn, 12); stroke(btn, Theme.Stroke, 2)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Bg}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text}) end)
    btn.MouseButton1Click:Connect(callback); return btn
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local row = new("TextButton", {Size = UDim2.new(1, -6, 0, 48), BackgroundColor3 = Theme.Row, Text = "", BorderSizePixel = 0, AutoButtonColor = false}, parent)
    round(row, 12); stroke(row, Theme.Stroke, 2)
    new("TextLabel", {Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local track_ = new("Frame", {Size = UDim2.new(0, 48, 0, 26), Position = UDim2.new(1, -60, 0.5, -13), BackgroundColor3 = Theme.Off, BorderSizePixel = 0}, row)
    round(track_, 13); stroke(track_, Theme.Stroke, 2)
    local knob = new("Frame", {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 4, 0.5, -9), BackgroundColor3 = Theme.Text, BorderSizePixel = 0}, track_)
    round(knob, 9)
    local function render() tween(track_, {BackgroundColor3 = state and Theme.Pink or Theme.Off}); tween(knob, {Position = state and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)}) end
    render(); row.MouseButton1Click:Connect(function() state = not state; render(); callback(state) end)
end

local function makeSearch(parent, placeholder, onChange)
    local box = new("TextBox", {Size = UDim2.new(1, -6, 0, 38), BackgroundColor3 = Theme.Row, PlaceholderText = "🔎  " .. placeholder, PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left}, parent)
    round(box, 12); stroke(box, Theme.Stroke, 2)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, box)
    box:GetPropertyChangedSignal("Text"):Connect(function() onChange(box.Text) end)
    return box
end

local function makeList(parent)
    local f = new("Frame", {Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, parent)
    new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, f)
    return f
end
local function clearList(f) for _, c in ipairs(f:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end end

local function makeRow(parent, text, color, buttons, height)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, height or 58), BackgroundColor3 = Theme.Row, BorderSizePixel = 0}, parent)
    round(row, 10); stroke(row, Theme.Stroke, 2)
    local w = #buttons * 36 + 8
    new("TextLabel", {Size = UDim2.new(1, -w - 8, 1, -6), Position = UDim2.new(0, 10, 0, 3), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd}, row)
    for i, b in ipairs(buttons) do
        local btn = new("TextButton", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -(#buttons - i + 1) * 36, 0.5, -16), BackgroundColor3 = Theme.Pink, Text = b[1], TextColor3 = Theme.Bg, Font = Enum.Font.GothamBlack, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, row)
        round(btn, 8); btn.MouseButton1Click:Connect(b[2])
    end
    return row
end

local function makeTextView(parent, height)
    local tb = new("TextBox", {Size = UDim2.new(1, -6, 0, height), BackgroundColor3 = Theme.Row, Text = "", PlaceholderText = "...", PlaceholderColor3 = Theme.TextGray, TextColor3 = Theme.Text, Font = Enum.Font.Code, TextSize = 12, TextWrapped = true, MultiLine = true, ClearTextOnFocus = false, TextEditable = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, BorderSizePixel = 0}, parent)
    round(tb, 12); stroke(tb, Theme.Stroke, 2)
    new("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 6)}, tb)
    return tb
end

local function makeSubMenu(parent, items)
    local bar = new("Frame", {Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, parent)
    round(bar, 10); stroke(bar, Theme.Stroke, 2)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center}, bar)
    new("UIPadding", {PaddingLeft = UDim.new(0, 4)}, bar)
    local buttons, contents = {}, {}
    local container = new("Frame", {Size = UDim2.new(1, -6, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, parent)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, container)
    for i, it in ipairs(items) do
        local b = new("TextButton", {Size = UDim2.new(1/#items, -4, 1, -8), BackgroundColor3 = (i == 1) and Theme.Pink or Theme.Row, Text = it[1], TextColor3 = (i == 1) and Theme.Bg or Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false}, bar)
        round(b, 8); buttons[it[2]] = b
        local c = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = (i == 1)}, container)
        new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, c)
        contents[it[2]] = c
        b.MouseButton1Click:Connect(function()
            for k, btn in pairs(buttons) do
                btn.BackgroundColor3 = (k == it[2]) and Theme.Pink or Theme.Row
                btn.TextColor3 = (k == it[2]) and Theme.Bg or Theme.Text
                contents[k].Visible = (k == it[2])
            end
        end)
    end
    return contents
end

-- Helpers
local function getHRP() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function getPos(o)
    if o:IsA("BasePart") then return o.Position end
    if o:IsA("Model") then local ok2, p = pcall(function() return o:GetPivot().Position end); if ok2 then return p end end
    local a = o:FindFirstAncestorWhichIsA("BasePart"); if a then return a.Position end
    return nil
end
local function tpTo(o)
    local hrp, pos = getHRP(), getPos(o)
    if hrp and pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)); notify("📍 TP: " .. o.Name)
    else notify("⚠️ Item sem posição") end
end

-- ============================================
-- ABA: PLAYERS
-- ============================================
local pagePlayers = makePage("players", "👥 Players", 1)
local playerFilter = ""
local playerFrame = makeList(pagePlayers)
local currentTarget, targetLabel

local function rebuildPlayers()
    clearList(playerFrame)
    for _, plr in ipairs(Players:GetChildren()) do
        if plr ~= LocalPlayer then
            local display, username = plr.DisplayName, plr.Name
            if playerFilter == "" or username:lower():find(playerFilter, 1, true) or display:lower():find(playerFilter, 1, true) then
                local row = makeButton(playerFrame, "➤ " .. display .. " (@" .. username .. ")", function()
                    local myHRP = getHRP()
                    local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); notify("📍 TP: " .. username) end
                end)
                row.Size = UDim2.new(1, 0, 0, 44)
                local targetBtn = new("TextButton", {Size = UDim2.new(0, 32, 1, -8), Position = UDim2.new(1, -36, 0, 4), BackgroundColor3 = Theme.Pink, Text = "🎯", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBlack, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, row)
                round(targetBtn, 8)
                targetBtn.MouseButton1Click:Connect(function()
                    currentTarget = plr; notify("🎯 Alvo: " .. username)
                    if targetLabel then targetLabel.Text = plr.DisplayName .. " (@" .. username .. ")"; targetLabel.TextColor3 = Theme.Text end
                    selectTab("stalker")
                end)
            end
        end
    end
end
makeSearch(pagePlayers, "Buscar @nome...", function(txt) playerFilter = txt:lower(); rebuildPlayers() end)
makeButton(pagePlayers, "🔃 Atualizar Lista", rebuildPlayers)
rebuildPlayers()
track(Players.PlayerAdded:Connect(rebuildPlayers))
track(Players.PlayerRemoving:Connect(function() task.wait(0.1); rebuildPlayers() end))

-- ============================================
-- ABA: STALKER
-- ============================================
local pageStalker = makePage("stalker", "🕵️ Stalker", 2)
makeLabel(pageStalker, "— Alvo Atual —")
targetLabel = makeLabel(pageStalker, "Nenhum alvo", Theme.TextGray, 24)
makeButton(pageStalker, "📍 Teleportar para o Alvo", function()
    if currentTarget and currentTarget.Character then
        local myHRP = getHRP()
        local tHRP = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); notify("📍 TP: " .. currentTarget.Name) end
    else notify("⚠️ Selecione um alvo") end
end)

-- ============================================
-- ABA: UTIL
-- ============================================
local pageUtil = makePage("util", "⚙️ Util", 3)
makeToggle(pageUtil, "🔄 Anti-AFK", false, function(on)
    if on then
        env.AntiAFK_Conn = LocalPlayer.Idled:Connect(function()
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
        end)
    elseif env.AntiAFK_Conn then
        env.AntiAFK_Conn:Disconnect(); env.AntiAFK_Conn = nil
    end
end)

local flying, flySpeed, flyUp, flyDown = false, 60, false, false
local flyBV, flyBG, flyConn
local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end
local function startFly()
    local hrp = getHRP()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then notify("⚠️ Personagem não encontrado"); return end
    stopFly(); flying = true
    flyBV = new("BodyVelocity", {MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero}, hrp)
    flyBG = new("BodyGyro", {MaxTorque = Vector3.new(1e9, 1e9, 1e9), P = 9e4, CFrame = hrp.CFrame}, hrp)
    hum.PlatformStand = true
    flyConn = RunService.RenderStepped:Connect(function()
        if not (hrp.Parent and hum.Parent) then return stopFly() end
        local cf = workspace.CurrentCamera.CFrame
        local md = hum.MoveDirection
        local dir = Vector3.zero
        if md.Magnitude > 0 then
            local flatLook = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
            if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(cf.UpVector.X, 0, cf.UpVector.Z) end
            local flatRight = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
            local lz, lx = md:Dot(flatLook.Unit), md:Dot(flatRight.Unit)
            dir = cf.RightVector * lx + cf.LookVector * lz
        end
        local v = 0
        if flyUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) then v += 1 end
        if flyDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v -= 1 end
        dir += Vector3.yAxis * v
        flyBV.Velocity = dir * flySpeed
        flyBG.CFrame = cf
    end)
    notify("🕊️ Fly ligado")
end
track(LocalPlayer.CharacterAdded:Connect(function() if flying then task.wait(1); startFly() end end))
makeToggle(pageUtil, "🕊️ Fly (WASD + Espaço/Shift)", false, function(on)
    if on then startFly() else stopFly(); notify("⛔ Fly desligado") end
end)
local speedBox = new("TextBox", {Size = UDim2.new(1, -6, 0, 38), BackgroundColor3 = Theme.Row, PlaceholderText = "Velocidade do Fly (padrão 60)", PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0}, pageUtil)
round(speedBox, 12); stroke(speedBox, Theme.Stroke, 2)
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n then flySpeed = math.clamp(n, 1, 500); notify("🕊️ Velocidade: " .. flySpeed) end
end)

-- ============================================
-- ABA: TP (SALVAR POSIÇÃO)
-- ============================================
local pageTP = makePage("positions", "📍 TP", 4)
makeLabel(pageTP, "— Salvar e voltar —", Theme.Green)
local savedPositions = {}
local posNameBox = new("TextBox", {Size = UDim2.new(1, -6, 0, 40), BackgroundColor3 = Theme.Row, PlaceholderText = "Nome do ponto (ex: base, farm...)", PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, ClearTextOnFocus = false, BorderSizePixel = 0}, pageTP)
round(posNameBox, 10); stroke(posNameBox, Theme.Stroke, 2)
local posList = makeList(pageTP)

local function renderPositions()
    clearList(posList)
    if #savedPositions == 0 then
        local l = new("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Row, Text = "Nenhum ponto salvo ainda", TextColor3 = Theme.TextGray, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0}, posList)
        round(l, 10); stroke(l, Theme.Stroke, 2); return
    end
    for i, p in ipairs(savedPositions) do
        local row = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Theme.Row, BorderSizePixel = 0}, posList)
        round(row, 10); stroke(row, Theme.Stroke, 2)
        local coord = string.format("%.1f, %.1f, %.1f", p.cf.X, p.cf.Y, p.cf.Z)
        new("TextLabel", {Size = UDim2.new(1, -120, 1, -6), Position = UDim2.new(0, 10, 0, 3), BackgroundTransparency = 1, Text = p.name .. "\n" .. coord, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true}, row)
        local tpBtn = new("TextButton", {Size = UDim2.new(0, 32, 1, -10), Position = UDim2.new(1, -80, 0, 5), BackgroundColor3 = Theme.Green, Text = "📍", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBlack, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, row)
        round(tpBtn, 8)
        tpBtn.MouseButton1Click:Connect(function()
            local hrp = getHRP()
            if hrp then hrp.CFrame = p.cf + Vector3.new(0, 3, 0); notify("📍 TP: " .. p.name) end
        end)
        local delBtn = new("TextButton", {Size = UDim2.new(0, 32, 1, -10), Position = UDim2.new(1, -44, 0, 5), BackgroundColor3 = Theme.Red, Text = "✕", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBlack, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false}, row)
        round(delBtn, 8)
        delBtn.MouseButton1Click:Connect(function() table.remove(savedPositions, i); renderPositions() end)
    end
end

makeButton(pageTP, "💾 Salvar posição atual", function()
    local hrp = getHRP(); if not hrp then return notify("⚠️ Personagem não encontrado") end
    local nm = posNameBox.Text ~= "" and posNameBox.Text or ("Ponto " .. (#savedPositions + 1))
    table.insert(savedPositions, {name = nm, cf = hrp.CFrame}); posNameBox.Text = ""
    notify("💾 Salvo: " .. nm); renderPositions()
end)
makeButton(pageTP, "📋 Exportar todos como script", function()
    if #savedPositions == 0 then return notify("⚠️ Nada salvo ainda") end
    local out = {}
    for _, p in ipairs(savedPositions) do
        out[#out + 1] = string.format('["%s"] = CFrame.new(%.2f, %.2f, %.2f);', p.name, p.cf.X, p.cf.Y, p.cf.Z)
    end
    clip("local pontos = {\n  " .. table.concat(out, "\n  ") .. "\n}")
end)
renderPositions()

-- ============================================
-- ABA: FARM (candy)
-- ============================================
local pageFarm = makePage("farm", "🍬 Farm", 5)
local isFarming, farmingThread, candyWaitTime = false, nil, 0.2
local function getAllCandies()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("candy", 1, true) and (obj:IsA("BasePart") or obj:IsA("Model")) then table.insert(list, obj) end
    end
    return list
end
local function safeTP(pos)
    local hrp = getHRP(); if not hrp then return end
    local dist = (pos - hrp.Position).Magnitude
    if dist > 50 then
        local dir = (pos - hrp.Position).Unit
        for i = 1, 3 do hrp.CFrame = hrp.CFrame + dir * (dist / 4); task.wait(0.1) end
    end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    hrp.AssemblyLinearVelocity = Vector3.zero
end
local function startFarmLoop()
    farmingThread = task.spawn(function()
        while isFarming and Screen
