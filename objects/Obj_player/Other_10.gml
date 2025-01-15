/// @DnDAction : YoYo Games.Common.If_Variable
/// @DnDVersion : 1
/// @DnDHash : 6DCC1941
/// @DnDArgument : "var" "invincible"
/// @DnDArgument : "value" "false"
if(invincible == false){	/// @DnDAction : YoYo Games.Instances.Destroy_Instance
	/// @DnDVersion : 1
	/// @DnDHash : 06900379
	/// @DnDParent : 6DCC1941
	instance_destroy();

	/// @DnDAction : YoYo Games.Instance Variables.Set_Lives
	/// @DnDVersion : 1
	/// @DnDHash : 03EF78FD
	/// @DnDApplyTo : {Obj_game}
	/// @DnDParent : 6DCC1941
	/// @DnDArgument : "lives" "-1"
	/// @DnDArgument : "lives_relative" "1"
	with(Obj_game) {
	if(!variable_instance_exists(id, "__dnd_lives")) __dnd_lives = 0;__dnd_lives += real(-1);
	}}