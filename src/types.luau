--!strict

export type ConstraintSchematic = {
	Part0: string,
	Part1: string,
	Offset0: CFrame,
	Offset1: CFrame,
	constraint: Constraint,
}

export type RigSchematic =  { 
	Constraints: { ConstraintSchematic },
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
	new: (rig: Model, schematic: string, owner: Player?) -> RagDoll,
	destroy: (RagDoll) -> (),
	enable: (RagDoll) -> (),
	disable: (RagDoll) -> (),

}


return 0