/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 7ADCAA1F
/// @DnDArgument : "expr" "-1"
/// @DnDArgument : "expr_relative" "1"
/// @DnDArgument : "var" "BIGHP"
BIGHP += -1;

/// @DnDAction : YoYo Games.Common.If_Variable
/// @DnDVersion : 1
/// @DnDHash : 38E0220C
/// @DnDArgument : "var" "BIGHP"
/// @DnDArgument : "op" "3"
if(BIGHP <= 0){	/// @DnDAction : YoYo Games.Instance Variables.Set_Score
	/// @DnDVersion : 1
	/// @DnDHash : 77A1B71D
	/// @DnDApplyTo : {Obj_game}
	/// @DnDParent : 38E0220C
	/// @DnDArgument : "score" "30"
	/// @DnDArgument : "score_relative" "1"
	with(Obj_game) {
	if(!variable_instance_exists(id, "__dnd_score")) __dnd_score = 0;__dnd_score += real(30);
	}

	/// @DnDAction : YoYo Games.Instances.Destroy_Instance
	/// @DnDVersion : 1
	/// @DnDHash : 5B949B65
	/// @DnDParent : 38E0220C
	instance_destroy();

	/// @DnDAction : YoYo Games.Audio.Play_Audio
	/// @DnDVersion : 1.1
	/// @DnDHash : 262833CA
	/// @DnDParent : 38E0220C
	/// @DnDArgument : "soundid" "Sd_break2"
	/// @DnDSaveInfo : "soundid" "Sd_break2"
	audio_play_sound(Sd_break2, 0, 0, 1.0, undefined, 1.0);

	/// @DnDAction : YoYo Games.Loops.Repeat
	/// @DnDVersion : 1
	/// @DnDHash : 42140ECD
	/// @DnDParent : 38E0220C
	/// @DnDArgument : "times" "4"
	repeat(4){	/// @DnDAction : YoYo Games.Instances.Create_Instance
		/// @DnDVersion : 1
		/// @DnDHash : 4E75FD06
		/// @DnDParent : 42140ECD
		/// @DnDArgument : "xpos_relative" "1"
		/// @DnDArgument : "ypos_relative" "1"
		/// @DnDArgument : "objectid" "Obj_enemyMID"
		/// @DnDSaveInfo : "objectid" "Obj_enemyMID"
		instance_create_layer(x + 0, y + 0, "Instances", Obj_enemyMID);}}