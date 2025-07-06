--!strict
--!optimize 2

local Ragdoll

if game:GetService("RunService"):IsClient() then
	require(script:WaitForChild("client"))
else
	Ragdoll = require(script.Ragdoll)
end

return Ragdoll

