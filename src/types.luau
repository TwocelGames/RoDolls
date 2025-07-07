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
	ColliderSize: Vector3,
}

export type RagDoll = {

	-- Private Fields
	_owner: Player?,
	_constraints: { Constraint },
	_motors: { Motor6D },
	_humanoid: Humanoid,
	_humanoidRootPart: BasePart,
	_attachments: {Attachment},
	_rootPartDestroyingWatch: RBXScriptConnection,
	_colliders: { BasePart },

	-- Public Fields
	_rig: Model,

	-- Methods
	new: (rig: Model, rigType: string?, owner: Player?) -> RagDoll,
	destroy: (RagDoll) -> (),
	enable: (RagDoll) -> (),
	disable: (RagDoll) -> (),

}


return 0