# RagDollModule
Roblox Module script for a RagDollService.
How to use:
To start using this Module you wil first. Need to copy the actual code for it into a module then rename that Module into "RagDollService", then Parent it to where you want it.
Next you will need to make all players to only play in R6. then to accsess the functions you will need to label the Service as a Variable at the top of your script.
afterwards your all set.

to Activate Ragdoll Simpley do this (Make sure to make a variable for the character or provide the character or it will error out.)

	RagDollService:EnableRagDoll(char)


 # To DeActivate RagDoll then do this. (Once again provide a character)
 	RagDollService:DisableRagDoll(char)
   that simple


# How to Fling around RagDolls.
To fling ragdolls around its very simple as ive made it even easier for you.
Simply type this

 	RagDollService:ForceApplyRagDoll(char, [Vector3], [Time you want to wait until applying this force])
this will Apply a force you set for the RagDoll. Will only do it if the Player is Ragdolled
