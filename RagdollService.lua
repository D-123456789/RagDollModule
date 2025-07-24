--[[
Only works on R6. Recommended to use a StartCharacter or switch game RigType to R6 if possible.
Copy the Code in here then paste it into a ModuleScript Named "RagdollService" into ReplicatedStorage.
]]
local RagDollService = {}
-- Builds the collision for each given part due to BallSocketContrsaints not having built in Collision.
function RagDollService:BuildCollision(PartToAttach: BasePart)
	local BuiltCollision = Instance.new("Part", PartToAttach)
	BuiltCollision.Size = Vector3.new(1,1,1)
	BuiltCollision.Transparency = 1
	BuiltCollision.Position = PartToAttach.Position
	BuiltCollision.Rotation = PartToAttach.Rotation
	BuiltCollision.Name = "BuiltCollison"
	local WeldedCollision = Instance.new("WeldConstraint", BuiltCollision)
	WeldedCollision.Part0 = PartToAttach
	WeldedCollision.Part1 = BuiltCollision
	if PartToAttach.Name == "Torso" then
		BuiltCollision.Size = Vector3.new(2,1,2)
	elseif PartToAttach.Name == "Left Leg" then
		BuiltCollision.Size = Vector3.new(1,1.5,1)
	elseif PartToAttach.Name == "Right Leg" then
		BuiltCollision.Size = Vector3.new(1,1.5,1)
	elseif PartToAttach.Name == "Head" then
		BuiltCollision.Size = Vector3.new(0.75,0.75,0.75)
		local Specialmesh = Instance.new("SpecialMesh", BuiltCollision)
		Specialmesh.MeshType = Enum.MeshType.Head
	end
end
-- Switchs all Motor6Ds into BallSocketContrsaints
function RagDollService:SwitchedRigsBallSocketContrsaint(char: Model)
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("Humanoid") then
			for i = 1,5 do
				v.PlatformStand = true
				v.RequiresNeck = false
				v.BreakJointsOnDeath = false
				v.AutoRotate = false
				if v.PlatformStand == true then break end
				task.wait(0.5)
			end
		end
		if v:IsA("Motor6D") then
			if v.Name ~= "RootJoint" then
				local A0 = Instance.new("Attachment")
				local A1 = Instance.new("Attachment")
				A0.CFrame = v.C0
				A1.CFrame = v.C1
				A0.Parent = v.Part0
				A1.Parent = v.Part1
				local b = Instance.new("BallSocketConstraint")
				b.Name = v.Name
				b.Attachment0 = A0
				b.Attachment1 = A1
				b.Parent = v.Part0
				v:Destroy()
			end
		end
	end
end
-- Switchs all BallSocketContrsaints into Motor6Ds
function RagDollService:SwitchedRigsMotor6D(char: Model)
	for _, v in ipairs(char:GetDescendants()) do
		char.HumanoidRootPart:PivotTo(CFrame.new(char.HumanoidRootPart.Position + Vector3.new(0,0.05,0)))
		if v:IsA("Humanoid") then
			v.PlatformStand = false
			v.RequiresNeck = true
			v.AutoRotate = true
		end
		if v:IsA("BallSocketConstraint") then
			local part0 = v.Attachment0.Parent
			local part1 = v.Attachment1.Parent
			local Motor6D = Instance.new("Motor6D")
			Motor6D.Name = v.Name
			Motor6D.Part0 = part0
			Motor6D.Part1 = part1
			Motor6D.C0 = v.Attachment0.CFrame
			Motor6D.C1 = v.Attachment1.CFrame
			Motor6D.Parent = part1  
			v:Destroy()
		end
	end
end
-- Removes all Collosion Parts for the character that was made for the Ragdoll
function RagDollService:RemoveCollisionRagDoll(char: Model)
	for i, v in ipairs(char:GetDescendants()) do
		if v.Name == "BuiltCollison" then
			v:Destroy()
		end
		if v.Name == "Head" then
			for ii, vv in ipairs(v:GetDescendants()) do
				if vv.Name == "Builded" then
					vv:Destroy()
				end
			end
		end
	end
end
return RagDollService
