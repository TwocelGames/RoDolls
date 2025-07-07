--!strict
--!optimize 2

local types = require(script.Parent.types)

-- Register u rig here by appending to the type RigTypes (Ex ..| "MyCustomRig2" )
export type RigTypes = "R6" | "R15"

local rigid = Instance.new("RigidConstraint")

local ankleJoint = Instance.new("HingeConstraint")
ankleJoint.LimitsEnabled = true
ankleJoint.LowerAngle = -45

local kneeJoint = Instance.new("HingeConstraint")
kneeJoint.LimitsEnabled = true
kneeJoint.LowerAngle = -135
kneeJoint.UpperAngle = -10

local elbowJoint = Instance.new("HingeConstraint")
elbowJoint.LimitsEnabled = true
elbowJoint.UpperAngle = 135

local wristJoint = Instance.new("HingeConstraint")
wristJoint.LimitsEnabled = true
wristJoint.LowerAngle = -20
wristJoint.UpperAngle = 20

local waistJoint = Instance.new("BallSocketConstraint")
waistJoint.LimitsEnabled = true
waistJoint.TwistLimitsEnabled = true
waistJoint.UpperAngle = 15
waistJoint.TwistLowerAngle = -1
waistJoint.TwistUpperAngle = 1

local shoulderJoint = Instance.new("BallSocketConstraint")
shoulderJoint.LimitsEnabled = true
shoulderJoint.TwistLimitsEnabled = true
shoulderJoint.UpperAngle = 30
shoulderJoint.TwistLowerAngle = -30
shoulderJoint.TwistUpperAngle = 30

local neckJoint = Instance.new("BallSocketConstraint")
neckJoint.LimitsEnabled = true
neckJoint.TwistLimitsEnabled = true
neckJoint.UpperAngle = 0
neckJoint.TwistLowerAngle = -40
neckJoint.TwistUpperAngle = 40

local hipJoint = Instance.new("BallSocketConstraint")
hipJoint.LimitsEnabled = true
hipJoint.TwistLimitsEnabled = true
hipJoint.UpperAngle = 40
hipJoint.TwistLowerAngle = -3
hipJoint.TwistUpperAngle = 3

local r6Socket = Instance.new("BallSocketConstraint")
r6Socket.LimitsEnabled = true
r6Socket.TwistLimitsEnabled = true
r6Socket.UpperAngle = 90
r6Socket.TwistLowerAngle = -40
r6Socket.TwistUpperAngle = 40

