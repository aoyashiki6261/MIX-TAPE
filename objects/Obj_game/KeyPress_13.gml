/// @DnDAction : YoYo Games.Instance Variables.If_Lives
/// @DnDVersion : 1
/// @DnDHash : 69E09C4E
/// @DnDArgument : "op" "2"
if(!variable_instance_exists(id, "__dnd_lives")) __dnd_lives = 0;
if(__dnd_lives > 0){	/// @DnDAction : YoYo Games.Instances.If_Instance_Exists
	/// @DnDVersion : 1
	/// @DnDHash : 4E982F7C
	/// @DnDParent : 69E09C4E
	/// @DnDArgument : "obj" "Obj_player"
	/// @DnDArgument : "not" "1"
	/// @DnDSaveInfo : "obj" "Obj_player"
	var l4E982F7C_0 = false;l4E982F7C_0 = instance_exists(Obj_player);if(!l4E982F7C_0){	/// @DnDAction : YoYo Games.Instances.Create_Instance
		/// @DnDVersion : 1
		/// @DnDHash : 59B9C170
		/// @DnDParent : 4E982F7C
		/// @DnDArgument : "xpos" "400"
		/// @DnDArgument : "ypos" "400"
		/// @DnDArgument : "objectid" "Obj_player"
		/// @DnDSaveInfo : "objectid" "Obj_player"
		instance_create_layer(400, 400, "Instances", Obj_player);}}

/// @DnDAction : YoYo Games.Common.Else
/// @DnDVersion : 1
/// @DnDHash : 406AA2B6
else{	/// @DnDAction : YoYo Games.Instance Variables.If_Score
	/// @DnDVersion : 1
	/// @DnDHash : 0464450A
	/// @DnDParent : 406AA2B6
	/// @DnDArgument : "op" "4"
	if(!variable_instance_exists(id, "__dnd_score")) __dnd_score = 0;
	if(__dnd_score >= 0){	/// @DnDAction : YoYo Games.Rooms.Go_To_Room
		/// @DnDVersion : 1
		/// @DnDHash : 79383766
		/// @DnDParent : 0464450A
		/// @DnDArgument : "room" "Rm_gameover"
		/// @DnDSaveInfo : "room" "Rm_gameover"
		room_goto(Rm_gameover);
	
		/// @DnDAction : YoYo Games.Audio.Stop_Audio
		/// @DnDVersion : 1
		/// @DnDHash : 4A834BD4
		/// @DnDParent : 0464450A
		/// @DnDArgument : "soundid" "Sd_bgm"
		/// @DnDSaveInfo : "soundid" "Sd_bgm"
		audio_stop_sound(Sd_bgm);}

	/// @DnDAction : YoYo Games.Common.Else
	/// @DnDVersion : 1
	/// @DnDHash : 04E69AEE
	/// @DnDParent : 406AA2B6
	else{	/// @DnDAction : YoYo Games.Rooms.Go_To_Room
		/// @DnDVersion : 1
		/// @DnDHash : 3C560157
		/// @DnDParent : 04E69AEE
		/// @DnDArgument : "room" "Rm_gameover"
		/// @DnDSaveInfo : "room" "Rm_gameover"
		room_goto(Rm_gameover);
	
		/// @DnDAction : YoYo Games.Audio.Stop_Audio
		/// @DnDVersion : 1
		/// @DnDHash : 204B24BD
		/// @DnDParent : 04E69AEE
		/// @DnDArgument : "soundid" "Sd_bgm"
		/// @DnDSaveInfo : "soundid" "Sd_bgm"
		audio_stop_sound(Sd_bgm);}}