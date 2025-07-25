-- This Module is the actual thing that makes the Ragdoll happen. Dont edit it unless you know what your doing.
-- Motor6Ds are the things that hold your Characters limbs Together. Without them you would be a pile of parts on the ground
-- BallSocketConstraints are the things that allows Parts to flop around. With them you can Ragdoll or flop around if you allow it.
-- Humanoid is the thing the defines a Model of a character from a Actaual Character. Without it you wouldnt be a Character but just a model.
-- Note that char is still a Model but has a Humanoid to make it a Character.
-- Only works on R6. Recommended to use a StartCharacter or switch game RigType to R6 if possible.
--[[
Copy the Code in here then paste it into a ModuleScript Named "RagdollService" into ReplicatedStorage.
Updated 2: Made legs not as broken and added new function RagDollService:DebrisRagDoll()
Updated 3: Added 2 functions. RagDollService:EnableRagDoll and RagDollService:DisableRagDoll. Does what they say.
Update 4: Added 2 Force applying functions. (RagDollService:ForceApplyRagDollWait() and RagDollService:ForceApplyRagDoll())
]]
local RagDollService = {}
-- Use this if your using a custom rig. A function that allows the user to create custom hitboxs for Ragdolls incase the user is making a custom rig.
function RagDollService:CustomBuildCollision(char: Model, PartToCopyFrom: BasePart, BuiltCollisionSize: BasePart)
	local BuiltCollision = Instance.new("Part", PartToCopyFrom)
	BuiltCollision.Size = BuiltCollisionSize
	BuiltCollision.Transparency = 1
	BuiltCollision.Position = PartToCopyFrom.Position
	BuiltCollision.Rotation = PartToCopyFrom.Rotation
	BuiltCollision.Name = "BuiltCollison"
	local WeldedCollision = Instance.new("WeldConstraint", BuiltCollision)
	WeldedCollision.Part0 = PartToCopyFrom
	WeldedCollision.Part1 = BuiltCollision
end
-- Builds the collision for each given part due to BallSocketContrsaints not having built in Collision.
function RagDollService:BuildCollision(PartToAttach: BasePart)
	-- The block for collision
	local BuiltCollision = Instance.new("Part", PartToAttach)
	BuiltCollision.Size = Vector3.new(1,1,1)
	BuiltCollision.Transparency = 1
	BuiltCollision.Position = PartToAttach.Position
	BuiltCollision.Rotation = PartToAttach.Rotation
	BuiltCollision.Name = "BuiltCollison"
	local WeldedCollision = Instance.new("WeldConstraint", BuiltCollision)
	WeldedCollision.Part0 = PartToAttach
	WeldedCollision.Part1 = BuiltCollision
	-- Big check to make sure each Cillision parts matchs CLOSELY to the limbs size and rotation that i dont wanna clean up
	if PartToAttach.Name == "Torso" then
		BuiltCollision.Size = Vector3.new(2,1,2)
	elseif PartToAttach.Name == "Left Leg" then
		BuiltCollision.Size = Vector3.new(1,1.5,1)
		BuiltCollision.Position -= Vector3.new(0,0.25,0)
	elseif PartToAttach.Name == "Right Leg" then
		BuiltCollision.Size = Vector3.new(1,1.5,1)
		BuiltCollision.Position -= Vector3.new(0,0.25,0)
	elseif PartToAttach.Name == "Head" then
		BuiltCollision.Size = Vector3.new(1,1,1)
		local Specialmesh = Instance.new("SpecialMesh", BuiltCollision)
		Specialmesh.MeshType = Enum.MeshType.Head
	elseif PartToAttach.Name == "Right Arm" then
		BuiltCollision.Size = Vector3.new(0.5,1.5,0.5)
		BuiltCollision.Position -= Vector3.new(0,0.25,0)
	elseif PartToAttach.Name == "Left Arm" then
		BuiltCollision.Size = Vector3.new(0.5,1.5,0.5)
		BuiltCollision.Position -= Vector3.new(0,0.25,0)
	end
end
-- Switchs all Motor6Ds into BallSocketContrsaints. (Removes all Motor6DS that Cant flop around into BallSockets that Can flop around.)
function RagDollService:SwitchedRigsBallSocketContrsaint(char: Model)
	-- Runs through a loop of all Parts inside the character for the Ragdoll
	for _, v in pairs(char:GetDescendants()) do
		local player = game.Players:GetPlayerFromCharacter(char)
		if player then
			player.RigMode.Value = "RagDolled"
		end
		-- Defines if the v Is the Humanoid
		if v:IsA("Humanoid") then
			for i = 1,5 do
				-- Sets Ragdoll
				v.PlatformStand = true
				v.RequiresNeck = false
				v.BreakJointsOnDeath = false
				v.AutoRotate = false
				if v.PlatformStand == true then break end
				task.wait(0.5)
			end
		end
		-- Defines if it is a Motor6D
		if v:IsA("Motor6D") then
			-- Check to make sure not to destroy the RootJoint
			if v.Name ~= "RootJoint" then
				local A0 = Instance.new("Attachment")
				local A1 = Instance.new("Attachment")
				A0.CFrame = v.C0
				A1.CFrame = v.C1
				A0.Parent = v.Part0
				A1.Parent = v.Part1
				local ballS = Instance.new("BallSocketConstraint")
				ballS.Name = v.Name
				ballS.Attachment0 = A0
				ballS.Attachment1 = A1
				ballS.Parent = v.Part1
				if ballS.Name == "Left Hip" or ballS.Name == "Right Hip" then
					ballS.LimitsEnabled = true
					ballS.TwistLimitsEnabled = true
				elseif ballS.Name == "Neck" then
					ballS.LimitsEnabled = true
				end
				v:Destroy()
			end
		end
	end
