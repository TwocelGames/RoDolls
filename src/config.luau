--!strict

return table.freeze{

	-- The offset of the attachments used in sockets (by removing a part from here you can make that part not ragdoll)
	R6_ATTACHMENT_OFFSETS = {
		Head = {
			CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1),
		},
		HumanoidRootPart = {
			CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		},
		["Right Arm"] = {
			CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		},
		["Left Arm"] = {
			CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
		},
		["Right Leg"] = {
			CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		},
		["Left Leg"] = {
			CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		},
	},

	ATTACHMENT_NAME = "RODOLLS_ATTACHMENTS",



}
