/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 2D5280A1
/// @DnDArgument : "expr" "-1"
/// @DnDArgument : "expr_relative" "1"
/// @DnDArgument : "var" "MIDHP"
MIDHP += -1;

/// @DnDAction : YoYo Games.Common.If_Variable
/// @DnDVersion : 1
/// @DnDHash : 45F82E3C
/// @DnDArgument : "var" "MIDHP"
/// @DnDArgument : "op" "3"
if(MIDHP <= 0){	/// @DnDAction : YoYo Games.Instance Variables.Set_Score
	/// @DnDVersion : 1
	/// @DnDHash : 44A80ED6
	/// @DnDApplyTo : {Obj_game}
	/// @DnDParent : 45F82E3C
	/// @DnDArgument : "score" "100"
	/// @DnDArgument : "score_relative" "1"
	with(Obj_game) {
	if(!variable_instance_exists(id, "__dnd_score")) __dnd_score = 0;__dnd_score += real(100);
	}

	/// @DnDAction : YoYo Games.Instances.Destroy_Instance
	/// @DnDVersion : 1
	/// @DnDHash : 6B9C5ACC
	/// @DnDParent : 45F82E3C
	instance_destroy();

	/// @DnDAction : YoYo Games.Audio.Play_Audio
	/// @DnDVersion : 1.1
	/// @DnDHash : 249A9D5C
	/// @DnDParent : 45F82E3C
	/// @DnDArgument : "soundid" "Sd_break3"
	/// @DnDSaveInfo : "soundid" "Sd_break3"
	audio_play_sound(Sd_break3, 0, 0, 1.0, undefined, 1.0);

	/// @DnDAction : YoYo Games.Loops.Repeat
	/// @DnDVersion : 1
	/// @DnDHash : 7DA5C385
	/// @DnDParent : 45F82E3C
	/// @DnDArgument : "times" "10"
	repeat(10){	/// @DnDAction : YoYo Games.Instances.Create_Instance
		/// @DnDVersion : 1
		/// @DnDHash : 58E7DFCB
		/// @DnDParent : 7DA5C385
		/// @DnDArgument : "xpos_relative" "1"
		/// @DnDArgument : "ypos_relative" "1"
		/// @DnDArgument : "objectid" "Obj_blood"
		/// @DnDSaveInfo : "objectid" "Obj_blood"
		instance_create_layer(x + 0, y + 0, "Instances", Obj_blood);}}