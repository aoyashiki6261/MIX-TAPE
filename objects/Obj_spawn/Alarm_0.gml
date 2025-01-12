/// @DnDAction : YoYo Games.Instances.Create_Instance
/// @DnDVersion : 1
/// @DnDHash : 2A199B70
/// @DnDArgument : "xpos" "random(room_width)"
/// @DnDArgument : "ypos" "random(room_height)"
/// @DnDArgument : "objectid" "Obj_egg"
/// @DnDSaveInfo : "objectid" "Obj_egg"
instance_create_layer(random(room_width), random(room_height), "Instances", Obj_egg);

/// @DnDAction : YoYo Games.Instances.Set_Alarm
/// @DnDVersion : 1
/// @DnDHash : 3C83BABB
/// @DnDArgument : "steps" "180"
alarm_set(0, 180);