-- ============================================
-- PAINEL GHOST 
-- ============================================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Tween = game:GetService("TweenService")
local VU = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LogS = game:GetService("LogService")
local LP = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.PCClean then pcall(env.PCClean) end
if env.PCGui then pcall(function() env.PCGui:Destroy() end) end

local T = {Bg=Color3.fromRGB(30,26,46),Top=Color3.fromRGB(45,38,70),Row=Color3.fromRGB(58,50,88),Str=Color3.fromRGB(120,100,200),Off=Color3.fromRGB(70,65,95),Pink=Color3.fromRGB(255,120,200),Tx=Color3.fromRGB(255,245,255),Gray=Color3.fromRGB(200,190,220),Grn=Color3.fromRGB(120,230,150),Red=Color3.fromRGB(255,90,110),Yel=Color3.fromRGB(255,220,100),Shd=Color3.fromRGB(10,8,20)}

local conns = {}
local function track(c) conns[#conns+1]=c; return c end
local function tw(o,p) Tween:Create(o,TweenInfo.new(0.2),p):Play() end
local function new(c,p,par) local i=Instance.new(c); for k,v in pairs(p) do i[k]=v end; if par then i.Parent=par end; return i end
local function rnd(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function strk(p,c,t) return new("UIStroke",{Color=c,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end

task.wait(0.5)

local SG = new("ScreenGui",{Name="Painel",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999999},LP:WaitForChild("PlayerGui"))
env.PCGui = SG

local mob = UIS.TouchEnabled and not UIS.KeyboardEnabled
local pSz = mob and UDim2.new(0,380,0,560) or UDim2.new(0,540,0,660)

local shd = new("Frame",{Size=pSz,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,8,0.5,8),BackgroundColor3=T.Shd,BorderSizePixel=0,Visible=false,ZIndex=1},SG)
rnd(shd,16)

local FB = new("TextButton",{Size=UDim2.new(0,62,0,62),Position=UDim2.new(0,20,0.5,-31),BackgroundColor3=T.Pink,Text="🌸",TextColor3=T.Bg,Font=Enum.Font.GothamBlack,TextSize=28,BorderSizePixel=0,AutoButtonColor=false},SG)
rnd(FB,31); strk(FB,T.Bg,3)

local MF = new("Frame",{Size=pSz,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=T.Bg,BorderSizePixel=0,Visible=false,ClipsDescendants=true,ZIndex=2},SG)
rnd(MF,16); strk(MF,T.Pink,3)

local TB = new("Frame",{Size=UDim2.new(1,0,0,55),BackgroundColor3=T.Top,BorderSizePixel=0},MF)
rnd(TB,16)
new("Frame",{Size=UDim2.new(1,0,0,3),Position=UDim2.new(0,0,1,-1.5),BackgroundColor3=T.Pink,BorderSizePixel=0},TB)
new("TextLabel",{Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,Text="🌸 Painel v32",TextColor3=T.Pink,Font=Enum.Font.GothamBlack,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left},TB)

local CB = new("TextButton",{Size=UDim2.new(0,32,0,32),Position=UDim2.new(1,-42,0.5,-16),BackgroundColor3=T.Bg,Text="✕",TextColor3=T.Pink,Font=Enum.Font.GothamBlack,TextSize=16,BorderSizePixel=0,AutoButtonColor=false},TB)
rnd(CB,10); strk(CB,T.Pink,2)
CB.MouseButton1Click:Connect(function() MF.Visible=false; shd.Visible=false; FB.Visible=true end)
FB.MouseButton1Click:Connect(function() FB.Visible=false; MF.Visible=true; shd.Visible=true end)

local drag, dS, sP
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true; dS=i.Position; sP=MF.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
track(UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dS
        MF.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y)
        shd.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X+8,sP.Y.Scale,sP.Y.Offset+d.Y+8)
    end
end))

local function notify(txt)
    local t = new("TextLabel",{Size=UDim2.new(0,300,0,42),AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,60),BackgroundColor3=T.Top,Text=txt,TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=13,TextWrapped=true,ZIndex=999999},SG)
    rnd(t,12); strk(t,T.Pink,2)
    tw(t,{Position=UDim2.new(0.5,0,1,-30)})
    task.delay(2,function() if t.Parent then tw(t,{Position=UDim2.new(0.5,0,1,60)}); task.wait(0.3); t:Destroy() end end)
end

local function clip(s)
    local f = setclipboard or toclipboard
    if f then pcall(f,s); notify("📋 Copiado!") else notify("⚠️ Sem setclipboard") end
end

