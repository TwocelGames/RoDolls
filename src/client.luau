--!strict
--!optimize 2

-- This script sends a msg to the server when the health reaches 0 while the player's character is ragdolled
-- because when ragdolled humanoid state is set to physics which means the client can't switch to dead (only humanoid states replicated from client -> server)

local Players = game:GetService("Players")
local config = require(script.Parent:WaitForChild("config"))

local networkHook: RemoteEvent = (config.NETWORK_HOOK:: any):: RemoteEvent
if not networkHook.OnClientEvent or not networkHook.OnClientEvent.Connect then
	error("[RODOLLS][CONFIG] invalid network hook, invalid OnClientEvent")
end
if not networkHook.FireServer then
	error("[RODOLLS][CONFIG] invalid network hook, invalid FireServer")
end

local player = Players.LocalPlayer
local connection: RBXScriptConnection?

local function watch(char: Model)
	if connection then
		connection:Disconnect()
	end

	local humanoid = char:WaitForChild("Humanoid"):: Humanoid
	connection = humanoid.HealthChanged:Connect(function(health)
		if health <= 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			networkHook:FireServer()
		end
	end)
end

player.CharacterAdded:Connect(watch)

if player.Character then
	watch(player.Character)
end

print('Required')

return 0