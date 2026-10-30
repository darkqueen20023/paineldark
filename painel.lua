-- Versão em Tecla (Funciona mesmo se o jogo bloquear janelas ScreenGui)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

print("[SUCESSO] Script de atalhos ativado!")
print("Pressione a tecla [ E ] para Teleporte Aleatório.")
print("Pressione a tecla [ F ] para ativar a Velocidade (30).")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	local char = localPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	-- Tecla E: Teleporte Aleatório pelo mapa
	if input.KeyCode == Enum.KeyCode.E then
		local partes = {}
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj:IsDescendantOf(char) and obj.Transparency < 1 and obj.Size.Magnitude > 3 then
				table.insert(partes, obj)
			end
		end
		if #partes > 0 then
			local escolhida = partes[math.random(1, #partes)]
			char.HumanoidRootPart.CFrame = escolhida.CFrame + Vector3.new(0, 5, 0)
			print("[TP] Teleportado para perto de: " .. escolhida.Name)
		else
			print("[TP] Nenhuma parte válida encontrada.")
		end
	
	-- Tecla F: Alterna a Velocidade
	elseif input.KeyCode == Enum.KeyCode.F then
		if humanoid then
			if humanoid.WalkSpeed == 16 then
				humanoid.WalkSpeed = 30
				print("[SPEED] Velocidade aumentada para 30!")
			else
				humanoid.WalkSpeed = 16
				print("[SPEED] Velocidade redefinida para o padrão (16).")
			end
		end
	end
end)
