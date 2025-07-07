--!strict
return table.freeze{

	-- Must be a instance/object with a property called .OnServerEvent( must contain :Connect() which takes (player) -> () ) 
	-- and a method called :FireServer() basically a copy of remoteEvent. use this to implement with custom networking libs
	NETWORK_HOOK = script.Parent:WaitForChild("Remote"),

	WAITFORCHILD_TIMEOUT = 1,

	ATTACHMENT_NAME = "RODOLLS_ATTACHMENT",
	CONSTRAINT_NAME = "RODOLLS_CONSTRAINT",
	COLLIDER_NAME = "RODOLLS_COLLIDER",

	DEBUG = false
}
