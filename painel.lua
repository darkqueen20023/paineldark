-- Execute no seu executor (Versão Sem Lag / Smooth Fly & Speed)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ScriptInspectorUI") then
	playerGui.ScriptInspectorUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptInspectorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 520)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "  ⚡ Smooth Stealth Panel (Sem Lag)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Caixa de Logs
local LogBox = Instance.new("ScrollingFrame")
LogBox.Size = UDim2.new(1, -20, 1, -215)
LogBox.Position = UDim2.new(0, 10, 0, 50)
LogBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
LogBox.BorderSizePixel = 0
LogBox.CanvasSize = UDim2.new(0, 0, 2, 0)
LogBox.Parent = MainFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -10, 1, 0)
LogText.Position = UDim2.new(0, 5, 0, 0)
LogText.BackgroundTransparency = 1
LogText.Text = "Sistema ajustado para evitar lag e travamentos de posição."
LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
LogText.TextSize = 13
LogText.Font = Enum.Font.Code
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Parent = LogBox

-- Botões
local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(0.46, 0, 0, 35)
ScanButton.Position = UDim2.new(0, 10, 1, -145)
ScanButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
ScanButton.Text = "Escanear Mapa"
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.Font = Enum.Font.GothamBold
ScanButton.TextSize = 13
ScanButton.Parent = MainFrame
Instance.new("UICorner", ScanButton).CornerRadius = UDim.new(0, 6)

local GodButton = Instance.new("TextButton")
GodButton.Size = UDim2.new(0.46, 0, 0, 35)
GodButton.Position = UDim2.new(0.52, 0, 1, -145)
GodButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
GodButton.Text = "Imunidade: OFF"
GodButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GodButton.Font = Enum.Font.GothamBold
GodButton.TextSize = 13
GodButton.Parent = MainFrame
Instance.new("UICorner", GodButton).CornerRadius = UDim.new(0, 6)

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0.46, 0, 0, 35)
FlyButton.Position = UDim2.new(0, 10, 1, -95)
FlyButton.BackgroundColor3 = Color3.fromRGB(150, 60, 255)
FlyButton.Text = "Fly (Suave): OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.GothamBold
FlyButton.TextSize = 13
FlyButton.Parent = MainFrame
Instance.new("UICorner", FlyButton).CornerRadius = UDim.new(0, 6)

local TpButton = Instance.new("TextButton")
TpButton.Size = UDim2.new(0.46, 0, 0, 35)
TpButton.Position = UDim2.new(0.52, 0, 1, -95)
TpButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
TpButton.Text = "TP Aleatório"
TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpButton.Font = Enum.Font.GothamBold
TpButton.TextSize = 13
TpButton.Parent = MainFrame
Instance.new("UICorner", TpButton).CornerRadius = UDim.new(0, 6)

--------------------------------------------------------------------------------
-- SISTEMA DE FLY SUAVE (SEM LAG / RUBBERBANDING)
--------------------------------------------------------------------------------

local flyAtivo = false
local conexaoFly = nil
local velocidadeFly = 35 -- Velocidade equilibrada para não causar lag de sincronização

FlyButton.MouseButton1Click:Connect(function()
	flyAtivo = not flyAtivo
	local char = localPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local rootPart = char.HumanoidRootPart
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	
	if flyAtivo then
		FlyButton.Text = "Fly (Suave): ON"
		FlyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
		
		if humanoid then 
			humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		end
		
		conexaoFly = RunService.Heartbeat:Connect(function(dt)
			if not char or not char.Parent then return end
			
			-- Desativa colisão para atravessar objetos sem travar
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
			
			local cam = Workspace.CurrentCamera
			local moveDir = Vector3.new(0, 0, 0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
			
			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit
				rootPart.AssemblyLinearVelocity = moveDir * velocidadeFly
			else
				rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end)
		
		LogText.Text = "[FLY] Voo suave ativado (Sem lag de posição)."
	else
		FlyButton.Text = "Fly (Suave): OFF"
		FlyButton.BackgroundColor3 = Color3.fromRGB(150, 60, 255)
		
		if conexaoFly then conexaoFly:Disconnect() conexaoFly = nil end
		
		if humanoid then 
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
		
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CanCollide = true
			end
		end
		
		LogText.Text = "[FLY] Desativado."
	end
end)

--------------------------------------------------------------------------------
-- IMUNIDADE E FUNÇÕES RESTANTES
--------------------------------------------------------------------------------

local godmodeAtivo, conexaoGodmode = false, nil
GodButton.MouseButton1Click:Connect(function()
	godmodeAtivo = not godmodeAtivo
	if godmodeAtivo then
		GodButton.Text = "Imunidade: ON"
		GodButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
		
		conexaoGodmode = RunService.Heartbeat:Connect(function()
			local char = localPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					if hum.Health > 0 and hum.Health < hum.MaxHealth then
						hum.Health = hum.MaxHealth
					end
					hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				end
				for _, part in ipairs(char:GetChildren()) do
					if part:IsA("BasePart") then part.CanTouch = false end
				end
			end
		end)
		LogText.Text = "[IMUNIDADE] Ativada."
	else
		GodButton.Text = "Imunidade: OFF"
		GodButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		if conexaoGodmode then conexaoGodmode:Disconnect() conexaoGodmode = nil end
		LogText.Text = "[IMUNIDADE] Desativada."
	end
end)

ScanButton.MouseButton1Click:Connect(function()
	local contagem = { Models = 0, Parts = 0, ParticleEmitters = 0, RemoteEvents = 0, BindableEvents = 0 }
	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("Model") then contagem.Models = contagem.Models + 1
		elseif obj:IsA("BasePart") then contagem.Parts = contagem.Parts + 1
		elseif obj:IsA("ParticleEmitter") then contagem.ParticleEmitters = contagem.ParticleEmitters + 1
		elseif obj:IsA("RemoteEvent") then contagem.RemoteEvents = contagem.RemoteEvents + 1
		elseif obj:IsA("BindableEvent") then contagem.BindableEvents = contagem.BindableEvents + 1 end
	end
	LogText.Text = string.format("=== MAPA ESCANEADO ===\n• Models: %d\n• Parts: %d\n• Partículas: %d\n• RemoteEvents: %d\n• Bindables: %d", 
		contagem.Models, contagem.Parts, contagem.ParticleEmitters, contagem.RemoteEvents, contagem.BindableEvents)
end)

TpButton.MouseButton1Click:Connect(function()
	local char = localPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local partes = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj:IsDescendantOf(char) and obj.Transparency < 1 and obj.Size.Magnitude > 3 then
			table.insert(partes, obj)
		end
	end
	if #partes > 0 then
		local escolhida = partes[math.random(1, #partes)]
		char.HumanoidRootPart.CFrame = escolhida.CFrame + Vector3.new(0, 5, 0)
		LogText.Text = "TP efetuado para: " .. escolhida.Name
	end
end)
