--!strict

export type RigType = "R6" | "R15"

export type RagDoll = {
	enable: (RagDoll, hideFromClient: boolean?) -> (),
	disable: (RagDoll, hideFromClient: boolean?) -> (),
	destroy: (RagDoll) -> (),
	bodyOnDeath: (RagDoll, enabled: boolean, resetTime: number) -> (),

	rigType: RigType,

	new: (rig: Model, rigType: RigType, owner: Player?) -> RagDoll,
	rig: Model,
	
	_motors: { Motor6D },
	_sockets: { BallSocketConstraint },
	_colliders: { Part },
	_humanoid: Humanoid,
	_rootPart: Part,
	_rootFolder: Folder,
	_owner: Player?,
	_lastCFrame: CFrame,
	_isEnabled: boolean,
	_deathCheckConnection: RBXScriptConnection?,
	_healthMonitorConnection: RBXScriptConnection?
}

return 0