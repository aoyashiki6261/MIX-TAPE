/// @DnDAction : YoYo Games.Audio.Play_Audio
/// @DnDVersion : 1.1
/// @DnDHash : 6584A1DA
/// @DnDArgument : "soundid" "Sd_shot"
/// @DnDSaveInfo : "soundid" "Sd_shot"
audio_play_sound(Sd_shot, 0, 0, 1.0, undefined, 1.0);

/// @DnDAction : YoYo Games.Movement.Set_Direction_Point
/// @DnDVersion : 1
/// @DnDHash : 44FA017B
/// @DnDArgument : "x" "mouse_x"
/// @DnDArgument : "y" "mouse_y"
direction = point_direction(x, y, mouse_x, mouse_y);

/// @DnDAction : YoYo Games.Movement.Set_Speed
/// @DnDVersion : 1
/// @DnDHash : 254787A1
/// @DnDArgument : "speed" "10"
speed = 10;