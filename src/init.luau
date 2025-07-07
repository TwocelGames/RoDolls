--!strict
--!optimize 2

if game:GetService("RunService"):IsClient() then
	require(script:WaitForChild("client"))
	return (nil:: any):: lib
end

local Schematics = require(script:WaitForChild("schematics"))
local RagDoll = require(script:WaitForChild("Ragdoll"))
local types = require(script:WaitForChild("types"))

type lib = {
	new: (rig: Model, rigType: Schematics.RigTypes, owner: Player?) -> types.RagDoll
}

return {
	new = RagDoll.new
} :: lib



