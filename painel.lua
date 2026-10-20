-- ============================================
-- PAINEL v29 - Fly / Explorer / Spy / Código / Diagnóstico / Log / Lucky Block
-- ============================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LogService = game:GetService("LogService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G
local ADMIN_PASSWORD = "admin123"

if env.PinkPanelCleanup then pcall(env.PinkPanelCleanup) end
if env.PinkPanelGui then pcall(function() env.PinkPanelGui:Destroy() end) end

local Theme = {
    Bg = Color3.fromRGB(14, 14, 18), TopBar = Color3.fromRGB(24, 24, 30), Row = Color3.fromRGB(28, 28, 35),
    Stroke = Color3.fromRGB(50, 50, 58), Off = Color3.fromRGB(55, 55, 64), Pink = Color3.fromRGB(255, 105, 180),
    Text = Color3.fromRGB(255, 255, 255), TextGray = Color3.fromRGB(165, 165, 175), Green = Color3.fromRGB(80, 200, 120),
    Red = Color3.fromRGB(220, 60, 60), Yellow = Color3.fromRGB(255, 200, 50)
}

local conns = {}
local function track(c) conns[#conns + 1] = c; return c end

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
local pSize = isMobile and UDim2.new(0, 330, 0, 440) or UDim2.new(0, 420, 0, 500)

local FloatBtn = new("TextButton", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), BackgroundColor3 = Theme.Pink, Text = "🌸", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 24, BorderSizePixel = 0, AutoButtonColor = false}, ScreenGui)
round(FloatBtn, 25); stroke(FloatBtn, Theme.Bg, 2)

local MainFrame = new("Frame", {Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false, ClipsDescendants = true}, ScreenGui)
round(MainFrame, 12); stroke(MainFrame, Theme.Pink, 1.5)

local TopBar = new("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, MainFrame)
round(TopBar, 12)
new("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0}, TopBar)
new("TextLabel", {Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "🌸 Painel v29", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, TopBar)

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
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end))

-- Notificações
local function notify(text)
    local t = new("TextLabel", {Size = UDim2.new(0, 260, 0, 36), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 50), BackgroundColor3 = Theme.TopBar, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 12, TextWrapped = true, ZIndex = 999999}, ScreenGui)
    round(t, 10); stroke(t, Theme.Pink, 1.2)
    tween(t, {Position = UDim2.new(0.5, 0, 1, -30)})
    task.delay(2, function() if t.Parent then tween(t, {Position = UDim2.new(0.5, 0, 1, 50)}); task.wait(0.3); t:Destroy() end end)
end

local function clip(s)
    local f = setclipboard or toclipboard
    if f then pcall(f, s); notify("📋 Copiado!") else notify("⚠️ Executor sem setclipboard") end
end

-- Abas (barra com rolagem horizontal)
local TabBar = new("ScrollingFrame", {Size = UDim2.new(1, -20, 0, 36), Position = UDim2.new(0, 10, 0, 55), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Pink, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollingDirection = Enum.ScrollingDirection.X}, MainFrame)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, TabBar)
local Body = new("Frame", {Size = UDim2.new(1, -20, 1, -105), Position = UDim2.new(0, 10, 0, 98), BackgroundTransparency = 1}, MainFrame)
local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do tween(b, {BackgroundColor3 = (n == name) and Theme.Pink or Theme.TopBar, TextColor3 = (n == name) and Theme.Bg or Theme.TextGray}) end
end

local function makePage(name, label, order)
    local b = new("TextButton", {Size = UDim2.new(0, 88, 0, 28), BackgroundColor3 = Theme.TopBar, Text = label, TextColor3 = Theme.TextGray, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = order}, TabBar)
    round(b, 6); b.MouseButton1Click:Connect(function() selectTab(name) end); tabButtons[name] = b
    local page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Pink, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Active = true, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable}, Body)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, page)
    pages[name] = page; return page
end

-- Componentes UI
local function makeLabel(parent, text, color, height)
    return new("TextLabel", {Size = UDim2.new(1, -6, 0, height or 22), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true}, parent)
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
    local track_ = new("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = Theme.Off, BorderSizePixel = 0}, row)
    round(track_, 10)
    local knob = new("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.Text, BorderSizePixel = 0}, track_)
    round(knob, 7)
    local function render() tween(track_, {BackgroundColor3 = state and Theme.Pink or Theme.Off}); tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}) end
    render(); row.MouseButton1Click:Connect(function() state = not state; render(); callback(state) end)
end

local function makeSearch(parent, placeholder, onChange)
    local box = new("TextBox", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Theme.Row, PlaceholderText = "🔎  " .. placeholder, PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, Active = true}, parent)
    round(box, 8); stroke(box, Theme.Stroke)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10)}, box)
    box:GetPropertyChangedSignal("Text"):Connect(function() onChange(box.Text) end)
    return box
end

-- Lista dinâmica (cresce sozinha)
local function makeList(parent)
    local f = new("Frame", {Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, parent)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, f)
    return f
