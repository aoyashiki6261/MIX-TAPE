/// @DnDAction : YoYo Games.Instances.Sprite_Scale
/// @DnDVersion : 1
/// @DnDHash : 61A7F619
/// @DnDArgument : "xscale" "0.01"
/// @DnDArgument : "xscale_relative" "1"
/// @DnDArgument : "yscale" "0.01"
/// @DnDArgument : "yscale_relative" "1"
image_xscale += 0.01;image_yscale += 0.01;

/// @DnDAction : YoYo Games.Common.If_Variable
/// @DnDVersion : 1
/// @DnDHash : 2DA45C4C
/// @DnDArgument : "var" "image_xscale"
/// @DnDArgument : "op" "4"
/// @DnDArgument : "value" "1"
if(image_xscale >= 1){	/// @DnDAction : YoYo Games.Instances.Change_Instance
	/// @DnDVersion : 1
	/// @DnDHash : 4D0924ED
	/// @DnDParent : 2DA45C4C
	/// @DnDArgument : "objind" "Obj_enemyBIG"
	/// @DnDSaveInfo : "objind" "Obj_enemyBIG"
	instance_change(Obj_enemyBIG, true);}