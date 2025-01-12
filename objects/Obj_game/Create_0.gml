/// @DnDAction : YoYo Games.Audio.Play_Audio
/// @DnDVersion : 1.1
/// @DnDHash : 1E9D5B75
/// @DnDArgument : "soundid" "Sd_bgm"
/// @DnDArgument : "loop" "1"
/// @DnDSaveInfo : "soundid" "Sd_bgm"
audio_play_sound(Sd_bgm, 0, 1, 1.0, undefined, 1.0);

/// @DnDAction : YoYo Games.Instance Variables.Set_Score
/// @DnDVersion : 1
/// @DnDHash : 190A53DD
__dnd_score = real(0);

/// @DnDAction : YoYo Games.Instance Variables.Set_Lives
/// @DnDVersion : 1
/// @DnDHash : 0596692E
/// @DnDArgument : "lives" "3"
__dnd_lives = real(3);