local TabBar = new("ScrollingFrame",{Size=UDim2.new(1,-20,0,42),Position=UDim2.new(0,10,0,66),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.Pink,AutomaticCanvasSize=Enum.AutomaticSize.X,CanvasSize=UDim2.new(0,0,0,0),ScrollingDirection=Enum.ScrollingDirection.X},MF)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center},TabBar)
local Body = new("Frame",{Size=UDim2.new(1,-20,1,-120),Position=UDim2.new(0,10,0,116),BackgroundTransparency=1},MF)
local pages, tbtns = {}, {}

local function selTab(n)
    for k,p in pairs(pages) do p.Visible=(k==n) end
    for k,b in pairs(tbtns) do tw(b,{BackgroundColor3=(k==n) and T.Pink or T.Top,TextColor3=(k==n) and T.Bg or T.Gray}) end
end

local function mkPage(name,label,order)
    local b = new("TextButton",{Size=UDim2.new(0,96,0,32),BackgroundColor3=T.Top,Text=label,TextColor3=T.Gray,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false,LayoutOrder=order},TabBar)
    rnd(b,10); strk(b,T.Str,2)
    b.MouseButton1Click:Connect(function() selTab(name) end); tbtns[name]=b
    local p = new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=T.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),Visible=false,Active=true},Body)
    new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},p)
    new("UIPadding",{PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,10)},p)
    pages[name]=p; return p
end

local function mkLabel(par,txt,col,h)
    return new("TextLabel",{Size=UDim2.new(1,-6,0,h or 24),BackgroundTransparency=1,Text=txt,TextColor3=col or T.Pink,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},par)
end

local function mkBtn(par,txt,cb)
    local b = new("TextButton",{Size=UDim2.new(1,-6,0,44),BackgroundColor3=T.Row,Text="  "..txt,TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,AutoButtonColor=false},par)
    rnd(b,12); strk(b,T.Str,2)
    b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=T.Pink,TextColor3=T.Bg}) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=T.Row,TextColor3=T.Tx}) end)
    b.MouseButton1Click:Connect(cb); return b
end

local function mkTog(par,txt,def,cb)
    local st = def
    local r = new("TextButton",{Size=UDim2.new(1,-6,0,48),BackgroundColor3=T.Row,Text="",BorderSizePixel=0,AutoButtonColor=false},par)
    rnd(r,12); strk(r,T.Str,2)
    new("TextLabel",{Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=txt,TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},r)
    local tr = new("Frame",{Size=UDim2.new(0,48,0,26),Position=UDim2.new(1,-60,0.5,-13),BackgroundColor3=T.Off,BorderSizePixel=0},r)
    rnd(tr,13); strk(tr,T.Str,2)
    local kn = new("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,4,0.5,-9),BackgroundColor3=T.Tx,BorderSizePixel=0},tr)
    rnd(kn,9)
    local function rd() tw(tr,{BackgroundColor3=st and T.Pink or T.Off}); tw(kn,{Position=st and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)}) end
    rd(); r.MouseButton1Click:Connect(function() st=not st; rd(); cb(st) end)
end

local function mkSrch(par,ph,cb)
    local b = new("TextBox",{Size=UDim2.new(1,-6,0,38),BackgroundColor3=T.Row,PlaceholderText="🔎  "..ph,PlaceholderColor3=T.Gray,Text="",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=13,ClearTextOnFocus=false,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left},par)
    rnd(b,12); strk(b,T.Str,2)
    new("UIPadding",{PaddingLeft=UDim.new(0,10)},b)
    b:GetPropertyChangedSignal("Text"):Connect(function() cb(b.Text) end)
    return b
end

