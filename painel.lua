-- Execute usando um Executor compatível com o jogo.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. CRIAR INTERFACE GRÁFICA (UI) EXPANDIDA
--------------------------------------------------------------------------------

local success, parentUI = pcall(function()
	return CoreGui
end)
if not success or not parentUI then
	parentUI = localPlayer:WaitForChild("PlayerGui")
end

if parentUI:FindFirstChild("ScriptInspectorUI") then
	parentUI.ScriptInspectorUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptInspectorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 520) -- Aumentado para caber as novas opções
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
Title.Text = "  🔍 Inspector, Godmode, Speed & TP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize: 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Caixa de Texto para Logs / Relatório
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
LogText.Text = "Clique em 'Escanear Mapa' para carregar..."
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

-- Botão Godmode
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

-- Botão de Velocidade (Speed)
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

-- Botão de TP Aleatório pelo Mapa
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

-- Nota de aviso rodapé
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 35)
InfoLabel.Position = UDim2.new(0, 10, 1, -45)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Seguro contra crash: loops otimizados via RenderStepped e checagem de nulos."
InfoLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextWrapped = true
InfoLabel.Parent = MainFrame


--------------------------------------------------------------------------------
-- 2. LÓGICA DE INSPEÇÃO
--------------------------------------------------------------------------------

local function realizarVarredura()
	local contagem = {
		Models = 0,
		Parts = 0,
		ParticleEmitters = 0,
		RemoteEvents = 0,
		BindableEvents = 0
	}

	for _, objeto in ipairs(game:GetDescendants()) do
		if objeto:IsA("Model") then
			contagem.Models = contagem.Models + 1
		elseif objeto:IsA("BasePart") then
			contagem.Parts = contagem.Parts + 1
		elseif objeto:IsA("ParticleEmitter") then
			contagem.ParticleEmitters = contagem.ParticleEmitters + 1
		elseif objeto:IsA("RemoteEvent") then
			contagem.RemoteEvents = contagem.RemoteEvents + 1
		elseif objeto:IsA("BindableEvent") then
			contagem.BindableEvents = contagem.BindableEvents + 1
		end
	end

	local resultado = string.format(
		"=== RELATÓRIO DO MAPA ===\n" ..
		"• Models: %d\n" ..
		"• Parts (Peças): %d\n" ..
		"• Partículas: %d\n" ..
		"• RemoteEvents: %d\n" ..
		"• BindableEvents: %d\n" ..
		"=========================\n" ..
		"Tudo pronto. Recursos ativados com segurança.",
		contagem.Models, contagem.Parts, contagem.ParticleEmitters, contagem.RemoteEvents, contagem.BindableEvents
	)

	LogText.Text = resultado
end

ScanButton.MouseButton1Click:Connect(realizarVarredura)

for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
	if v:IsA("RemoteEvent") then
		v.OnClientEvent:Connect(function(...)
			print("[EVENTO] " .. v.Name, ...)
		end)
	end
end


--------------------------------------------------------------------------------
-- 3. GODMODE SEGURO
--------------------------------------------------------------------------------

local godmodeAtivo = false
local conexaoGodmode = nil

local function alternarGodmode()
	godmodeAtivo = not godmodeAtivo
	
	if godmodeAtivo then
		GodButton.Text = "Godmode: ON"
		GodButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
		
		conexaoGodmode = RunService.RenderStepped:Connect(function()
			local char = localPlayer.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health < humanoid.MaxHealth then
					humanoid.Health = humanoid.MaxHealth
				end
			end
		end)
	else
		GodButton.Text = "Godmode: OFF"
		GodButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		
		if conexaoGodmode then
			conexaoGodmode:Disconnect()
			conexaoGodmode = nil
		end
	end
end

GodButton.MouseButton1Click:Connect(alternarGodmode)


--------------------------------------------------------------------------------
-- 4. VELOCIDADE (SPEED) SEGURA (Evita crash por travamento)
--------------------------------------------------------------------------------

local speedAtivo = false
local conexaoSpeed = nil
local velocidadeAlvo = 30 -- Velocidade segura para não bugar o anti-cheat ou crashar

local function alternarSpeed()
	speedAtivo = not speedAtivo
	
	if speedAtivo then
		SpeedButton.Text = "Velocidade: ON"
		SpeedButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		
		conexaoSpeed = RunService.RenderStepped:Connect(function()
			local char = localPlayer.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = velocidadeAlvo
				end
			end
		end)
	else
		SpeedButton.Text = "Velocidade: OFF"
		SpeedButton.BackgroundColor3 = Color3.fromRGB(150, 60, 255)
		
		if conexaoSpeed then
			conexaoSpeed:Disconnect()
			conexaoSpeed = nil
		end
		
		local char = localPlayer.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16 -- Volta ao padrão do Roblox
			end
		end
	end
end

SpeedButton.MouseButton1Click:Connect(alternarSpeed)


--------------------------------------------------------------------------------
-- 5. TELEPORTE ALEATÓRIO SEGURO PELO MAPA
--------------------------------------------------------------------------------

local function teleporteAleatorio()
	local char = localPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then
		LogText.Text = "[AVISO] Personagem não encontrado para TP."
		return
	end

	-- Coleta todas as partes válidas do Workspace que não sejam do próprio jogador
	local partesMapa = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj:IsDescendantOf(char) and obj.Transparency < 1 and obj.Size.Magnitude > 2 then
			table.insert(partesMapa, obj)
		end
	end

	if #partesMapa > 0 then
		-- Escolhe uma peça aleatória de forma segura
		math.randomseed(tick())
partesMapa[math.random(1, #partesMapa)]
		local parteEscolhida = partesMapa[math.random(1, #partesMapa)]
		
		-- Teleporta levemente acima da peça para evitar prender dentro dela
		local posicaoDestino = parteEscolhida.Position + Vector3.new(0, 5, 0)
		char.HumanoidRootPart.CFrame = CFrame.new(posicaoDestino)
		
		LogText.Text = "Teleportado para perto de: " .. parteEscolhida.Name
	else
		LogText.Text = "[AVISO] Nenhuma parte válida encontrada no mapa."
	end
end

TpButton.MouseButton1Click:Connect(teleporteAleatorio)