end
-- Switchs all BallSocketContrsaints into Motor6Ds (Removes all BallSockets that Can flop but dont allow movementinto Motor6Ds that cant flop but allow movement.)
function RagDollService:SwitchedRigsMotor6D(char: Model)
	-- Runs through the loop of the character for unRagdoll
	for _, v in ipairs(char:GetDescendants()) do
		-- Gets players Current Rig Mode (A String value that determines if theyre in Ragdoll or Not)
		local player = game.Players:GetPlayerFromCharacter(char)
		if player then
			player.RigMode.Value = "Motor6D"
		end
		-- Defines v as a Humanoid for the unragdoll
		if v:IsA("Humanoid") then
			v.PlatformStand = false
			v.RequiresNeck = true
			v.AutoRotate = true
		end
		-- Defines if v as a BallSocketConstraint for unragdoll
		if v:IsA("BallSocketConstraint") then
			local Motor6D = Instance.new("Motor6D")
			Motor6D.Name = v.Name
			Motor6D.Part0 = v.Attachment0.Parent
			Motor6D.Part1 = v.Attachment1.Parent
			Motor6D.C0 = v.Attachment0.CFrame
			Motor6D.C1 = v.Attachment1.CFrame
			Motor6D.Parent = v.Attachment1.Parent  
			v:Destroy()
			v.Attachment0:Destroy()
			v.Attachment1:Destroy()
		end
	end
end
-- Removes all Collosion Parts for the character that was made for the Ragdoll
function RagDollService:RemoveCollisionRagDoll(char: Model)
	-- Runs through the loop and checks for each built collision part that was made before and destroys it to return to UnRagdoll
	for i, v in ipairs(char:GetDescendants()) do
		if v.Name == "BuiltCollison" then
			v:Destroy()
		end
		if v.Name == "Head" then
			for ii, vv in ipairs(v:GetDescendants()) do
				if vv.Name == "BuiltCollison" then
					vv:Destroy()
				end
			end
		end
	end
end
-- Acts as a custom Debris service function but instead of Turning on it does Ragdoll then Uses "Time" Variable for how long to wait until UnRagDolling.
function RagDollService:DebrisRagDoll(char: Model, Time: number)
	-- Simulates the Debris service with a time to wait until undoing Ragdoll
	RagDollService:BuildCollision(char["Right Arm"])
	RagDollService:BuildCollision(char["Left Arm"])
	RagDollService:BuildCollision(char["Left Leg"])
	RagDollService:BuildCollision(char["Right Leg"])
	RagDollService:BuildCollision(char.Head)
	RagDollService:SwitchedRigsBallSocketContrsaint(char)
	task.wait(Time)
	RagDollService:RemoveCollisionRagDoll(char)
	RagDollService:SwitchedRigsMotor6D(char)
end
-- Does all the collision building and Switched for you instead of doing Writing the functions this Service provides. Dont use if your using a custom rig
function RagDollService:EnableRagDoll(char: Model)
	-- Turns on Ragdoll
	if char then
		RagDollService:BuildCollision(char["Right Arm"])
		RagDollService:BuildCollision(char["Left Arm"])
		RagDollService:BuildCollision(char["Left Leg"])
		RagDollService:BuildCollision(char["Right Leg"])
		RagDollService:BuildCollision(char.Head)
		RagDollService:SwitchedRigsBallSocketContrsaint(char)
	end
end
-- Does all the disabling RagDoll for you instead of Writing out  the function this Service provides. dont use if your using a custom rig
function RagDollService:DisableRagDoll(char: Model)
	-- Turns off ragdoll
	RagDollService:RemoveCollisionRagDoll(char)
	RagDollService:SwitchedRigsMotor6D(char)
end
-- Applies force to the HumanoidRootPart which causes the player to fling in the Direction of the Character using AssemblyLinearVelocity. Uses TimeUntilApply to wait how long to apply the force. TimeToWaitUntilUnRagdoll is how long until to UnRagdoll. 
function RagDollService:ForceApplyRagDollWait(char: Model, Force: Vector3, TimeUntilApply: number, TimeToWaitUntilUnRagdoll: number)
	-- The Provided time to wait.
	task.wait(TimeUntilApply)
	-- Enables RagDoll to ensure its BallSockets being pushed and NOT Motor6Ds.
	RagDollService:EnableRagDoll(char)
	-- Sets HRP (the Humanoids Root Part)
	local HumanoidRootPart: BasePart = char.HumanoidRootPart
	-- Simple calculation to make it apply in the direction of the character.
	local ForceResult = (HumanoidRootPart.CFrame.LookVector * Force.Magnitude)
	-- checks if the hrp is real and ForceResult is real
	if HumanoidRootPart and ForceResult then
		-- Applies Force
		HumanoidRootPart.AssemblyLinearVelocity = ForceResult
	end
	-- The time to wait until ragdolling
	task.delay(TimeToWaitUntilUnRagdoll, function()
		RagDollService:DisableRagDoll(char)
	end)
end
-- Apples force to the HumanoidRootPart which causes the player to fling in the Direction of the Vector3 using AssemblyLinearVelocity But doesnt wait to unRagDoll.
function RagDollService:ForceApplyRagDoll(char: Model, Force: Vector3, TimeUntilApply: number)
	task.wait(TimeUntilApply)
	RagDollService:EnableRagDoll(char)
	local HumanoidRootPart: BasePart = char.HumanoidRootPart
	local ForceResult = (HumanoidRootPart.CFrame.LookVector * Force.Magnitude)
	if HumanoidRootPart then
		HumanoidRootPart.AssemblyLinearVelocity = ForceResult
	end
end
return RagDollService
