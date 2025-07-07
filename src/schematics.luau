--!strict
--!optimize 2

local types = require(script.Parent.types)

-- Register u rig here by appending to the type RigTypes (Ex ..| "MyCustomRig2" )
export type RigTypes = "AUTO" | "R6" | "R15"

-- ===== Joint Presets =====

local R6SOCKET: types.Joint = {
	JointType = "BallSocketConstraint",
	Properties = {
		LimitsEnabled = true,
		TwistLimitsEnabled = true,
		UpperAngle = 30,
		TwistLowerAngle = -30,
		TwistUpperAngle = 30,
	},
}

local NECK: types.Joint = {
	JointType = "BallSocketConstraint",
	Properties = {
		LimitsEnabled = true,
		TwistLimitsEnabled = true,
		UpperAngle = 0,
		TwistLowerAngle = -40,
		TwistUpperAngle = 40,
	},
}

local WAIST: types.Joint = {
	JointType = "BallSocketConstraint",
	Properties = {
		LimitsEnabled = true,
		TwistLimitsEnabled = true,
		UpperAngle = 15,
		TwistLowerAngle = -1,
		TwistUpperAngle = 1,
	},
}

local HIP: types.Joint = {
	JointType = "BallSocketConstraint",
	Properties = {
		LimitsEnabled = true,
		TwistLimitsEnabled = true,
		UpperAngle = 40,
		TwistLowerAngle = -3,
		TwistUpperAngle = 3,
	},
}

local ELBOW: types.Joint = {
	JointType = "HingeConstraint",
	Properties = {
		LimitsEnabled = true,
		UpperAngle = 135,
	},
}

local WRIST: types.Joint = {
	JointType = "HingeConstraint",
	Properties = {
		LimitsEnabled = true,
		LowerAngle = -20,
		UpperAngle = 20,
	},
}

local KNEE: types.Joint = {
	JointType = "HingeConstraint",
	Properties = {
		LimitsEnabled = true,
		LowerAngle = -135,
		UpperAngle = -10,
	},
}

local ANKLE: types.Joint = {
	JointType = "HingeConstraint",
	Properties = {
		LimitsEnabled = true,
		LowerAngle = -45,
	},
}

local ROOT: types.Joint = {
	JointType = "RigidConstraint"
}

-- ===== Schematics Table =====

local Schematics: { [string]: types.RigSchematic } = {

	R6 = {
		Joints = {
			["Right Shoulder"] = R6SOCKET,
			["Left Shoulder"] = R6SOCKET,
			["Right Hip"] = R6SOCKET,
			["Left Hip"] = R6SOCKET,
			["Neck"] = NECK,
			["RootJoint"] = ROOT,
		},

		ColliderSize = Vector3.new(0.75, 0.75, 0.75),
	},

	R15 = {
		Joints = {
			["Neck"] = NECK,
			["Waist"] = WAIST,

			["LeftShoulder"] = R6SOCKET,
			["RightShoulder"] = R6SOCKET,

			["LeftElbow"] = ELBOW,
			["RightElbow"] = ELBOW,

			["LeftWrist"] = WRIST,
			["RightWrist"] = WRIST,

			["LeftHip"] = HIP,
			["RightHip"] = HIP,

			["LeftKnee"] = KNEE,
			["RightKnee"] = KNEE,

			["LeftAnkle"] = ANKLE,
			["RightAnkle"] = ANKLE,

			["Root"] = ROOT
		},

		ColliderSize = Vector3.new(0.7, 0.25, 0.7),
	},
}

export type Schematics = typeof(Schematics)

return table.freeze(Schematics) :: Schematics
