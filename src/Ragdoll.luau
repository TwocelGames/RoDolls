--!strict
--!optimize 2

local config = require(script.Parent.config)
local types = require(script.Parent.types)

local attachName = config.ATTACHMENT_NAME
local offsetsR6 = config.R6_ATTACHMENT_OFFSETS

local RagDoll: types.RagDoll = {} :: types.RagDoll
RagDoll["__index"] = RagDoll

function RagDoll:enable()
	self._isEnabled = true
	local humanoid = self._humanoid
	local rootPart = self._rootPart
	self._lastCFrame = rootPart.CFrame

	if self._rig.Parent then
		rootPart:SetNetworkOwner(nil)
	end

	humanoid.AutoRotate = false
	humanoid.EvaluateStateMachine = false
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	for _, part in self._colliders do
		part.CanCollide = true
	end

	for _, motor in self._motors do
		motor.Enabled = false
	end

	for _, socket in self._sockets do
		socket.Enabled = true
	end

end

function RagDoll:disable()
	self._isEnabled = false
	local humanoid = self._humanoid

	if self._owner and self._rig.Parent then
		self._rootPart:SetNetworkOwner(self._owner)
	end

	for _, socket in self._sockets do
		socket.Enabled = false
	end

	for _, motor in self._motors do
		motor.Enabled = true
	end

	local lastCFrame = self._lastCFrame
	local newCFrame = CFrame.new(self._rootPart.Position) + Vector3.new(0, humanoid.HipHeight, 0)
	self._rootPart:PivotTo(newCFrame * CFrame.Angles(lastCFrame:ToEulerAnglesXYZ()))

	humanoid:ChangeState(Enum.HumanoidStateType.None)
	humanoid.EvaluateStateMachine = true
	humanoid.AutoRotate = true

	for _, part in self._colliders do
		part.CanCollide = false
	end
end

-- Drop's body on death which is cleanedup after reset time
function RagDoll:bodyOnDeath(enabled, resetTime)
	local humanoid = self._humanoid
	if enabled then
		self._rig.Archivable = true
		self._deathCheckConnection = humanoid.Died:Connect(function()
			if not self._isEnabled then
				self:enable()
			end
			self._humanoid:Destroy()
			local body = self._rig:Clone()
			local humanoid = Instance.new("Humanoid")
			humanoid.RequiresNeck = false
			humanoid.Parent = body
			humanoid.HipHeight = 2
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			self._humanoid = humanoid
			self._rootPart = humanoid.RootPart:: Part
			self._rig:Destroy()
			self._rig = body
			self:enable()
			body.Parent = workspace
			task.delay(resetTime, function()
				body:Destroy()
				self:destroy()
			end)
		end)
	else
		self._rig.Archivable = false
		if self._deathCheckConnection then
			self._deathCheckConnection:Disconnect()
		end
	end
end

function RagDoll:destroy()
	
	if self._isEnabled then
		self:disable()
	end	

	if self._deathCheckConnection then
		self._deathCheckConnection:Disconnect()
	end

	for _, child in self._rig:GetChildren() do

		if not child:IsA("Part") then continue end

		for _, item in child:GetChildren() do
			local name = item.Name
			if name == "RODOLL" or name == attachName then
				item:Destroy()
			end
		end
		
	end

	table.clear(self)
	setmetatable(self, nil)
end

function RagDoll:setNetworkOwner(plr)
	self._owner = plr
end

function RagDoll.new(rig, rigType)
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		error("[RODOLLS][CREATION] invalid rig passed, no humanoid found")
	end

	local humanoidRootPart = rig:FindFirstChild("HumanoidRootPart") :: Part
	if not humanoidRootPart then
		error("[RODOLLS][CREATION] invalid rig passed, no humanoidRootPart found")
	end

	local rootFolder = Instance.new("Folder")
	rootFolder.Name = "RODOLL"
	rootFolder.Parent = humanoidRootPart

	local motors = {}
	local sockets = {}
	local colliders = {}

	for _, descendant in rig:GetDescendants() do
		if descendant:IsA("Motor6D") then
			if descendant.Name == "RootJoint" then
				continue
			end
			table.insert(motors, descendant)
		elseif descendant:IsA("BasePart") then
			if rigType == "R6" then
				local name = descendant.Name
				local attachOffsets = offsetsR6[name]
				if not attachOffsets then
					continue
				end

				local attachment0 = Instance.new("Attachment")
				attachment0.Name = attachName
				attachment0.Parent = humanoidRootPart
				attachment0.CFrame = attachOffsets[1]

				local attachment1 = Instance.new("Attachment")
				attachment1.Name = attachName
				attachment1.Parent = descendant
				attachment1.CFrame = attachOffsets[2]

				local socket = Instance.new("BallSocketConstraint")
				socket.Name = "RODOLL_SOCKET"
				socket.Parent = rootFolder
				socket.Enabled = false
				socket.Attachment0 = attachment0
				socket.Attachment1 = attachment1
				table.insert(sockets, socket)

				local collider = Instance.new("Part")
				collider.Position = descendant.Position
				collider.Parent = rootFolder
				collider.CanCollide = false
				collider.Transparency = 1
				collider.Massless = true
				collider.Size = Vector3.one
				table.insert(colliders, collider)

				local colliderWeld = Instance.new("Weld")
				colliderWeld.Parent = collider
				colliderWeld.Part0 = descendant
				colliderWeld.Part1 = collider
			end
		end
	end

	humanoid.RequiresNeck = false

	local ragDoll: types.RagDoll = setmetatable({}, RagDoll) :: any
	ragDoll._humanoid = humanoid
	ragDoll._rootPart = humanoidRootPart
	ragDoll._rig = rig
	ragDoll._motors = motors
	ragDoll._colliders = colliders
	ragDoll._sockets = sockets

	return ragDoll
end

return table.freeze(RagDoll)
