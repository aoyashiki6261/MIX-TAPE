/// @DnDAction : YoYo Games.Instances.If_Instance_Exists
/// @DnDVersion : 1
/// @DnDHash : 4616D8DC
/// @DnDArgument : "obj" "Obj_player"
/// @DnDSaveInfo : "obj" "Obj_player"
var l4616D8DC_0 = false;l4616D8DC_0 = instance_exists(Obj_player);if(l4616D8DC_0){	/// @DnDAction : YoYo Games.Movement.Set_Direction_Point
	/// @DnDVersion : 1
	/// @DnDHash : 2841DBA6
	/// @DnDParent : 4616D8DC
	/// @DnDArgument : "x" "Obj_player.x"
	/// @DnDArgument : "y" "Obj_player.y"
	direction = point_direction(x, y, Obj_player.x, Obj_player.y);}

/// @DnDAction : YoYo Games.Movement.Set_Speed
/// @DnDVersion : 1
/// @DnDHash : 02FF2AE9
/// @DnDArgument : "speed" "1.5"
speed = 1.5;