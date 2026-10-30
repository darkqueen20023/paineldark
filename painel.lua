-- Execute no seu executor (Versão Imunidade Total / Stealth)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Remove interface anterior se já existir
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
Title.Text = "  🛡️ Stealth & Absolute Godmode"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Caixa de Texto para Logs
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
LogText.Text = "Painel ativado.\nAtive 'Godmode Total' para imunidade completa a mortes."
LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
LogText.TextSize = 13
LogText.Font = Enum.Font.Code
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Parent = LogBox

-- Botão de Escanear
local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(0.46, 0, 0, 35)
ScanButton.Position = UDim2.new(0, 10, 1, -145)
ScanButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
ScanButton.Text = "Escanear Mapa"
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.Font = Enum.Font.GothamBold
ScanButton.TextSize = 13
ScanButton.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = ScanButton

-- Botão Godmode Total (Sem Morte)
local GodButton = Instance.new("TextButton")
GodButton.Size = UDim2.new(0.46, 0, 0, 35)
GodButton.Position = UDim2.new(0.52, 0, 1, -145)
GodButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
GodButton.Text = "Godmode: OFF"
GodButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GodButton.Font = Enum.Font.GothamBold
GodButton.TextSize = 13
GodButton.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = GodButton

-- Botão de Velocidade Segura (CFrame)
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0.46, 0, 0, 35)
SpeedButton.Position = UDim2.new(0, 10, 1, -95)
SpeedButton.BackgroundColor3 = Color3.fromRGB(150, 60, 255)
SpeedButton.Text = "Velocidade: OFF"
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.GothamBold
SpeedButton.TextSize = 13
SpeedButton.Parent = MainFrame

local BtnCorner3 = Instance.new("UICorner")
BtnCorner3.CornerRadius = UDim.new(0, 6)
BtnCorner3.Parent = SpeedButton

-- Botão de TP Aleatório
local TpButton = Instance.new("TextButton")
TpButton.Size = UDim2.new(0.46, 0, 0, 35)
TpButton.Position = UDim2.new(0.52, 0, 1, -95)
TpButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
TpButton.Text = "TP Aleatório"
TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpButton.Font = Enum.Font.GothamBold
TpButton.TextSize = 13
TpButton.Parent = MainFrame

local BtnCorner4 = Instance.new("UICorner")
BtnCorner4.CornerRadius = UDim.new(0, 6)
BtnCorner4.Parent = TpButton

-- Rodapé
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 35)
InfoLabel.Position = UDim2.new(0, 10, 1, -45)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Proteção contra morte por Dano e Hitbox Ativada."
InfoLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

--------------------------------------------------------------------------------
-- FUNÇÕES DE IMUNIDADE E CONTROLE
--------------------------------------------------------------------------------

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

-- SISTEMA DE GODMODE ABSOLUTO
local godmodeAtivo, conexaoGodmode = false, nil

local function aplicarImunidadePersonagem(char)
	if not char then return end
	local hum = char:WaitForChild("Humanoid", 3)
	if hum then
		-- Desativa o estado de Morte no Humanoid
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		
		-- Impede a vida de zerar
		hum.Health = hum.MaxHealth
	end
	
	-- Torna as partes do corpo insensíveis a toques de dano (Hitboxes de ataque não registram)
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanTouch = false
		end
	end
end

GodButton.MouseButton1Click:Connect(function()
	godmodeAtivo = not godmodeAtivo
	if godmodeAtivo then
		GodButton.Text = "Godmode: ON"
		GodButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
		
		aplicarImunidadePersonagem(localPlayer.Character)
		
		conexaoGodmode = RunService.Stepped:Connect(function()
			local char = localPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					if hum.Health < hum.MaxHealth then
						hum.Health = hum.MaxHealth
					end
					if hum:GetState() == Enum.HumanoidStateType.Dead then
						hum:ChangeState(Enum.HumanoidStateType.Running)
					end
				end
			end
		end)
		
		LogText.Text = "[GODMODE] Imunidade Absoluta ATIVADA!"
	else
		GodButton.Text = "Godmode: OFF"
		GodButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		if conexaoGodmode then conexaoGodmode:Disconnect() conexaoGodmode = nil end
		
		local char = localPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then part.CanTouch = true end
			end
		end
		
		LogText.Text = "[GODMODE] Imunidade DESATIVADA."
	end
end)

-- Re-aplica a imunidade caso o personagem renasça
localPlayer.CharacterAdded:Connect(function(novoChar)
	if godmodeAtivo then
		task.wait(0.5)
		aplicarImunidadePersonagem(novoChar)
	end
end)

-- VELOCIDADE CFRAME DISCRETA
local speedAtivo, conexaoSpeed = false, nil
local multiplicador = 1.4

SpeedButton.MouseButton1Click:Connect(function()
	speedAtivo = not speedAtivo
	if speedAtivo then
		SpeedButton.Text = "Velocidade: ON"
		SpeedButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		conexaoSpeed = RunService.RenderStepped:Connect(function(delta)
			local char = localPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local root = char.HumanoidRootPart
				if hum.MoveDirection.Magnitude > 0 then
					root.CFrame = root.CFrame + (hum.MoveDirection * multiplicador * delta * 20)
				end
			end
		end)
	else
		SpeedButton.Text = "Velocidade: OFF"
		SpeedButton.BackgroundColor3 = Color3.fromRGB(150, 60, 255)
		if conexaoSpeed then conexaoSpeed:Disconnect() conexaoSpeed = nil end
	end
end)

-- TP ALEATÓRIO SEGURO
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
	else
		LogText.Text = "Nenhuma parte válida encontrada."
	end
end)
