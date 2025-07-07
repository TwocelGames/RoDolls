--!strict
--!optimize 2

local config = require(script.Parent.config)
local types = require(script.Parent.types)
local schematics = require(script.Parent.schematics)

local RagDoll: types.RagDoll = {} :: types.RagDoll
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

	for _, collider in self._colliders do
		collider:Destroy()
	end

	self._rootPartDestroyingWatch:Disconnect()
	
	table.clear(self)
	setmetatable(self, nil)
	self = nil :: any
end

function RagDoll.new(rig, rt, owner)

	local rigType = rt or "AUTO"

	local self: types.RagDoll = setmetatable({}, RagDoll) :: any

	-- Verify Rig
	local humanoid = rig:WaitForChild("Humanoid", config.WAITFORCHILD_TIMEOUT) :: Humanoid?
	assert(humanoid, "[RODOLLS][RIG-BUILDER] failed to build rig, no humanoid found")
	self._humanoid = humanoid
	
	local schematic = rigType == "AUTO" and schematics[humanoid.RigType.Name] or schematics[rigType]
	assert(schematic, "[RODOLLS][RIG-BUILDER] failed to build rig, no schematic found for given rigType, rigType=" .. rigType)

	local humanoidRootPart = rig:WaitForChild("HumanoidRootPart", config.WAITFORCHILD_TIMEOUT) :: BasePart?
	assert(humanoidRootPart, "[RODOLLS][RIG-BUILDER] failed to build rig, no humanoidRootPart found")
	self._humanoidRootPart = humanoidRootPart

	local constraints = {}
	local attachments = {}
	local motors = {}

	local colliders = {}

	-- Find Motors & Store Parts
	local joints = schematic.Joints

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
					if (constraint:: any)[name] ~= nil then
						(constraint:: any)[name] = value
					else
						warn("[RODOLLS][RIG-BUILDER] invalid joint property, give jointType doesn't have the property=", name, "joint=", joint)
					end
				end
			end

			table.insert(constraints, constraint)
		elseif descendant:IsA("BasePart") then
			
			local collider = Instance.new("Part") :: BasePart
			collider.Name = config.COLLIDER_NAME
			collider.CanCollide = false
			collider.Parent = rig
			collider.Massless = true
			collider.Size = descendant.Size * schematic.ColliderSize

			if descendant.Name == "Head" then
				local specialMesh = descendant:FindFirstChildOfClass("SpecialMesh")
				if specialMesh then
					local cloneMesh = specialMesh:Clone()
					cloneMesh.Parent = collider
				end
			end

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
