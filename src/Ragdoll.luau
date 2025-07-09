--!strict
--!optimize 2

local config = require(script.Parent.config)
local types = require(script.Parent.types)
local schematics = require(script.Parent.schematics)
local networkHook = config.NETWORK_HOOK:: RemoteEvent
if not networkHook.OnServerEvent or not networkHook.OnServerEvent.Connect then
	error("[RODOLLS][CONFIG] invalid network hook, invalid OnServerEvent")
end

local rigToRagdoll = {}

local RagDoll: types.RagDoll = {} :: types.RagDoll
RagDoll["__index"] = RagDoll

function RagDoll:enable()
	if self._isEnabled then
		return
	end

	local humanoid = self._humanoid

	-- save humanoid
	self._autoRotateDefault = humanoid.AutoRotate
	self._requiresNeckDefault = humanoid.RequiresNeck
	self._evaluateStateMachineDefault = humanoid.EvaluateStateMachine

	-- update Humanoid
	humanoid.RequiresNeck = false
	humanoid.AutoRotate = false
	local humanoidRootPart = self._humanoidRootPart

	humanoidRootPart.CanCollide = false
	if self._rig.Parent == workspace then
		humanoidRootPart:SetNetworkOwner(nil)
	end

	self._lastCFrame = humanoidRootPart.CFrame

	-- Disable motors
	for _, motor in self._motors do
		motor.Enabled = false
	end

	-- Enable collisions
	for _, collider in self._colliders do
		collider.CanCollide = true
	end

	-- Enable Constraints
	for _, constraint in self._constraints do
		constraint.Enabled = true
	end

	-- update state
	humanoid.EvaluateStateMachine = false
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	if not self._humanoidDeathWatch then
		self._humanoidDeathWatch = humanoid.HealthChanged:Connect(function(health)
			if health <= 0 then
				humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			end
		end)
	end

	self._isEnabled = true
end

function RagDoll:disable()
	if not self._isEnabled then
		return
	end

	local humanoid = self._humanoid
	local humanoidRootPart = self._humanoidRootPart

	-- Enable motors
	for _, motor in self._motors do
		motor.Enabled = true
	end

	-- Disable collisions
	for _, collider in self._colliders do
		collider.CanCollide = false
	end

	-- Disable Constraints
	for _, constraint in self._constraints do
		constraint.Enabled = false
	end

	-- Position Rig
	local lastCFrame = self._lastCFrame
	local newCFrame = CFrame.new(humanoidRootPart.Position + Vector3.yAxis * humanoid.HipHeight)
	local _, y, _ = lastCFrame:ToEulerAnglesXYZ()
	humanoidRootPart:PivotTo(newCFrame * CFrame.Angles(0, y, 0))

	-- Reset Humanoid
	humanoid.RequiresNeck = self._requiresNeckDefault
	humanoid.AutoRotate = self._autoRotateDefault
	humanoid:ChangeState(Enum.HumanoidStateType.None)
	humanoid.EvaluateStateMachine = self._evaluateStateMachineDefault

	if self._rig.Parent == workspace then
		humanoidRootPart:SetNetworkOwnershipAuto()
	end

	if self._humanoidHealthWatch then
		self._humanoidHealthWatch:Disconnect()
	end

	self._isEnabled = false
end

function RagDoll:destroyOnDeath()
	local rig = self._rig
	local humanoidRootPart = self._humanoidRootPart

	self._rootPartDestroyingWatch = humanoidRootPart.AncestryChanged:Connect(function()
		if not humanoidRootPart.Parent then
			self:destroy()
		end
	end)

	self._rigDestroyingWatch = rig.AncestryChanged:Connect(function()
		if not rig.Parent then
			self:destroy()
		end
	end)

	self._humanoidDeathWatch = self._humanoid.Died:Connect(function(health)
		self:destroy()
	end)

	return self
end

function RagDoll:destroy()
	self:disable()

	for _, constraint in self._constraints do
		constraint:Destroy()
	end

	for _, attachment in self._attachments do
		attachment:Destroy()
	end

	for _, collider in self._colliders do
		collider:Destroy()
	end

	if self._rootPartDestroyingWatch then
		self._rootPartDestroyingWatch:Disconnect()
	end

	if self._rigDestroyingWatch then
		self._rigDestroyingWatch:Disconnect()
	end

	if self._humanoidDeathWatch then
		self._humanoidDeathWatch:Disconnect()
	end

	self._rig = nil :: any
	table.clear(self)
	setmetatable(self, nil)
	table.freeze(self)