end
local function clearList(f) for _, c in ipairs(f:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end end

-- Linha com texto + botões pequenos: buttons = {{"📍", fn}, {"📋", fn}}
local function makeRow(parent, text, color, buttons, height)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, height or 58), BackgroundColor3 = Theme.Row, BorderSizePixel = 0}, parent)
    round(row, 8); stroke(row, Theme.Stroke)
    local w = #buttons * 34 + 8
    new("TextLabel", {Size = UDim2.new(1, -w - 8, 1, -6), Position = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Text, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd}, row)
    for i, b in ipairs(buttons) do
        local btn = new("TextButton", {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -(#buttons - i + 1) * 34, 0.5, -15), BackgroundColor3 = Theme.Pink, Text = b[1], TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0, AutoButtonColor = false}, row)
        round(btn, 6); btn.MouseButton1Click:Connect(b[2])
    end
    return row
end

local function makeTextView(parent, height)
    local tb = new("TextBox", {Size = UDim2.new(1, -6, 0, height), BackgroundColor3 = Theme.Row, Text = "", PlaceholderText = "...", PlaceholderColor3 = Theme.TextGray, TextColor3 = Theme.Text, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, MultiLine = true, ClearTextOnFocus = false, TextEditable = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, BorderSizePixel = 0}, parent)
    round(tb, 8); stroke(tb, Theme.Stroke)
    new("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 6)}, tb)
    return tb
end

-- ============================================
-- HELPERS GERAIS (posição, IDs, TP, info)
-- ============================================
local function getHRP() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end

local function getPos(o)
    if o:IsA("BasePart") then return o.Position end
    if o:IsA("Model") then local ok2, p = pcall(function() return o:GetPivot().Position end); if ok2 then return p end end
    local a = o:FindFirstAncestorWhichIsA("BasePart")
    if a then return a.Position end
    local m = o:FindFirstAncestorWhichIsA("Model")
    if m then local ok2, p = pcall(function() return m:GetPivot().Position end); if ok2 then return p end end
    return nil
end

local function tpTo(o)
    local hrp, pos = getHRP(), getPos(o)
    if hrp and pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)); notify("📍 TP: " .. o.Name)
    else notify("⚠️ Esse item não tem posição") end
end

local idProps = {"MeshId", "TextureID", "TextureId", "AnimationId", "SoundId", "Texture", "ColorMap", "NormalMap", "ShirtTemplate", "PantsTemplate", "Image"}
local function getIds(o)
    local out = {}
    for _, p in ipairs(idProps) do
        local ok2, v = pcall(function() return o[p] end)
        if ok2 and type(v) == "string" and v ~= "" then out[#out + 1] = p .. "=" .. v end
    end
    return table.concat(out, " | ")
end

local function fullInfo(o)
    local L = {}
    L[#L + 1] = "Nome: " .. o.Name
    L[#L + 1] = "Classe: " .. o.ClassName
    L[#L + 1] = "Caminho: " .. o:GetFullName()
    local okd, dbg = pcall(function() return o:GetDebugId() end)
    if okd then L[#L + 1] = "DebugId: " .. tostring(dbg) end
    local pos = getPos(o)
    if pos then L[#L + 1] = string.format("Posição: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z) end
    if o:IsA("BasePart") then
        L[#L + 1] = string.format("Tamanho: %.1f, %.1f, %.1f | Anchored: %s | CanCollide: %s", o.Size.X, o.Size.Y, o.Size.Z, tostring(o.Anchored), tostring(o.CanCollide))
        L[#L + 1] = "Material: " .. tostring(o.Material)
    end
    local ids = getIds(o)
    if ids ~= "" then L[#L + 1] = "IDs: " .. ids end
    for k, v in pairs(o:GetAttributes()) do L[#L + 1] = "Atributo " .. k .. " = " .. tostring(v) end
    local animator = o:IsA("Animator") and o or (o:IsA("Humanoid") and o:FindFirstChildOfClass("Animator"))
    if animator then
        for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
            L[#L + 1] = "Animação tocando: " .. t.Name .. " -> " .. t.Animation.AnimationId
        end
    end
    L[#L + 1] = "Filhos: " .. #o:GetChildren()
    return table.concat(L, "\n")
end

-- ============================================
-- FUNÇÕES DE SISTEMA (FARM, STALKER, FLY)
-- ============================================
local currentTarget, targetLabel
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
    local myHRP = getHRP()
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

-- FLY
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
    stopFly()
    flying = true
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
        if flyDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v -= 1 end
        dir += Vector3.yAxis * v
        flyBV.Velocity = dir * flySpeed
        flyBG.CFrame = cf
    end)
    notify("🕊️ Fly ligado")
end

track(LocalPlayer.CharacterAdded:Connect(function()
    if flying then task.wait(1); startFly() end
end))

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
    local hrp = getHRP()
    if not hrp then return end
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
local playerFrame = makeList(pagePlayers)

local function rebuildPlayers()
    clearList(playerFrame)
    for _, plr in ipairs(Players:GetChildren()) do
        if plr ~= LocalPlayer then
            local display = plr.DisplayName; local username = plr.Name
            if playerFilter == "" or username:lower():find(playerFilter, 1, true) or display:lower():find(playerFilter, 1, true) then
                local row = makeButton(playerFrame, "➤ " .. display .. " (@" .. username .. ")", function()
                    local myHRP = getHRP()
                    local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); notify("📍 TP: " .. username) end
                end)
                row.Size = UDim2.new(1, 0, 0, 36)
                local targetBtn = new("TextButton", {Size = UDim2.new(0, 30, 1, -4), Position = UDim2.new(1, -32, 0, 2), BackgroundColor3 = Theme.Pink, Text = "🎯", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false, Active = false}, row)
                round(targetBtn, 6)
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
-- ABA 2: STALKER
-- ============================================
local pageStalker = makePage("stalker", "🕵️ Stalker", 2)
makeLabel(pageStalker, "— Alvo Atual —")
targetLabel = makeLabel(pageStalker, "Nenhum alvo", Theme.TextGray, 22)

makeButton(pageStalker, "📍 Teleportar para o Alvo", function()
    if currentTarget and currentTarget.Character then
        local myHRP = getHRP()
        local tHRP = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3); notify("📍 TP: " .. currentTarget.Name) end
    else notify("⚠️ Selecione um alvo") end
end)

local btnStalkToggle
btnStalkToggle = makeButton(pageStalker, "👣 Grudar (Stalker)", function()
    if not currentTarget or not currentTarget.Character then return notify("⚠️ Selecione um alvo") end
    if isStalking then stopStalk(); btnStalkToggle.Text = "  👣 Grudar (Stalker)"; notify("⛔ Parou")
    else startStalk(currentTarget); btnStalkToggle.Text = "  ⏹️ Parar de Grudar" end
end)

local btnInvis
btnInvis = makeButton(pageStalker, "👻 Invisibilidade Server-Side", function()
    setInvisible(not isInvisibleServer)
    btnInvis.Text = isInvisibleServer and "  👁️ Ficar Visível" or "  👻 Invisibilidade Server-Side"
end)

-- ============================================
-- ABA 3: UTIL (Anti-AFK + FLY)
-- ============================================
local pageUtil = makePage("util", "⚙️ Util", 3)
makeToggle(pageUtil, "🔄 Anti-AFK", false, function(on)
    if on then env.AntiAFK_Conn = LocalPlayer.Idled:Connect(function() pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end)
    else if env.AntiAFK_Conn then env.AntiAFK_Conn:Disconnect(); env.AntiAFK_Conn = nil end end
end)

makeLabel(pageUtil, "— Fly —")
makeToggle(pageUtil, "🕊️ Fly (WASD/analógico + Espaço/Shift)", false, function(on)
    if on then startFly() else stopFly(); notify("⛔ Fly desligado") end
end)
local speedBox = new("TextBox", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Theme.Row, PlaceholderText = "Velocidade do Fly (padrão 60)", PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0}, pageUtil)
round(speedBox, 8); stroke(speedBox, Theme.Stroke)
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n then flySpeed = math.clamp(n, 1, 500); notify("🕊️ Velocidade: " .. flySpeed) end
end)

local holdRow = new("Frame", {Size = UDim2.new(1, -6, 0, 38), BackgroundTransparency = 1}, pageUtil)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6)}, holdRow)
local function makeHold(text, setter)
    local b = new("TextButton", {Size = UDim2.new(0.5, -3, 1, 0), BackgroundColor3 = Theme.Row, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false}, holdRow)
    round(b, 8); stroke(b, Theme.Stroke)
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then setter(true) end end)
    b.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then setter(false) end end)
end
makeHold("⬆️ Subir (segurar)", function(v) flyUp = v end)
makeHold("⬇️ Descer (segurar)", function(v) flyDown = v end)

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
makeLabel(pageInfo, "— Performance —")
local fpsLabel = makeLabel(pageInfo, "FPS: ...", Theme.Green, 22)
local pingLabel = makeLabel(pageInfo, "Ping: ...", Theme.Green, 22)

task.spawn(function()
    while ScreenGui.Parent do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        if fps > 50 then fpsLabel.TextColor3 = Theme.Green; fpsLabel.Text = "FPS: " .. fps .. " (Ótimo)"
        elseif fps > 30 then fpsLabel.TextColor3 = Theme.Yellow; fpsLabel.Text = "FPS: " .. fps .. " (Médio)"
        else fpsLabel.TextColor3 = Theme.Red; fpsLabel.Text = "FPS: " .. fps .. " (Ruim)" end
        local okp, ping = pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        if okp then
            if ping < 100 then pingLabel.TextColor3 = Theme.Green; pingLabel.Text = "Ping: " .. ping .. " ms (Bom)"
            elseif ping < 200 then pingLabel.TextColor3 = Theme.Yellow; pingLabel.Text = "Ping: " .. ping .. " ms (Médio)"
            else pingLabel.TextColor3 = Theme.Red; pingLabel.Text = "Ping: " .. ping .. " ms (Ruim)" end
        end
        serverInfo.Text = string.format("Place ID: %s\nJob ID: %s\nJogadores: %d/%d", tostring(game.PlaceId), game.JobId ~= "" and game.JobId:sub(1,8).."..." or "N/A", #Players:GetPlayers(), Players.MaxPlayers)
        task.wait(1)
    end
end)

-- ============================================
-- ABA 6: ADM
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
local function doLogin() loginFrame.Visible = false; contentFrame.Visible = true; notify("✅ Login ADM feito!") end
loginBtn.MouseButton1Click:Connect(function()
    if passBox.Text == ADMIN_PASSWORD then doLogin() else notify("❌ Senha incorreta! Use: admin123") end
end)
autoLoginBtn.MouseButton1Click:Connect(doLogin)

-- ============================================
-- ABA 7: VOZ
-- ============================================
local pageVoice = makePage("voice", "🎙️ Voz", 7)
makeLabel(pageVoice, "— Alterar Nome de Voz —", Theme.Green)
makeLabel(pageVoice, "Digite o nome exato que o evento do jogo espera ouvir:", Theme.TextGray, 30)
local voiceBox = new("TextBox", {Size = UDim2.new(1, -6, 0, 40), BackgroundColor3 = Theme.Row, PlaceholderText = "Ex: 'abrir' ou 'candy'", PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = true, BorderSizePixel = 0}, pageVoice)
round(voiceBox, 8); stroke(voiceBox, Theme.Stroke)

makeButton(pageVoice, "▶️ Ativar Escuta de Comando", function()
    if voiceBox.Text ~= "" then
        local comando = voiceBox.Text
        notify("🎙️ Escutando: " .. comando)
        local success = pcall(function() local v = game:GetService("VoiceChatService"); print("[Voz] Pronto para ouvir: " .. comando) end)
        if not success then notify("⚠️ Este jogo não suporta API de Voz.") end
        pcall(function()
            local RemoteEvent = ReplicatedStorage:FindFirstChild("VoiceEvent")
            if RemoteEvent then RemoteEvent:FireServer(comando) end
        end)
    else notify("⚠️ Digite uma palavra primeiro.") end
end)

makeButton(pageVoice, "🔊 Testar Comando no Jogo", function()
    local Remote = ReplicatedStorage:FindFirstChild("VoiceEvent") or ReplicatedStorage:FindFirstChild("CommandEvent")
    if Remote then
        pcall(function() Remote:FireServer(voiceBox.Text) end)
        notify("✅ Comando '" .. voiceBox.Text .. "' enviado.")
    else notify("⚠️ Nenhum evento de voz encontrado.") end
end)

-- ============================================
-- ABA 8: ITENS (EXPLORER: nomes, classes, IDs, TP)
-- ============================================
local pageEx = makePage("explorer", "🗺️ Itens", 8)
local exNames = {"Workspace", "ReplicatedStorage", "Lighting", "PlayerGui", "Jogo todo"}
local exRoots = {workspace, ReplicatedStorage, Lighting, LocalPlayer:WaitForChild("PlayerGui"), game}
local exSrc, exFilter, exEntries = 1, "", {}
local exCount, exDetail, exList

local function addExRow(o)
    local ids = getIds(o)
    local text = string.format("[%s] %s\n%s%s", o.ClassName, o.Name, o:GetFullName(), ids ~= "" and ("\n" .. ids) or "")
    makeRow(exList, text, Theme.Text, {
        {"📍", function() tpTo(o) end},
        {"ℹ️", function() exDetail.Text = fullInfo(o) end},
        {"📋", function() clip(fullInfo(o)) end},
    }, 64)
end

local function renderEx()
    clearList(exList)
    local shown, matched = 0, 0
    for _, o in ipairs(exEntries) do
        if exFilter == "" or o.Name:lower():find(exFilter, 1, true) or o.ClassName:lower():find(exFilter, 1, true) then
            matched += 1
            if shown < 100 then shown += 1; addExRow(o) end
        end
    end
    exCount.Text = matched .. " encontrados (mostrando " .. shown .. ") de " .. #exEntries
end

local function scanEx()
    local ok2, list = pcall(function() return exRoots[exSrc]:GetDescendants() end)
    exEntries = ok2 and list or {}
    renderEx()
end

makeLabel(pageEx, "— Explorer do Mapa —")
local srcBtn
srcBtn = makeButton(pageEx, "📂 Fonte: Workspace (toque p/ trocar)", function()
    exSrc = exSrc % #exRoots + 1
    srcBtn.Text = "  📂 Fonte: " .. exNames[exSrc] .. " (toque p/ trocar)"
    scanEx()
end)
makeSearch(pageEx, "Nome, classe (meshpart, sound, animation...)", function(t) exFilter = t:lower(); renderEx() end)
makeButton(pageEx, "🔄 Escanear de novo", scanEx)
makeButton(pageEx, "💾 Exportar tudo p/ arquivo (writefile)", function()
    if not writefile then return notify("⚠️ Executor sem writefile") end
    local out = {}
    for i, o in ipairs(exEntries) do
        out[#out + 1] = o.ClassName .. "\t" .. o:GetFullName() .. "\t" .. getIds(o)
        if i % 3000 == 0 then task.wait() end
    end
    pcall(writefile, "mapa_export.txt", table.concat(out, "\n"))
    notify("💾 Salvo: mapa_export.txt (" .. #out .. " itens)")
end)
exCount = makeLabel(pageEx, "Toque em Escanear", Theme.TextGray, 20)
makeLabel(pageEx, "— Detalhes (toque em ℹ️) —", Theme.Green)
exDetail = makeTextView(pageEx, 130)
makeLabel(pageEx, "— Resultados (📍 TP | ℹ️ detalhes | 📋 copiar) —", Theme.Green)
exList = makeList(pageEx)
task.spawn(scanEx)

-- ============================================
-- ABA 9: SPY (eventos/remotes do cliente)
-- ============================================
local pageSpy = makePage("spy", "📡 Spy", 9)
local spyOut, spyIn = false, false
local spyEntries, spyIncomingConns = {}, {}
local spyList

local function ser(v, d)
    d = d or 0
    local t = typeof(v)
    if t == "string" then return string.format("%q", #v > 80 and v:sub(1, 80) .. "..." or v)
    elseif t == "Instance" then return "<" .. v.ClassName .. ":" .. v:GetFullName() .. ">"
    elseif t == "table" then
        if d >= 2 then return "{...}" end
        local p, n = {}, 0
        for k, val in pairs(v) do
            n += 1
            if n > 10 then p[#p + 1] = "..."; break end
            p[#p + 1] = "[" .. ser(k, d + 1) .. "]=" .. ser(val, d + 1)
        end
        return "{" .. table.concat(p, ", ") .. "}"
    end
    return tostring(v)
end

local function addSpy(dir, remote, args)
    local parts = {}
    for i = 1, args.n do parts[i] = ser(args[i]) end
    local joined = table.concat(parts, ", ")
    local path = remote:GetFullName()
    local text = os.date("%H:%M:%S") .. " " .. dir .. " " .. path .. "(" .. joined .. ")"
    spyEntries[#spyEntries + 1] = text
    local snippet = string.format("%s:%s(%s)", path, remote.ClassName == "RemoteFunction" and "InvokeServer" or "FireServer", joined)
    makeRow(spyList, text, dir == "→" and Theme.Pink or Theme.Green, {{"📋", function() clip(dir == "→" and snippet or text) end}}, 50)
    local kids = spyList:GetChildren()
    if #kids > 121 then for _, c in ipairs(kids) do if c:IsA("Frame") then c:Destroy(); break end end end
end

local hookInstalled = false
local function installHook()
    if hookInstalled then return true end
    if not (hookmetamethod and getnamecallmethod) then notify("⚠️ Executor sem hookmetamethod"); return false end
    local cc = checkcaller or function() return false end
    local wrap = newcclosure or function(f) return f end
    local okh = pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
            local m = getnamecallmethod()
            if spyOut and (m == "FireServer" or m == "InvokeServer") and typeof(self) == "Instance" and (self.ClassName == "RemoteEvent" or self.ClassName == "RemoteFunction") and not cc() then
                task.defer(addSpy, "→", self, table.pack(...))
            end
            return old(self, ...)
        end))
    end)
    hookInstalled = okh
    if not okh then notify("❌ Falha ao instalar o hook") end
    return okh
end

local function connectIncoming(r)
    if r:IsA("RemoteEvent") then
        spyIncomingConns[#spyIncomingConns + 1] = r.OnClientEvent:Connect(function(...) addSpy("←", r, table.pack(...)) end)
    end
end
local incomingAdded
local function setIncoming(on)
    spyIn = on
    for _, c in ipairs(spyIncomingConns) do c:Disconnect() end
    spyIncomingConns = {}
    if incomingAdded then incomingAdded:Disconnect(); incomingAdded = nil end
    if on then
        for _, o in ipairs(game:GetDescendants()) do pcall(connectIncoming, o) end
        incomingAdded = game.DescendantAdded:Connect(function(o) pcall(connectIncoming, o) end)
    end
end

makeLabel(pageSpy, "— Remote Spy —")
makeToggle(pageSpy, "📤 Capturar o que o CLIENTE envia (→)", false, function(on)
    if on and not installHook() then return end
    spyOut = on
end)
makeToggle(pageSpy, "📥 Capturar o que o SERVIDOR envia (←)", false, setIncoming)
makeButton(pageSpy, "🧹 Limpar log", function() clearList(spyList); spyEntries = {} end)
makeButton(pageSpy, "📋 Copiar log inteiro", function() clip(table.concat(spyEntries, "\n")) end)

makeLabel(pageSpy, "— Todos os Remotes/Bindables do jogo —", Theme.Green)
local remList = makeList(pageSpy)
makeButton(pageSpy, "🔎 Listar Remotes", function()
    clearList(remList)
    local n = 0
    for _, o in ipairs(game:GetDescendants()) do
        if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") or o:IsA("BindableEvent") or o:IsA("BindableFunction") then
            n += 1
            if n <= 150 then
                local path = o:GetFullName()
                makeRow(remList, "[" .. o.ClassName .. "] " .. o.Name .. "\n" .. path, Theme.Text, {{"📋", function() clip(path) end}}, 44)
            end
        end
    end
    notify("🔎 " .. n .. " remotes/bindables")
end)
makeLabel(pageSpy, "— Log em tempo real —", Theme.Green)
spyList = makeList(pageSpy)

-- ============================================
-- ABA 10: CÓDIGO (scripts do cliente)
-- ============================================
local pageCode = makePage("code", "💻 Código", 10)
local codeFilter, codeSource = "", ""
local codeList, codeView

local function readScript(s)
    if not decompile then return notify("⚠️ Executor sem decompile") end
    local ok2, res = pcall(decompile, s)
    if ok2 and type(res) == "string" then
        codeSource = res
        codeView.Text = #res > 12000 and (res:sub(1, 12000) .. "\n-- [cortado: use 📋 p/ copiar tudo] --") or res
        notify("📖 " .. s.Name .. " (" .. #res .. " chars)")
    else notify("❌ Falha ao decompilar") end
end

local function listScripts()
    clearList(codeList)
    local src = {}
    if getscripts then pcall(function() src = getscripts() end) end
    if getloadedmodules then pcall(function() for _, m in ipairs(getloadedmodules()) do src[#src + 1] = m end end) end
    if #src == 0 then
        for _, o in ipairs(game:GetDescendants()) do if o:IsA("LocalScript") or o:IsA("ModuleScript") then src[#src + 1] = o end end
    end
    local shown = 0
    for _, s in ipairs(src) do
        local okn, path = pcall(function() return s:GetFullName() end)
        if okn and (codeFilter == "" or path:lower():find(codeFilter, 1, true)) and shown < 120 then
            shown += 1
            makeRow(codeList, "[" .. s.ClassName .. "] " .. s.Name .. "\n" .. path, Theme.Text, {
                {"📖", function() readScript(s) end},
                {"📋", function() readScript(s); clip(codeSource) end},
            }, 46)
        end
    end
    notify("📜 " .. shown .. " scripts de " .. #src)
end

makeLabel(pageCode, "— Leitor de Código do Cliente —")
makeLabel(pageCode, "Precisa de decompile no executor. Scripts de servidor não aparecem.", Theme.TextGray, 30)
makeSearch(pageCode, "Filtrar scripts por nome/caminho", function(t) codeFilter = t:lower() end)
makeButton(pageCode, "📜 Listar scripts (LocalScript/Module)", listScripts)
makeLabel(pageCode, "— Código —", Theme.Green)
codeView = makeTextView(pageCode, 240)
makeButton(pageCode, "📋 Copiar código aberto", function() if codeSource ~= "" then clip(codeSource) else notify("⚠️ Abra um script primeiro") end end)
codeList = makeList(pageCode)

-- ============================================
-- ABA 11: MAPA (diagnóstico de bugs/falhas)
-- ============================================
local pageDiag = makePage("diag", "📊 Mapa", 11)
makeLabel(pageDiag, "— Informações Gerais —")
local mapInfo = makeLabel(pageDiag, "Toque em Analisar", Theme.TextGray, 170)
mapInfo.TextYAlignment = Enum.TextYAlignment.Top
makeLabel(pageDiag, "— Problemas encontrados (📍 TP | 📋 caminho) —", Theme.Green)
local diagList = makeList(pageDiag)

local function runDiag()
    clearList(diagList)
    notify("🔬 Analisando mapa...")
    task.spawn(function()
        local c = {Parts = 0, MeshParts = 0, Models = 0, Unanchored = 0, Scripts = 0, Remotes = 0, Sounds = 0, Animations = 0, Lights = 0, Particles = 0, Total = 0}
        local problems, pc = {}, {}
        local function addProb(cat, o)
            pc[cat] = (pc[cat] or 0) + 1
            if pc[cat] <= 25 then problems[#problems + 1] = {cat, o} end
        end
        local fall = workspace.FallenPartsDestroyHeight
        local n = 0
        for _, o in ipairs(workspace:GetDescendants()) do
            n += 1; if n % 1500 == 0 then task.wait() end
            c.Total += 1
            if o:IsA("BasePart") then
                c.Parts += 1
                if not o.Anchored then c.Unanchored += 1 end
                local p = o.Position
                if p.X ~= p.X or p.Y ~= p.Y or p.Z ~= p.Z then addProb("Posição NaN", o)
                elseif p.Y < fall + 100 then addProb("Perto/abaixo do void", o) end
                if o.Size.Magnitude < 0.01 then addProb("Tamanho zero", o) end
                if o:IsA("MeshPart") then c.MeshParts += 1; if o.MeshId == "" then addProb("MeshPart sem MeshId", o) end end
            elseif o:IsA("Model") then c.Models += 1
            elseif o:IsA("LuaSourceContainer") then c.Scripts += 1
            elseif o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then c.Remotes += 1
            elseif o:IsA("Sound") then c.Sounds += 1; if o.SoundId == "" then addProb("Sound sem SoundId", o) end
            elseif o:IsA("Animation") then c.Animations += 1; if o.AnimationId == "" then addProb("Animation sem ID", o) end
            elseif o:IsA("Light") then c.Lights += 1
            elseif o:IsA("ParticleEmitter") then c.Particles += 1 end
        end
        local okn, pname = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
        local sums = {}
        for cat, num in pairs(pc) do sums[#sums + 1] = cat .. ": " .. num end
        mapInfo.Text = string.format(
            "Jogo: %s\nPlaceId: %s | Jogadores: %d/%d\nStreaming: %s | Gravidade: %.1f | Void: %d\nInstâncias: %d | Parts: %d (MeshParts %d) | Soltas: %d\nModels: %d | Scripts: %d | Remotes: %d\nSounds: %d | Animações: %d | Luzes: %d | Partículas: %d\nProblemas: %s",
            okn and pname or "?", tostring(game.PlaceId), #Players:GetPlayers(), Players.MaxPlayers,
            tostring(workspace.StreamingEnabled), workspace.Gravity, fall,
            c.Total, c.Parts, c.MeshParts, c.Unanchored, c.Models, c.Scripts, c.Remotes, c.Sounds, c.Animations, c.Lights, c.Particles,
            #sums > 0 and table.concat(sums, " | ") or "nenhum")
        mapInfo.TextColor3 = Theme.Text
        for _, pr in ipairs(problems) do
            local o = pr[2]
            makeRow(diagList, "⚠️ " .. pr[1] .. "\n" .. o.Name .. " — " .. o:GetFullName(), Theme.Yellow, {
                {"📍", function() tpTo(o) end},
                {"📋", function() clip(o:GetFullName()) end},
            }, 48)
        end
        notify("✅ Análise concluída")
    end)
end
makeButton(pageDiag, "🔬 Analisar Mapa Agora", runDiag)

-- ============================================
-- ABA 12: LOG (erros/avisos do cliente)
-- ============================================
local pageLog = makePage("log", "🐞 Log", 12)
local logFilter = "all"
local logEntries = {}
local logList

local function logColor(t)
    if t == Enum.MessageType.MessageError then return Theme.Red
    elseif t == Enum.MessageType.MessageWarning then return Theme.Yellow
    elseif t == Enum.MessageType.MessageInfo then return Theme.TextGray end
    return Theme.Text
end
local function logPass(t)
    return logFilter == "all" or (logFilter == "error" and t == Enum.MessageType.MessageError) or (logFilter == "warn" and t == Enum.MessageType.MessageWarning)
end
local function addLogRow(e)
    local lbl = new("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Row, BorderSizePixel = 0, Text = e.text, TextColor3 = logColor(e.t), Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left}, logList)
    round(lbl, 6); new("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3)}, lbl)
    local kids = logList:GetChildren()
    if #kids > 151 then for _, ch in ipairs(kids) do if ch:IsA("TextLabel") then ch:Destroy(); break end end end
end
local function pushLog(msg, t, ts)
    local e = {text = os.date("%H:%M:%S", ts or os.time()) .. " " .. msg, t = t}
    logEntries[#logEntries + 1] = e
    if #logEntries > 500 then table.remove(logEntries, 1) end
    if logList and logPass(t) then addLogRow(e) end
end
local function rebuildLog()
    clearList(logList)
    local start = math.max(1, #logEntries - 149)
    for i = start, #logEntries do if logPass(logEntries[i].t) then addLogRow(logEntries[i]) end end
end

makeLabel(pageLog, "— Log do Cliente (Output/Console) —")
local filterRow = new("Frame", {Size = UDim2.new(1, -6, 0, 34), BackgroundTransparency = 1}, pageLog)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4)}, filterRow)
for _, f in ipairs({{"Tudo", "all"}, {"Erros", "error"}, {"Avisos", "warn"}}) do
    local b = new("TextButton", {Size = UDim2.new(1/3, -3, 1, 0), BackgroundColor3 = Theme.Row, Text = f[1], TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false}, filterRow)
    round(b, 8); stroke(b, Theme.Stroke)
    b.MouseButton1Click:Connect(function() logFilter = f[2]; rebuildLog() end)
end
makeButton(pageLog, "📋 Copiar log completo", function()
    local t = {}
    for _, e in ipairs(logEntries) do t[#t + 1] = e.text end
    clip(table.concat(t, "\n"))
end)
makeButton(pageLog, "🧹 Limpar", function() logEntries = {}; clearList(logList) end)
logList = makeList(pageLog)

pcall(function()
    for _, h in ipairs(LogService:GetLogHistory()) do pushLog(h.message, h.messageType, h.timestamp) end
end)
track(LogService.MessageOut:Connect(function(msg, t) pushLog(msg, t) end))

-- ============================================
-- ABA 13: LUCKY BLOCK (detecta spawn + TP exato)
-- ============================================
local pageLucky = makePage("lucky", "🍀 Lucky", 13)
local luckyAuto, luckyExact = false, false
local luckyName = "lucky"      -- trecho do nome (minúsculo)
local luckyTimeout = 10        -- segundos esperando ela carregar por completo
local luckySeen = setmetatable({}, {__mode = "k"})
local luckyRemotes = setmetatable({}, {__mode = "k"})
local lastLucky
local luckyStatus, luckyList

local function luckyTP(pos, name)
    local hrp = getHRP()
    if not hrp then return notify("⚠️ Personagem não encontrado") end
    local off = luckyExact and Vector3.zero or Vector3.new(0, 3, 0)
    hrp.CFrame = CFrame.new(pos + off)
    hrp.AssemblyLinearVelocity = Vector3.zero
    notify("🍀 TP: " .. tostring(name))
end

local function luckyRecord(name, pos, inst)
    lastLucky = {name = name, pos = pos, inst = inst}
    local coords = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
    luckyStatus.Text = "✅ " .. os.date("%H:%M:%S") .. " " .. name .. " @ " .. coords
    luckyStatus.TextColor3 = Theme.Green
    makeRow(luckyList, os.date("%H:%M:%S") .. " " .. name .. "\n" .. coords, Theme.Text, {
        {"📍", function() luckyTP(pos, name) end},
        {"📋", function() clip(string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)) end},
    }, 48)
    local kids = luckyList:GetChildren()
    if #kids > 21 then for _, c in ipairs(kids) do if c:IsA("Frame") then c:Destroy(); break end end end
end

-- espera a block terminar de carregar e a posição estabilizar (evita TP em 0,0,0)
local function luckyResolve(o)
    local t0, last, stable = os.clock(), nil, 0
    while os.clock() - t0 < luckyTimeout do
        if not o.Parent then return nil end
        local ready = o:IsA("BasePart") or o:FindFirstChildWhichIsA("BasePart", true)
        local pos = ready and getPos(o)
        if pos and pos.Magnitude > 1 then
            if last and (pos - last).Magnitude < 0.05 then stable += 1 else stable = 0 end
            last = pos
            if stable >= 3 then return pos end
        end
        task.wait(0.1)
    end
    return last
end

local function luckyMatch(o)
    if not (o:IsA("Model") or o:IsA("BasePart")) then return false end
    if not o.Name:lower():find(luckyName, 1, true) then return false end
    -- ignora partes internas de um model que já bate com o nome
    if o.Parent and o.Parent ~= workspace and o.Parent:IsA("Model") and o.Parent.Name:lower():find(luckyName, 1, true) then return false end
    return true
end

local function luckyHandle(o)
    if luckySeen[o] then return end
    luckySeen[o] = true
    luckyStatus.Text = "⏳ Detectada: " .. o.Name .. " (carregando...)"
    luckyStatus.TextColor3 = Theme.Yellow
    local pos = luckyResolve(o)
    if not pos then luckyStatus.Text = "❌ Sumiu antes de carregar"; luckyStatus.TextColor3 = Theme.Red; return end
    luckyRecord(o.Name, pos, o)
    if luckyAuto then luckyTP(pos, o.Name) end
end

-- Detecção por RemoteEvent (funciona com StreamingEnabled: o server manda a posição)
local function luckyHookRemote(r)
    if not r:IsA("RemoteEvent") or luckyRemotes[r] then return end
    if not r.Name:lower():find(luckyName, 1, true) then return end
    luckyRemotes[r] = true
    track(r.OnClientEvent:Connect(function(...)
        for _, v in ipairs({...}) do
            local pos
            if typeof(v) == "Vector3" then pos = v
            elseif typeof(v) == "CFrame" then pos = v.Position
            elseif typeof(v) == "Instance" then task.spawn(luckyHandle, v) end
            if pos then
                luckyRecord("Remote: " .. r.Name, pos, nil)
                if luckyAuto then luckyTP(pos, r.Name) end
            end
        end
    end))
end

track(workspace.DescendantAdded:Connect(function(o)
    if luckyMatch(o) then task.spawn(luckyHandle, o) end
end))
track(game.DescendantAdded:Connect(function(o) pcall(luckyHookRemote, o) end))

local function luckyScan()
    luckySeen = setmetatable({}, {__mode = "k"})
    local n = 0
    for _, o in ipairs(game:GetDescendants()) do
        pcall(luckyHookRemote, o)
        if o:IsDescendantOf(workspace) and luckyMatch(o) then n += 1; task.spawn(luckyHandle, o) end
    end
    notify("🍀 " .. n .. " lucky block(s) no mapa")
end

makeLabel(pageLucky, "— Lucky Block —")
makeToggle(pageLucky, "🍀 Auto-TP quando spawnar", false, function(on) luckyAuto = on; notify(on and "🍀 Auto-TP ligado" or "⛔ Auto-TP desligado") end)
makeToggle(pageLucky, "🎯 TP exato (sem offset de altura)", false, function(on) luckyExact = on end)
makeSearch(pageLucky, "Nome da lucky block (padrão: lucky)", function(t)
    luckyName = (t == "" and "lucky") or t:lower()
end)
makeButton(pageLucky, "🔍 Escanear agora", luckyScan)
makeButton(pageLucky, "📍 TP na última encontrada", function()
    if lastLucky and (not lastLucky.inst or lastLucky.inst.Parent) then luckyTP(lastLucky.pos, lastLucky.name)
    elseif lastLucky then luckyTP(lastLucky.pos, lastLucky.name .. " (posição antiga)")
    else notify("⚠️ Nenhuma encontrada ainda") end
end)
luckyStatus = makeLabel(pageLucky, "Aguardando spawn...", Theme.TextGray, 36)
makeLabel(pageLucky, "— Histórico (📍 TP | 📋 copiar posição) —", Theme.Green)
luckyList = makeList(pageLucky)
task.spawn(luckyScan)

-- ============================================
-- LIMPEZA
-- ============================================
env.PinkPanelCleanup = function()
    stopFly(); stopStalk()
    isFarming = false; isInvisibleServer = false; spyOut = false; luckyAuto = false
    setIncoming(false)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
end

selectTab("players")
print("[Painel] v29 carregado! 🌸")
