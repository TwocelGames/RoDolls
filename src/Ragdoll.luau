--!strict
--!optimize 2

local config = require(script.Parent.config)
local types = require(script.Parent.types)

local attachName = config.ATTACHMENT_NAME
local offsetsR6 = config.R6_ATTACHMENT_OFFSETS

local networkHook: RemoteEvent = (config.NETWORK_HOOK:: any):: RemoteEvent
if not networkHook.OnServerEvent or not networkHook.OnServerEvent.Connect then
	error("[RODOLLS][CONFIG] invalid network hook, invalid OnServerEvent")
end
if not networkHook.FireClient then
	error("[RODOLLS][CONFIG] invalid network hook, invalid FireServer")
end

local rigToRagDoll = {}

local RagDoll: types.RagDoll = {} :: types.RagDoll
RagDoll["__index"] = RagDoll

function RagDoll:enable(hideFromClient)
	if self._isEnabled then
		return
	end
	local humanoid = self._humanoid
	local rootPart = self._rootPart
	self._lastCFrame = rootPart.CFrame


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

	if self._owner and not hideFromClient  then
		networkHook:FireClient(self._owner, true)
	end

	-- needed because humanoid cannot exit physics state automatically when health is set to 0
	self._healthMonitorConnection = humanoid.HealthChanged:Connect(function()
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end)

	self._isEnabled = true
end

function RagDoll:disable(hideFromClient)
	if not self._isEnabled then
		return
	end

	local humanoid = self._humanoid
	local rootPart = self._rootPart

	for _, socket in self._sockets do
		socket.Enabled = false
	end

	for _, motor in self._motors do
		motor.Enabled = true
	end

	for _, part in self._colliders do
		part.CanCollide = false
	end

	local lastCFrame = self._lastCFrame
	local newCFrame = CFrame.new(rootPart.Position + Vector3.yAxis * humanoid.HipHeight)

	local _, y, _ = lastCFrame:ToEulerAnglesXYZ()
	rootPart:PivotTo(newCFrame * CFrame.Angles(0, y, 0))

	humanoid:ChangeState(Enum.HumanoidStateType.None)
	humanoid.EvaluateStateMachine = true
	humanoid.AutoRotate = true

	if self._owner and not hideFromClient then
		networkHook:FireClient(self._owner, false)
	end
	
	if self._healthMonitorConnection then
		self._healthMonitorConnection:Disconnect()
	end

	self._isEnabled = false
end

-- Drop's body on death which is cleanedup after reset time
function RagDoll:bodyOnDeath(enabled, bodyLifetime)
	local humanoid = self._humanoid
	if enabled then
		self.rig.Archivable = true
		self._deathCheckConnection = humanoid.Died:Connect(function()
			-- we enable ragdoll and clone the rig in that state (this is to ensure if rig = player character it doesn't get destroyed before the lifetime)
			self:enable(true)
			self._humanoid:Destroy()
			local body = self.rig:Clone()
			self.rig:Destroy()

			-- we have to make new humanoid otherwise the new rig will have state = dead which will not allow us to change state to physics
			local humanoid = Instance.new("Humanoid")
			humanoid.RequiresNeck = false
			humanoid.Parent = body
			humanoid.HipHeight = 2
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		
			humanoid.EvaluateStateMachine = false
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)

			body.Parent = workspace

			-- we know the orginal rig is destroyed so no point in renabling motors so we just destroy the ragdoll in enabled state
			self._isEnabled = false
			self:destroy()

			task.delay(bodyLifetime, function()
				body:Destroy()
			end)
		end)
	else
		self.rig.Archivable = false
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

	if self.rig then
		rigToRagDoll[self.rig] = nil
		for _, child in self.rig:GetChildren() do
			if not child:IsA("Part") then
				continue
			end

			for _, item in child:GetChildren() do
				local name = item.Name
				if name == "RODOLL" or name == attachName then
					item:Destroy()
				end
			end
		end
	end
	
	table.clear(self)
	setmetatable(self, nil)
end

function RagDoll.new(rig, rigType, owner)

	if rigToRagDoll[rig] then
		return rigToRagDoll[rig]
	end

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
	ragDoll.rig = rig
	ragDoll._motors = motors
	ragDoll._colliders = colliders
	ragDoll._sockets = sockets
	ragDoll._owner = owner
	ragDoll._rootFolder = rootFolder

	rigToRagDoll[rig] = ragDoll

	return ragDoll
end

networkHook.OnServerEvent:Connect(function(player)
	local char = player.Character 
	if not char then return end
	local ragDoll = rigToRagDoll[char]
	if not ragDoll then return end
	if ragDoll._isEnabled then
		ragDoll._humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
end)

return table.freeze(RagDoll)