local function mkList(par)
    local f = new("Frame",{Size=UDim2.new(1,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},par)
    new("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},f)
    return f
end
local function clrList(f) for _,c in ipairs(f:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end end

local function mkRow(par,txt,col,btns,h)
    local r = new("Frame",{Size=UDim2.new(1,0,0,h or 58),BackgroundColor3=T.Row,BorderSizePixel=0},par)
    rnd(r,10); strk(r,T.Str,2)
    local w = #btns*36+8
    new("TextLabel",{Size=UDim2.new(1,-w-8,1,-6),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,Text=txt,TextColor3=col or T.Tx,Font=Enum.Font.GothamBold,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center},r)
    for i,b in ipairs(btns) do
        local btn = new("TextButton",{Size=UDim2.new(0,32,0,32),Position=UDim2.new(1,-(#btns-i+1)*36,0.5,-16),BackgroundColor3=T.Pink,Text=b[1],TextColor3=T.Bg,Font=Enum.Font.GothamBlack,TextSize=14,BorderSizePixel=0,AutoButtonColor=false},r)
        rnd(btn,8); btn.MouseButton1Click:Connect(b[2])
    end
    return r
end

local function getHRP() return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end
local function getPos(o)
    if o:IsA("BasePart") then return o.Position end
    if o:IsA("Model") then local ok2,p=pcall(function() return o:GetPivot().Position end); if ok2 then return p end end
    return nil
end
local function tpTo(o)
    local hrp,pos = getHRP(),getPos(o)
    if hrp and pos then hrp.CFrame = CFrame.new(pos+Vector3.new(0,5,0)); notify("📍 TP: "..o.Name) end
end
local idP = {"MeshId","TextureID","AnimationId","SoundId","Image"}
local function getIds(o)
    local out = {}
    for _,p in ipairs(idP) do local ok2,v=pcall(function() return o[p] end); if ok2 and type(v)=="string" and v~="" then out[#out+1]=p.."="..v end end
    return table.concat(out," | ")
end

-- ========== ABA PLAYERS ==========
local pPl = mkPage("players","👥 Players",1)
local pFil = ""
local pLst = mkList(pPl)
local curTarget, targetLbl

local function rebuildPl()
    clrList(pLst)
    for _,pl in ipairs(Players:GetChildren()) do
        if pl~=LP then
            local dn, un = pl.DisplayName, pl.Name
            if pFil=="" or un:lower():find(pFil,1,true) or dn:lower():find(pFil,1,true) then
                local r = mkBtn(pLst,"➤ "..dn.." (@"..un..")",function()
                    local mh = getHRP(); local th = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                    if mh and th then mh.CFrame = th.CFrame*CFrame.new(0,0,3); notify("📍 TP: "..un) end
                end)
                r.Size = UDim2.new(1,0,0,44)
                local tb = new("TextButton",{Size=UDim2.new(0,32,1,-8),Position=UDim2.new(1,-36,0,4),BackgroundColor3=T.Pink,Text="🎯",TextColor3=T.Bg,Font=Enum.Font.GothamBlack,TextSize=14,BorderSizePixel=0,AutoButtonColor=false},r)
                rnd(tb,8)
                tb.MouseButton1Click:Connect(function()
                    curTarget = pl; notify("🎯 Alvo: "..un)
                    if targetLbl then targetLbl.Text = dn.." (@"..un..")"; targetLbl.TextColor3=T.Tx end
                    selTab("stalker")
                end)
            end
        end
    end
end
mkSrch(pPl,"Buscar @nome...",function(t) pFil=t:lower(); rebuildPl() end)
mkBtn(pPl,"🔃 Atualizar",rebuildPl)
rebuildPl()
track(Players.PlayerAdded:Connect(rebuildPl))
track(Players.PlayerRemoving:Connect(function() task.wait(0.1); rebuildPl() end))

-- ========== ABA STALKER ==========
local pSt = mkPage("stalker","🕵️ Stalker",2)
mkLabel(pSt,"— Alvo Atual —")
targetLbl = mkLabel(pSt,"Nenhum alvo",T.Gray,24)
mkBtn(pSt,"📍 TP para Alvo",function()
    if curTarget and curTarget.Character then
        local mh = getHRP(); local th = curTarget.Character:FindFirstChild("HumanoidRootPart")
        if mh and th then mh.CFrame = th.CFrame*CFrame.new(0,0,3); notify("📍 TP: "..curTarget.Name) end
    else notify("⚠️ Selecione alvo") end
end)

-- ========== ABA UTIL (Fly + Anti-AFK) ==========
local pUt = mkPage("util","⚙️ Util",3)
mkTog(pUt,"🔄 Anti-AFK",false,function(on)
    if on then env.AFK = LP.Idled:Connect(function() pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end) end)
    elseif env.AFK then env.AFK:Disconnect(); env.AFK=nil end
end)

local flying, fSpd, fUp, fDn = false, 60, false, false
local fBV, fBG, fConn
local function stopFly()
    flying = false
    if fConn then fConn:Disconnect(); fConn=nil end
    if fBV then fBV:Destroy(); fBV=nil end
    if fBG then fBG:Destroy(); fBG=nil end
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand = false end
end
local function startFly()
    local hrp = getHRP(); local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not h then notify("⚠️ Personagem não encontrado"); return end
    stopFly(); flying = true
    fBV = new("BodyVelocity",{MaxForce=Vector3.new(1e9,1e9,1e9),Velocity=Vector3.zero},hrp)
    fBG = new("BodyGyro",{MaxTorque=Vector3.new(1e9,1e9,1e9),P=9e4,CFrame=hrp.CFrame},hrp)
    h.PlatformStand = true
    fConn = Run.RenderStepped:Connect(function()
        if not (hrp.Parent and h.Parent) then return stopFly() end
        local cf = workspace.CurrentCamera.CFrame
        local md = h.MoveDirection
        local dir = Vector3.zero
        if md.Magnitude>0 then
            local fl = Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
            if fl.Magnitude<0.01 then fl = Vector3.new(cf.UpVector.X,0,cf.UpVector.Z) end
            local fr = Vector3.new(cf.RightVector.X,0,cf.RightVector.Z)
            local lz,lx = md:Dot(fl.Unit),md:Dot(fr.Unit)
            dir = cf.RightVector*lx + cf.LookVector*lz
        end
        local v = 0
        if fUp or UIS:IsKeyDown(Enum.KeyCode.Space) then v+=1 end
        if fDn or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then v-=1 end
        dir += Vector3.yAxis*v
        fBV.Velocity = dir*fSpd
        fBG.CFrame = cf
    end)
    notify("🕊️ Fly ligado")
end
track(LP.CharacterAdded:Connect(function() if flying then task.wait(1); startFly() end end))
mkTog(pUt,"🕊️ Fly",false,function(on) if on then startFly() else stopFly(); notify("⛔ Fly desligado") end end)
local spdB = new("TextBox",{Size=UDim2.new(1,-6,0,38),BackgroundColor3=T.Row,PlaceholderText="Velocidade do Fly (60)",PlaceholderColor3=T.Gray,Text="",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=13,ClearTextOnFocus=false,BorderSizePixel=0},pUt)
rnd(spdB,12); strk(spdB,T.Str,2)
spdB.FocusLost:Connect(function() local n=tonumber(spdB.Text); if n then fSpd=math.clamp(n,1,500); notify("🕊️ Vel: "..fSpd) end end)

-- ========== ABA TP ==========
local pTp = mkPage("positions","📍 TP",4)
mkLabel(pTp,"— Salvar / Voltar —",T.Grn)
local savedP = {}
local nmBox = new("TextBox",{Size=UDim2.new(1,-6,0,40),BackgroundColor3=T.Row,PlaceholderText="Nome do ponto...",PlaceholderColor3=T.Gray,Text="",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=14,ClearTextOnFocus=false,BorderSizePixel=0},pTp)
rnd(nmBox,10); strk(nmBox,T.Str,2)
local posLst = mkList(pTp)

local function renderP()
    clrList(posLst)
    if #savedP==0 then
        local l = new("TextLabel",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.Row,Text="Nenhum ponto salvo",TextColor3=T.Gray,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},posLst)
        rnd(l,10); strk(l,T.Str,2); return
    end
    for i,p in ipairs(savedP) do
        local r = new("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=T.Row,BorderSizePixel=0},posLst)
        rnd(r,10); strk(r,T.Str,2)
        local co = string.format("%.1f, %.1f, %.1f",p.cf.X,p.cf.Y,p.cf.Z)
        new("TextLabel",{Size=UDim2.new(1,-120,1,-6),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,Text=p.name.."\n"..co,TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},r)
        local tpb = new("TextButton",{Size=UDim2.new(0,32,1,-10),Position=UDim2.new(1,-80,0,5),BackgroundColor3=T.Grn,Text="📍",TextColor3=T.Bg,Font=Enum.Font.GothamBlack,TextSize=14,BorderSizePixel=0,AutoButtonColor=false},r)
        rnd(tpb,8)
        tpb.MouseButton1Click:Connect(function() local hrp=getHRP(); if hrp then hrp.CFrame=p.cf+Vector3.new(0,3,0); notify("📍 TP: "..p.name) end end)
        local dl = new("TextButton",{Size=UDim2.new(0,32,1,-10),Position=UDim2.new(1,-44,0,5),BackgroundColor3=T.Red,Text="✕",TextColor3=T.Bg,Font=Enum.Font.GothamBlack,TextSize=14,BorderSizePixel=0,AutoButtonColor=false},r)
        rnd(dl,8)
        dl.MouseButton1Click:Connect(function() table.remove(savedP,i); renderP() end)
    end
end
mkBtn(pTp,"💾 Salvar posição atual",function()
    local hrp = getHRP(); if not hrp then return notify("⚠️ Personagem não encontrado") end
    local nm = nmBox.Text~="" and nmBox.Text or ("Ponto "..(#savedP+1))
    table.insert(savedP,{name=nm,cf=hrp.CFrame}); nmBox.Text=""
    notify("💾 Salvo: "..nm); renderP()
end)
mkBtn(pTp,"📋 Exportar como script",function()
    if #savedP==0 then return notify("⚠️ Nada salvo") end
    local out = {}
    for _,p in ipairs(savedP) do out[#out+1]=string.format('["%s"]=CFrame.new(%.2f,%.2f,%.2f);',p.name,p.cf.X,p.cf.Y,p.cf.Z) end
    clip("local pontos={\n  "..table.concat(out,"\n  ").."\n}")
end)
renderP()

-- ========== ABA FARM ==========
local pFm = mkPage("farm","🍬 Farm",5)
local isFarm, farmTh = false, nil

local function allCandy()
    local l = {}
    for _,o in ipairs(workspace:GetDescendants()) do
        if o.Name:lower():find("candy",1,true) and (o:IsA("BasePart") or o:IsA("Model")) then l[#l+1]=o end
    end
    return l
end

-- 👇 ANDA ATÉ O ITEM (em vez de teleportar pra cima)
local function walkTo(targetPos, opts)
    opts = opts or {}
    local hrp = getHRP()
    if not hrp then return false end

    local stopDist = opts.stopDist or 3          -- para a X studs do item
    local stepTime = opts.stepTime or 0.08       -- tempo de cada passo
    local maxTime  = opts.maxTime  or 15         -- tempo máximo andando (segurança)
    local speed    = opts.speed    or 22         -- studs por passo (velocidade do "andar")

    local start = tick()
    local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")

    while tick() - start < maxTime do
        hrp = getHRP()
        if not hrp then return false end

        local cur = hrp.Position
        local delta = targetPos - cur
        local dist = Vector3.new(delta.X, 0, delta.Z).Magnitude

        if dist <= stopDist then
            return true   -- chegou perto o suficiente
        end

        -- direção no plano XZ (sem subir/descer)
        local dir = Vector3.new(delta.X, 0, delta.Z).Unit
        local moveDist = math.min(speed * stepTime, dist - stopDist)

        -- move mantendo a altura do chão (Raycast pra não subir na parede)
        local nextPos = cur + dir * moveDist
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LP.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local ray = workspace:Raycast(Vector3.new(nextPos.X, cur.Y + 6, nextPos.Z), Vector3.new(0, -20, 0), rayParams)

        if ray then
            nextPos = Vector3.new(nextPos.X, ray.Position.Y + (hrp.Size.Y / 2) + 0.5, nextPos.Z)
        end

        hrp.CFrame = CFrame.new(nextPos, nextPos + dir)
        hrp.AssemblyLinearVelocity = Vector3.zero

        -- deixa o pulo desativado pra não bugar
        if humanoid then
            humanoid.Jump = false
        end

        task.wait(stepTime)
    end
    return false
end

-- versão antiga do teleporte mantida como fallback (para distâncias gigantes)
local function fastTP(pos)
    local hrp = getHRP(); if not hrp then return end
    local d = (pos - hrp.Position).Magnitude
    if d > 200 then  -- se está MUITO longe, teleporta parcial pra não demorar demais
        local dr = (pos - hrp.Position).Unit
        for i = 1, 4 do
            hrp.CFrame = hrp.CFrame + dr * (d / 5)
            task.wait(0.08)
        end
    end
end

mkTog(pFm,"🍬 Auto-Farm Candy (andando)",false,function(on)
    isFarm = on
    if on then
        notify("🍬 Farm ligado (andando até o doce)")
        farmTh = task.spawn(function()
            while isFarm and SG.Parent do
                local c = allCandy()
                if #c > 0 then
                    local t = c[1]
                    if t and t.Parent then
                        local pos = t:IsA("BasePart") and t.Position or (t.GetPivot and t:GetPivot().Position)
                        if pos then
                            fastTP(pos)                       -- teleporta só se estiver MUITO longe
                            walkTo(pos, {stopDist = 3.5, stepTime = 0.06, speed = 22})
                            task.wait(0.15)

                            -- coleta via remote do jogo
                            local r = nil
                            pcall(function() r = RS.Features.HalloweenCandy.Remotes.Pickup end)
                            if r then
                                pcall(function() r:InvokeServer(t:GetAttribute("CandyId") or t.Name) end)
                            end

                            -- fallback: tocar no item se tiver TouchTransmitter
                            local hrp = getHRP()
                            if hrp and firetouchinterest then
                                local part = t:IsA("BasePart") and t or t:FindFirstChildWhichIsA("BasePart", true)
                                if part then
                                    pcall(function()
                                        firetouchinterest(hrp, part, 0)
                                        firetouchinterest(hrp, part, 1)
                                    end)
                                end
                            end
                            task.wait(0.3)
                        end
                    end
                else
                    task.wait(1)
                end
                task.wait(0.1)
            end
        end)
    else
        notify("⛔ Farm desligado")
        if farmTh then pcall(task.cancel, farmTh) end
    end
end)

-- opções extras
mkLabel(pFm,"— Ajustes do caminhar —",T.Grn)
local distBox = new("TextBox",{Size=UDim2.new(1,-6,0,38),BackgroundColor3=T.Row,PlaceholderText="Distância pra parar (padrão 3.5)",PlaceholderColor3=T.Gray,Text="",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=13,ClearTextOnFocus=false,BorderSizePixel=0},pFm)
rnd(distBox,12); strk(distBox,T.Str,2)
env.FarmStopDist = 3.5
distBox.FocusLost:Connect(function()
    local n = tonumber(distBox.Text)
    if n then env.FarmStopDist = math.clamp(n, 1, 20); notify("🍬 Para a "..env.FarmStopDist.." studs") end
end)

local spdBox = new("TextBox",{Size=UDim2.new(1,-6,0,38),BackgroundColor3=T.Row,PlaceholderText="Velocidade do andar (padrão 22)",PlaceholderColor3=T.Gray,Text="",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=13,ClearTextOnFocus=false,BorderSizePixel=0},pFm)
rnd(spdBox,12); strk(spdBox,T.Str,2)
env.FarmSpeed = 22
spdBox.FocusLost:Connect(function()
    local n = tonumber(spdBox.Text)
    if n then env.FarmSpeed = math.clamp(n, 5, 100); notify("🍬 Velocidade: "..env.FarmSpeed) end
end)

-- ========== ABA LUCKY ==========
local pLk = mkPage("lucky","🍀 Lucky",6)
local lkName = "lucky"
local lkAuto = false
local lastLk, lkLst

local function lkTP(pos,nm)
    local hrp = getHRP(); if not hrp then return end
    hrp.CFrame = CFrame.new(pos+Vector3.new(0,3,0))
    hrp.AssemblyLinearVelocity = Vector3.zero
    notify("🍀 TP: "..tostring(nm))
end
local function lkRec(nm,pos)
    lastLk = {name=nm,pos=pos}
    local co = string.format("%.1f, %.1f, %.1f",pos.X,pos.Y,pos.Z)
    local r = new("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Row,BorderSizePixel=0},lkLst)
    rnd(r,10); strk(r,T.Str,2)
    new("TextLabel",{Size=UDim2.new(1,-80,1,-6),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,Text=nm.."\n"..co,TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},r)
    local tpb = new("TextButton",{Size=UDim2.new(0,32,1,-10),Position=UDim2.new(1,-44,0,5),BackgroundColor3=T.Grn,Text="📍",TextColor3=T.Bg,Font=Enum.Font.GothamBlack,TextSize=14,BorderSizePixel=0,AutoButtonColor=false},r)
    rnd(tpb,8)
    tpb.MouseButton1Click:Connect(function() lkTP(pos,nm) end)
end
mkLabel(pLk,"— Lucky Block —",T.Grn)
mkTog(pLk,"🍀 Auto-TP ao spawnar",false,function(on) lkAuto=on end)
mkBtn(pLk,"🔍 Escanear agora",function()
    local n = 0
    for _,o in ipairs(workspace:GetDescendants()) do
        if (o:IsA("Model") or o:IsA("BasePart")) and o.Name:lower():find(lkName,1,true) then
            local pos = o:IsA("BasePart") and o.Position or (o.GetPivot and o:GetPivot().Position)
            if pos and pos.Magnitude>1 then n+=1; lkRec(o.Name,pos); if n>=20 then break end end
        end
    end
    notify("🍀 "..n.." lucky encontradas")
end)
mkLabel(pLk,"— Histórico —",T.Grn)
lkLst = mkList(pLk)
track(workspace.DescendantAdded:Connect(function(o)
    if lkAuto and (o:IsA("Model") or o:IsA("BasePart")) and o.Name:lower():find(lkName,1,true) then
        task.wait(1)
        local pos = o:IsA("BasePart") and o.Position or (o.GetPivot and o:GetPivot().Position)
        if pos and pos.Magnitude>1 then lkRec(o.Name,pos); lkTP(pos,o.Name) end
    end
end))

-- ========== ABA EXPLORER/SPY ==========
local pEx = mkPage("explorer","🗺️ Explorer/Spy",7)
local subB = new("Frame",{Size=UDim2.new(1,-6,0,36),BackgroundColor3=T.Top,BorderSizePixel=0},pEx)
rnd(subB,10)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),VerticalAlignment=Enum.VerticalAlignment.Center},subB)
new("UIPadding",{PaddingLeft=UDim.new(0,4)},subB)
local bEx = new("TextButton",{Size=UDim2.new(0.5,-4,1,-8),BackgroundColor3=T.Pink,Text="🗺️ Explorer",TextColor3=T.Bg,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},subB)
rnd(bEx,8)
local bSp = new("TextButton",{Size=UDim2.new(0.5,-4,1,-8),BackgroundColor3=T.Row,Text="📡 Spy",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},subB)
rnd(bSp,8)

local exC = new("Frame",{Size=UDim2.new(1,-6,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},pEx)
new("UIListLayout",{Padding=UDim.new(0,6)},exC)
local spC = new("Frame",{Size=UDim2.new(1,-6,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Visible=false},pEx)
new("UIListLayout",{Padding=UDim.new(0,6)},spC)
bEx.MouseButton1Click:Connect(function() exC.Visible=true; spC.Visible=false; bEx.BackgroundColor3=T.Pink; bEx.TextColor3=T.Bg; bSp.BackgroundColor3=T.Row; bSp.TextColor3=T.Tx end)
bSp.MouseButton1Click:Connect(function() exC.Visible=false; spC.Visible=true; bSp.BackgroundColor3=T.Pink; bSp.TextColor3=T.Bg; bEx.BackgroundColor3=T.Row; bEx.TextColor3=T.Tx end)

-- Explorer
mkLabel(exC,"— Explorer —",T.Grn)
local exSrc, exFil, exEnt = 1, "", {}
local srcN = {"Workspace","ReplicatedStorage","Lighting"}
local srcR = {workspace,RS,game:GetService("Lighting")}
local exCnt, exLst
local function renderEx()
    clrList(exLst)
    local sh = 0
    for _,o in ipairs(exEnt) do
        if exFil=="" or o.Name:lower():find(exFil,1,true) or o.ClassName:lower():find(exFil,1,true) then
            if sh<60 then sh+=1
                local ids = getIds(o)
                local txt = "["..o.ClassName.."] "..o.Name.."\n"..o:GetFullName()..(ids~="" and ("\n"..ids) or "")
                mkRow(exLst,txt,T.Tx,{
                    {"📍",function() tpTo(o) end},
                    {"📋",function() clip(o:GetFullName()) end},
                },58)
            end
        end
    end
    exCnt.Text = sh.." de "..#exEnt
end
local sB
sB = mkBtn(exC,"📂 Fonte: Workspace",function()
    exSrc = exSrc%#srcR+1
    sB.Text = "  📂 Fonte: "..srcN[exSrc]
    local ok2,l = pcall(function() return srcR[exSrc]:GetDescendants() end)
    exEnt = ok2 and l or {}
    renderEx()
end)
mkSrch(exC,"Nome ou classe",function(t) exFil=t:lower(); renderEx() end)
mkBtn(exC,"🔄 Escanear",function()
    local ok2,l = pcall(function() return srcR[exSrc]:GetDescendants() end)
    exEnt = ok2 and l or {}
    renderEx()
end)
exCnt = mkLabel(exC,"Toque Escanear",T.Gray,20)
exLst = mkList(exC)
task.spawn(function()
    local ok2,l = pcall(function() return srcR[exSrc]:GetDescendants() end)
    exEnt = ok2 and l or {}
    renderEx()
end)

-- Spy
mkLabel(spC,"— Spy (recebidos) —",T.Grn)
local spLst = mkList(spC)
local spN = 0
local spConns = {}
local function addSpy(r,...)
    if spN>50 then return end
    spN+=1
    local a = {}
    for i=1,select("#",...) do local v=select(i,...); a[i]=typeof(v)=="Instance" and ("<"..v.ClassName..":"..v.Name..">") or tostring(v) end
    mkRow(spLst,"← "..r:GetFullName().."("..table.concat(a,", ")..")",T.Grn,{},44)
end
mkTog(spC,"📥 Capturar eventos recebidos",false,function(on)
    for _,c in ipairs(spConns) do c:Disconnect() end
    spConns = {}
    if on then
        for _,o in ipairs(game:GetDescendants()) do
            if o:IsA("RemoteEvent") then
                spConns[#spConns+1] = o.OnClientEvent:Connect(function(...) addSpy(o,...) end)
            end
        end
    end
end)
mkBtn(spC,"🧹 Limpar",function() clrList(spLst); spN=0 end)

-- ========== ABA CÓDIGO/DIAG/LOG ==========
local pCDL = mkPage("cdl","💻 Código/Diag/Log",8)
local subC = new("Frame",{Size=UDim2.new(1,-6,0,36),BackgroundColor3=T.Top,BorderSizePixel=0},pCDL)
rnd(subC,10)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),VerticalAlignment=Enum.VerticalAlignment.Center},subC)
new("UIPadding",{PaddingLeft=UDim.new(0,4)},subC)
local bC = new("TextButton",{Size=UDim2.new(0.33,-3,1,-8),BackgroundColor3=T.Pink,Text="💻 Código",TextColor3=T.Bg,Font=Enum.Font.GothamBold,TextSize=11,BorderSizePixel=0},subC)
rnd(bC,8)
local bD = new("TextButton",{Size=UDim2.new(0.33,-3,1,-8),BackgroundColor3=T.Row,Text="📊 Diag",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=11,BorderSizePixel=0},subC)
rnd(bD,8)
local bL = new("TextButton",{Size=UDim2.new(0.33,-3,1,-8),BackgroundColor3=T.Row,Text="🐞 Log",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=11,BorderSizePixel=0},subC)
rnd(bL,8)
local cC = new("Frame",{Size=UDim2.new(1,-6,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},pCDL)
new("UIListLayout",{Padding=UDim.new(0,6)},cC)
local cD = new("Frame",{Size=UDim2.new(1,-6,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Visible=false},pCDL)
new("UIListLayout",{Padding=UDim.new(0,6)},cD)
local cL = new("Frame",{Size=UDim2.new(1,-6,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Visible=false},pCDL)
new("UIListLayout",{Padding=UDim.new(0,6)},cL)
bC.MouseButton1Click:Connect(function() cC.Visible=true; cD.Visible=false; cL.Visible=false; bC.BackgroundColor3=T.Pink; bC.TextColor3=T.Bg; bD.BackgroundColor3=T.Row; bD.TextColor3=T.Tx; bL.BackgroundColor3=T.Row; bL.TextColor3=T.Tx end)
bD.MouseButton1Click:Connect(function() cC.Visible=false; cD.Visible=true; cL.Visible=false; bD.BackgroundColor3=T.Pink; bD.TextColor3=T.Bg; bC.BackgroundColor3=T.Row; bC.TextColor3=T.Tx; bL.BackgroundColor3=T.Row; bL.TextColor3=T.Tx end)
bL.MouseButton1Click:Connect(function() cC.Visible=false; cD.Visible=false; cL.Visible=true; bL.BackgroundColor3=T.Pink; bL.TextColor3=T.Bg; bC.BackgroundColor3=T.Row; bC.TextColor3=T.Tx; bD.BackgroundColor3=T.Row; bD.TextColor3=T.Tx end)

mkLabel(cC,"— Scripts do cliente —",T.Grn)
mkBtn(cC,"📜 Listar scripts",function()
    if not getscripts then return notify("⚠️ Executor sem getscripts") end
    local ok2,s = pcall(getscripts)
    if not ok2 then return notify("❌ Falha") end
    notify("📜 "..tostring(#s).." scripts")
end)
local codeLst = mkList(cC)
mkBtn(cC,"🔄 Limpar",function() clrList(codeLst) end)

mkLabel(cD,"— Info do Mapa —",T.Grn)
local diagI = new("TextLabel",{Size=UDim2.new(1,-6,0,200),BackgroundColor3=T.Row,Text="Toque em Analisar",TextColor3=T.Gray,Font=Enum.Font.Code,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,BorderSizePixel=0},cD)
rnd(diagI,12); strk(diagI,T.Str,2)
new("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingTop=UDim.new(0,4),PaddingRight=UDim.new(0,6)},diagI)
mkBtn(cD,"🔬 Analisar Mapa",function()
    diagI.Text = "Analisando..."
    task.spawn(function()
        local p,m,s = 0,0,0
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") then p+=1
            elseif o:IsA("Model") then m+=1
            elseif o:IsA("LuaSourceContainer") then s+=1 end
        end
        diagI.Text = string.format("PlaceId: %s\nJogadores: %d/%d\nStreaming: %s\nGravidade: %.1f\nVoid: %d\n\nParts: %d\nModels: %d\nScripts: %d",tostring(game.PlaceId),#Players:GetPlayers(),Players.MaxPlayers,tostring(workspace.StreamingEnabled),workspace.Gravity,workspace.FallenPartsDestroyHeight,p,m,s)
        diagI.TextColor3 = T.Tx
    end)
end)

mkLabel(cL,"— Log —",T.Grn)
local logLst = mkList(cL)
local logN = 0
local function addLog(msg,t)
    if logN>60 then return end
    logN+=1
    local col = (t==Enum.MessageType.MessageError) and T.Red or (t==Enum.MessageType.MessageWarning) and T.Yel or T.Gray
    local l = new("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=T.Row,BorderSizePixel=0,Text=msg,TextColor3=col,Font=Enum.Font.Code,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},logLst)
    rnd(l,6)
    new("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,3)},l)
end
pcall(function() for _,h in ipairs(LogS:GetLogHistory()) do addLog(h.message,h.messageType) end end)
track(LogS.MessageOut:Connect(addLog))
mkBtn(cL,"🧹 Limpar",function() clrList(logLst); logN=0 end)

-- ========== ABA ADM ==========
local pAd = mkPage("admin","🔐 ADM",9)
local lF = new("Frame",{Size=UDim2.new(1,-6,0,200),BackgroundTransparency=1},pAd)
new("UIListLayout",{Padding=UDim.new(0,6)},lF)
mkLabel(lF,"Senha: admin123",T.Grn,30)
local pB = new("TextBox",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.Row,PlaceholderText="Digite a senha...",PlaceholderColor3=T.Gray,Text="",TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=14,BorderSizePixel=0},lF)
rnd(pB,10); strk(pB,T.Str,2)
mkBtn(lF,"🔓 Entrar",function()
    if pB.Text=="admin123" then notify("✅ Login OK"); lF.Visible=false
    else notify("❌ Senha errada") end
end)

-- ========== CLEANUP ==========
env.PCClean = function()
    stopFly()
    isFarm = false; lkAuto = false
    if farmTh then pcall(task.cancel,farmTh) end
    for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
end

selTab("players")
print("[Painel v32] Carregado! 🌸")
