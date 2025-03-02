/// @DnDAction : YoYo Games.Instances.Create_Instance
/// @DnDVersion : 1
/// @DnDHash : 31299D6E
/// @DnDArgument : "xpos" "random(room_width)"
/// @DnDArgument : "ypos" "random(room_height)"
/// @DnDArgument : "objectid" "Obj_enemy"
/// @DnDSaveInfo : "objectid" "Obj_enemy"
instance_create_layer(random(room_width), random(room_height), "Instances", Obj_enemy);

/// @DnDAction : YoYo Games.Instances.Set_Alarm
/// @DnDVersion : 1
/// @DnDHash : 4B28AF4A
/// @DnDArgument : "steps" "180"
alarm_set(0, 180);