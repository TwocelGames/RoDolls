--!strict
--!optimize 2

local config = require(script.Parent.config)
local types = require(script.Parent.types)
local schematics = require(script.Parent.schematics)

local RagDoll: types.RagDoll = {}:: types.RagDoll
RagDoll["__index"] = RagDoll

function RagDoll:enable()

	-- update Humanoid
	local humanoid = self._humanoid
	humanoid.RequiresNeck = false
	humanoid.AutoRotate = false

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

end

function RagDoll:destroy()

	for _, constraint in self._constraints do
		constraint:Destroy()
	end

	for _, attachment in self._attachments do
		attachment:Destroy()
	end

	self._rootPartDestroyingWatch:Disconnect()
	
	table.clear(self)
	setmetatable(self, nil)
	self = nil:: any
end

function RagDoll.new(rig, rigType, owner)
	local schematic = schematics[rigType]
	assert(schematic, "[RODOLLS][RIG-BUILDER] failed to build rig, no schematic found for given rigType, rigType="..rigType)

	local self: types.RagDoll = setmetatable({}, RagDoll):: any

	-- Verify Rig
	local humanoid = rig:WaitForChild("Humanoid", config.WAITFORCHILD_TIMEOUT):: Humanoid?
	assert(humanoid, "[RODOLLS][RIG-BUILDER] failed to build rig, no humanoid found")
	self._humanoid = humanoid

	local humanoidRootPart = rig:WaitForChild("HumanoidRootPart", config.WAITFORCHILD_TIMEOUT):: BasePart?
	assert(humanoidRootPart, "[RODOLLS][RIG-BUILDER] failed to build rig, no humanoidRootPart found")
	self._humanoidRootPart = humanoidRootPart

	local constraints = {}
	local attachments = {}
	local motors = {}

	local parts = {}
	local usedParts = {}
	local colliders = {}
	local limbs = {}

	-- Find Motors & Store Parts
	for _, descendant in rig:GetDescendants() do
		local name = descendant.Name
		if name == "RootJoint"	 then continue end
		if descendant:IsA("BasePart") then
			parts[name] = descendant
		elseif descendant:IsA("Motor6D") then
			table.insert(motors, descendant)
		end
	end

	-- Build Rig
	for _, constraintSchematic in schematic.Constraints do
		local part0 = parts[constraintSchematic.Part0]
		assert(part0, "[RODOLLS][RIG-BUILDER] failed to build rig, no part0 found for constraint, part0="..constraintSchematic.Part0)
		local part1 = parts[constraintSchematic.Part1]
		assert(part1, "[RODOLLS][RIG-BUILDER] failed to build rig, no part1 found for constraint, part1="..constraintSchematic.Part1)
		

		local constraint = constraintSchematic.constraint:Clone()
		constraint.Name = config.CONSTRAINT_NAME
		constraint.Enabled = false
		constraint.Parent = rig
		table.insert(constraints, constraint)

		local attachment0, attachment1 = Instance.new("Attachment"), Instance.new("Attachment")
		attachment0.Name, attachment1.Name = config.ATTACHMENT_NAME, config.ATTACHMENT_NAME
		attachment0.CFrame, attachment1.CFrame = constraintSchematic.Offset0, constraintSchematic.Offset1
		attachment0.Parent, attachment1.Parent = part0, part1
		table.insert(attachments, attachment0); table.insert(attachments, attachment1)
		constraint.Attachment0, constraint.Attachment1 = attachment0, attachment1
		usedParts[part0], usedParts[part1] = true, true

		if config.DEBUG then
			constraint.Visible = true
			attachment0.Visible = true
			attachment1.Visible = true
		end
	end

	for part, _ in usedParts do
		local collider = Instance.new("Part"):: BasePart
		collider.Name = config.COLLIDER_NAME
		collider.CanCollide = false
		collider.Parent = rig
		collider.Massless = true
		collider.Size = part.Size * schematic.ColliderSize
		table.insert(limbs, part)

		if part.Name == "Head" then
			local specialMesh = part:FindFirstChildOfClass("SpecialMesh")
			if specialMesh then
				local cloneMesh = specialMesh:Clone()
				cloneMesh.Parent = collider
			end
		end

		part.CanCollide = false

		local weld = Instance.new("Weld")
		weld.Name = "RODOLLS_WELD"
		weld.Parent = collider
		weld.Part0 = collider
		weld.Part1 = part

		if config.DEBUG then
			part.Transparency = 0.3
			part.Color = Color3.new(1, 0.070588, 0.070588)
			collider.Color = Color3.new(0.035294, 1, 0)
		else
			collider.Transparency = 1
		end

		table.insert(colliders, collider)
	end

	self._constraints = constraints
	self._attachments = attachments
	self._motors = motors
	self._colliders = colliders

	self._rootPartDestroyingWatch = humanoidRootPart.AncestryChanged:Connect(function()
		if not humanoidRootPart.Parent then
			self:destroy()
		end
	end)

	self._rig = rig
	self._owner = owner
	
	return self
end

return table.freeze(RagDoll)