-- After Registering write a schematic file for that rig the names must match
local Schematics: { [string]: types.RigSchematic } = {

	R6 = {

		Constraints = {
			-- Neck
			{
				constraint = neckJoint,
				Part0 = "Torso",
				Part1 = "Head",
				Offset0 = CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1),
				Offset1 = CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1),
			},

			-- Left Arm to Root
			{
				constraint = r6Socket,
				Part0 = "Torso",
				Part1 = "Left Arm",
				Offset0 = CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
				Offset1 = CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
			},

			-- Right Arm to Root
			{
				constraint = r6Socket,
				Part0 = "Torso",
				Part1 = "Right Arm",
				Offset0 = CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Offset1 = CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			},

			-- Left Leg to Root
			{
				constraint = r6Socket,
				Part0 = "Torso",
				Part1 = "Left Leg",
				Offset0 = CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
				Offset1 = CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
			},

			-- Right Leg to Root
			{
				constraint = r6Socket,
				Part0 = "Torso",
				Part1 = "Right Leg",
				Offset0 = CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
				Offset1 = CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
			},

			{
				constraint = rigid,
				Part0 = "HumanoidRootPart",
				Part1 = "Torso",
				Offset0 = CFrame.new(),
				Offset1 = CFrame.new(),
			},
		},

		ColliderSize = Vector3.new(0.75, 0.75, 0.75),
	},

	R15 = {

		Constraints = {
			-- Neck
			{
				constraint = neckJoint,
				Part0 = "UpperTorso",
				Part1 = "Head",
				Offset0 = CFrame.new(-0, 0.8, 0),
				Offset1 = CFrame.new(0, -0.5, -0),
			},

			-- Left Shoulder
			{
				constraint = shoulderJoint,
				Part0 = "UpperTorso",
				Part1 = "LeftUpperArm",
				Offset0 = CFrame.new(-1, 0.563, 0),
				Offset1 = CFrame.new(0.5, 0.394, 0),
			},

			-- Right Shoulder
			{
				constraint = shoulderJoint,
				Part0 = "UpperTorso",
				Part1 = "RightUpperArm",
				Offset0 = CFrame.new(1, 0.563, 0),
				Offset1 = CFrame.new(-0.5, 0.394, 0),
			},

			-- Left Elbow
			{
				constraint = elbowJoint,
				Part0 = "LeftUpperArm",
				Part1 = "LeftLowerArm",
				Offset0 = CFrame.new(0, -0.334, 0),
				Offset1 = CFrame.new(0, 0.259, 0),
			},

			-- Right Elbow
			{
				constraint = elbowJoint,
				Part0 = "RightUpperArm",
				Part1 = "RightLowerArm",
				Offset0 = CFrame.new(-0, -0.334, 0),
				Offset1 = CFrame.new(0, 0.259, 0),
			},

			-- Left Wrist
			{
				constraint = wristJoint,
				Part0 = "LeftLowerArm",
				Part1 = "LeftHand",
				Offset0 = CFrame.new(0, -0.501, 0),
				Offset1 = CFrame.new(0, 0.125, 0),
			},

			-- Right Wrist
			{
				constraint = wristJoint,
				Part0 = "RightLowerArm",
				Part1 = "RightHand",
				Offset0 = CFrame.new(0, -0.501, -0),
				Offset1 = CFrame.new(0, 0.125, 0),
			},

			-- Root
			{
				constraint = rigid,
				Part0 = "HumanoidRootPart",
				Part1 = "LowerTorso",
				Offset0 = CFrame.new(0, -1, 0),
				Offset1 = CFrame.new(-0, -0.2, 0),
			},

			-- Waist
			{
				constraint = waistJoint,
				Part0 = "LowerTorso",
				Part1 = "UpperTorso",
				Offset0 = CFrame.new(-0, 0.2, 0),
				Offset1 = CFrame.new(-0, -0.8, 0),
			},

			-- Left Hip
			{
				constraint = hipJoint,
				Part0 = "LowerTorso",
				Part1 = "LeftUpperLeg",
				Offset0 = CFrame.new(-0.5, -0.2, 0),
				Offset1 = CFrame.new(0, 0.421, -0),
			},

			-- Right Hip
			{
				constraint = hipJoint,
				Part0 = "LowerTorso",
				Part1 = "RightUpperLeg",
				Offset0 = CFrame.new(0.5, -0.2, -0),
				Offset1 = CFrame.new(0, 0.421, -0),
			},

			-- Left Knee
			{
				constraint = kneeJoint,
				Part0 = "LeftUpperLeg",
				Part1 = "LeftLowerLeg",
				Offset0 = CFrame.new(0, -0.401, -0),
				Offset1 = CFrame.new(0, 0.379, -0),
			},

			-- Right Knee
			{
				constraint = kneeJoint,
				Part0 = "RightUpperLeg",
				Part1 = "RightLowerLeg",
				Offset0 = CFrame.new(0, -0.401, -0),
				Offset1 = CFrame.new(0, 0.379, 0),
			},

			-- Left Ankle
			{
				constraint = ankleJoint,
				Part0 = "LeftLowerLeg",
				Part1 = "LeftFoot",
				Offset0 = CFrame.new(-0, -0.547, -0),
				Offset1 = CFrame.new(-0, 0.102, -0),
			},

			-- Right Ankle
			{
				constraint = ankleJoint,
				Part0 = "RightLowerLeg",
				Part1 = "RightFoot",
				Offset0 = CFrame.new(0, -0.547, 0),
				Offset1 = CFrame.new(0, 0.102, 0),
			},
		},

		ColliderSize = Vector3.new(0.7, 0.25, 0.7),
	},
}

export type Schematics = typeof(Schematics)

return table.freeze(Schematics) :: Schematics