end

function RagDoll.new(rig, rt, owner)

	if rigToRagdoll[rig] then
		return rigToRagdoll[rig]
	end

	local rigType = rt or "AUTO"

	local self: types.RagDoll = setmetatable({}, RagDoll) :: any

	-- Verify Rig
	local humanoid = rig:WaitForChild("Humanoid", config.WAITFORCHILD_TIMEOUT) :: Humanoid?
	assert(humanoid, "[RODOLLS][RIG-BUILDER] failed to build rig, no humanoid found")
	self._humanoid = humanoid

	local schematic = rigType == "AUTO" and schematics[humanoid.RigType.Name] or schematics[rigType]
	assert(
		schematic,
		"[RODOLLS][RIG-BUILDER] failed to build rig, no schematic found for given rigType, rigType=" .. rigType
	)

	local humanoidRootPart = rig:WaitForChild("HumanoidRootPart", config.WAITFORCHILD_TIMEOUT) :: BasePart?
	assert(humanoidRootPart, "[RODOLLS][RIG-BUILDER] failed to build rig, no humanoidRootPart found")
	self._humanoidRootPart = humanoidRootPart

	local constraints = {}
	local attachments = {}
	local motors = {}

	local colliders = {}

	-- Find Motors & Store Parts
	local joints = schematic.Joints
	local colliderMap = schematic.Colliders

	for _, descendant in rig:GetDescendants() do
		if descendant:IsA("Motor6D") then
			local jointName = descendant.Name
			local joint = joints[jointName]

			if not joint then
				warn("[RODOLLS][RIG-BUILDER] missing joint for motor, no joint found for motor=", descendant)
				continue
			end

			table.insert(motors, descendant)

			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.CFrame, a1.CFrame = descendant.C0, descendant.C1
			a0.Name, a1.Name = config.ATTACHMENT_NAME, config.ATTACHMENT_NAME
			a0.Parent, a1.Parent = descendant.Part0, descendant.Part1

			local constraint = Instance.new(joint.JointType) :: Constraint
			constraint.Attachment0, constraint.Attachment1 = a0, a1
			constraint.Enabled = false
			constraint.Parent = rig

			if joint.Properties then
				for name, value in joint.Properties do
					if (constraint :: any)[name] ~= nil then
						(constraint :: any)[name] = value
					else
						warn(
							"[RODOLLS][RIG-BUILDER] invalid joint property, give jointType doesn't have the property=",
							name,
							"joint=",
							joint
						)
					end
				end
			end

			table.insert(constraints, constraint)
		elseif descendant:IsA("BasePart") then
			local name = descendant.Name
			local scale = colliderMap[name]
			if not scale then
				continue
			end

			local collider = descendant:Clone()
			collider:ClearAllChildren()
			collider.Name = config.COLLIDER_NAME
			collider.CanCollide = false
			collider.Parent = descendant
			collider.Size = descendant.Size * scale

			descendant.CanCollide = false

			local weld = Instance.new("Weld")
			weld.Name = "RODOLLS_WELD"
			weld.Parent = collider
			weld.Part0 = collider
			weld.Part1 = descendant

			if config.DEBUG then
				descendant.Transparency = 0.3
				descendant.Color = Color3.new(1, 0.070588, 0.070588)
				collider.Color = Color3.new(0.035294, 1, 0)
			else
				collider.Transparency = 1
			end

			table.insert(colliders, collider)
		end
	end

	self._constraints = constraints
	self._attachments = attachments
	self._motors = motors
	self._colliders = colliders
	self._rig = rig
	self._owner = owner	
	self._lastCFrame = humanoidRootPart.CFrame
	self._autoRotateDefault = humanoid.AutoRotate
	self._requiresNeckDefault = humanoid.RequiresNeck
	self._evaluateStateMachineDefault = humanoid.EvaluateStateMachine
	
	humanoidRootPart.CanCollide = true
	self.alive = true

	rigToRagdoll[rig] = self

	return self
end

-- this allows for players to reset thier own character (the roblox reset button only updates health on client and it hopes for the state change to dead to replicate to the server
-- but our lib blocks that by putting the humanoid state to physics which is not exitable internally)
networkHook.OnServerEvent:Connect(function(player)
	if not player.Character then return end
	local ragDoll = rigToRagdoll[player.Character]
	if ragDoll._isEnabled then
		ragDoll._humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
end)

return table.freeze(RagDoll)
