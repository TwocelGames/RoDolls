--!strict

export type RigType = "R6" | "R15"

export type RagDoll = {

	enable: (RagDoll) -> (),
	disable: (RagDoll) -> (),
	destroy: (RagDoll) -> (),
	setNetworkOwner: (RagDoll, player: Player) -> (),
	bodyOnDeath: (RagDoll, enabled: boolean, resetTime: number) -> (),

	rigType: RigType,

	new: (rig: Model, rigType: RigType) -> RagDoll,

	_motors: { Motor6D },
	_sockets: { BallSocketConstraint },
	_colliders: { Part },
	_rig: Model,
	_humanoid: Humanoid,
	_rootPart: Part,
	_owner: Player?,
	_lastCFrame: CFrame,
	_isEnabled: boolean,
	_deathCheckConnection: RBXScriptConnection?,
}


return 0