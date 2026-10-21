-- ============================================
-- PAINEL v30 - Cartoon / Fly / Explorer+Spy / Código+Diag+Log / TP / Lucky
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

-- ============================================
-- TEMA CARTOON
-- ============================================
local Theme = {
    Bg         = Color3.fromRGB(30, 26, 46),
    TopBar     = Color3.fromRGB(45, 38, 70),
    Row        = Color3.fromRGB(58, 50, 88),
    RowHover   = Color3.fromRGB(80, 70, 120),
    Stroke     = Color3.fromRGB(120, 100, 200),
    Off        = Color3.fromRGB(70, 65, 95),
    Pink       = Color3.fromRGB(255, 120, 200),
    PinkDark   = Color3.fromRGB(200, 80, 160),
    Text       = Color3.fromRGB(255, 245, 255),
    TextGray   = Color3.fromRGB(200, 190, 220),
    Green      = Color3.fromRGB(120, 230, 150),
    Red        = Color3.fromRGB(255, 90, 110),
    Yellow     = Color3.fromRGB(255, 220, 100),
    Shadow     = Color3.fromRGB(10, 8, 20),
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
local pSize = isMobile and UDim2.new(0, 380, 0, 560) or UDim2.new(0, 540, 0, 660)

-- SOMBRA
local shadow = new("Frame", {
    Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 8, 0.5, 8),
    BackgroundColor3 = Theme.Shadow, BorderSizePixel = 0,
    Visible = false, ZIndex = 1
}, ScreenGui)
round(shadow, 16)

-- BOTÃO FLUTUANTE
local FloatBtn = new("TextButton", {
    Size = UDim2.new(0, 62, 0, 62), Position = UDim2.new(0, 20, 0.5, -31),
    BackgroundColor3 = Theme.Pink, Text = "🌸", TextColor3 = Theme.Bg,
    Font = Enum.Font.GothamBlack, TextSize = 28, BorderSizePixel = 0, AutoButtonColor = false
}, ScreenGui)
round(FloatBtn, 31); stroke(FloatBtn, Theme.Bg, 3)

-- PAINEL
local MainFrame = new("Frame", {
    Size = pSize, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
    Visible = false, ClipsDescendants = true, ZIndex = 2
}, ScreenGui)
round(MainFrame, 16); stroke(MainFrame, Theme.Pink, 3)

-- TOPBAR
local TopBar = new("Frame", {Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = Theme.TopBar, BorderSizePixel = 0}, MainFrame)
round(TopBar, 16)
new("Frame", {Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -1.5), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0}, TopBar)
new("TextLabel", {Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 18, 0, 0), BackgroundTransparency = 1, Text = "🌸 Painel v30", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBlack, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left}, TopBar)

local CloseBtn = new("TextButton", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -42, 0.5, -16), BackgroundColor3 = Theme.Bg, Text = "✕", TextColor3 = Theme.Pink, Font = Enum.Font.GothamBlack, TextSize = 16, BorderSizePixel = 0, AutoButtonColor = false}, TopBar)
round(CloseBtn, 10); stroke(CloseBtn, Theme.Pink, 2)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; shadow.Visible = false; FloatBtn.Visible = true end)
FloatBtn.MouseButton1Click:Connect(function() FloatBtn.Visible = false; MainFrame.Visible = true; shadow.Visible = true; tween(MainFrame, {Size = pSize}) end)

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
    if f then pcall(f, s); notify("📋 Copiado!") else notify("⚠️ Executor sem setclipboard") end
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
    local page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Pink, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Active = true, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable}, Body)
    new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, page)
    pages[name] = page; return page
end

-- Componentes
local function makeLabel(parent, text, color, height)
    return new("TextLabel", {Size = UDim2.new(1, -6, 0, height or 24), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.Pink, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true}, parent)
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {Size = UDim2.new(1, -6, 0, 44), BackgroundColor3 = Theme.Row, Text = "  " .. text, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutoButtonColor = false, Active = false, Selectable = false}, parent)
    round(btn, 12); stroke(btn, Theme.Stroke, 2)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.Pink, TextColor3 = Theme.Bg}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text}) end)
    btn.MouseButton1Click:Connect(callback); return btn
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local row = new("TextButton", {Size = UDim2.new(1, -6, 0, 48), BackgroundColor3 = Theme.Row, Text = "", BorderSizePixel = 0, AutoButtonColor = false, Active = false, Selectable = false}, parent)
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
    local box = new("TextBox", {Size = UDim2.new(1, -6, 0, 38), BackgroundColor3 = Theme.Row, PlaceholderText = "🔎  " .. placeholder, PlaceholderColor3 = Theme.TextGray, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, Active = true}, parent)
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

-- Sub-menu horizontal (para juntar abas)
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

-- ============================================
-- HELPERS GERAIS
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
    L[#L + 1] = "Filhos: " .. #o:GetChildren()
    return table.concat(L, "\n")
end

-- ============================================
-- FLY / STALKER / INVIS / FARM
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
    local myHRP = getHRP(); if not myHRP then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart"); if not targetHRP then return end
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
        if flyDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v -= 1 end
        dir += Vector3.yAxis * v
        flyBV.Velocity = dir * flySpeed
        flyBG.CFrame = cf
    end)
    notify("🕊️ Fly ligado")
end

track(LocalPlayer.CharacterAdded:Connect(function() if flying then task.wait(1); startFly() end end))

-- Farm candy (mantido)
local isFarming = false
local farmingThread = nil
local candyWaitTime = 0.2

local function getAllCandies()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("candy", 1, true) and (obj:IsA("BasePart") or obj:IsA("Model")) then table.insert(list, obj) end
    end
    return list
end

local function safeTeleport(targetPos)
    local hrp = getHRP(); if not hrp then return end
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
                row.Size = UDim2.new(1, 0, 0, 44)
                local targetBtn = new("TextButton", {Size = UDim2.new(0, 32, 1, -8), Position = UDim2.new(1, -36, 0, 4), BackgroundColor3 = Theme.Pink, Text = "🎯", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBlack, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false, Active = false}, row)
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
-- ABA 2: STALKER
-- ============================================
local pageStalker = makePage("stalker", "🕵️ Stalker", 2)
makeLabel(pageStalker, "— Alvo Atual —")
targetLabel = makeLabel(pageStalker, "Nenhum alvo", Theme.TextGray, 24)

makeButton(pageStalker, "📍 Teleportar para o Alvo
