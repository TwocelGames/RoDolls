--!strict

export type JointType =
	"BallSocketConstraint" |
	"HingeConstraint" |
	"RodConstraint" |
	"SpringConstraint" |
	"PrismaticConstraint" |
	"PlaneConstraint" |
	"CylindricalConstraint" |
	"RopeConstraint" |
	"SlidingBallConstraint" |
	"TwistConstraint" |
	"NoCollisionConstraint" |
	"RigidConstraint"

export type Joint = {
	JointType: JointType,
	Properties: { [string]: any }?
}

export type RigSchematic =  { 
	Joints: { [string]: Joint },
	Colliders: { [string]: Vector3 }
}

export type RagDoll = {

	-- Private Fields
	_owner: Player?,
	_constraints: { Constraint },
	_motors: { Motor6D },
	_humanoid: Humanoid,
	_humanoidRootPart: BasePart,
	_attachments: {Attachment},
	_rootPartDestroyingWatch: RBXScriptConnection?,
	_rigDestroyingWatch: RBXScriptConnection?,
	_humanoidDeathWatch: RBXScriptConnection?,
	_humanoidHealthWatch: RBXScriptConnection?,
	_colliders: { BasePart },
	_lastCFrame: CFrame,
	_isEnabled: boolean,
	_requiresNeckDefault: boolean,
	_evaluateStateMachineDefault: boolean,
	_autoRotateDefault: boolean,
	_rig: Model,

	-- Public Fields
	alive: boolean?,

	-- Methods
	new: (rig: Model, rigType: string?, owner: Player?) -> RagDoll,
	destroy: (RagDoll) -> (),
	enable: (RagDoll) -> (),
	disable: (RagDoll) -> (),
	destroyOnDeath: (RagDoll) -> RagDoll,

}


return 0