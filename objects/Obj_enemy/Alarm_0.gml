/// @DnDAction : YoYo Games.Instances.Create_Instance
/// @DnDVersion : 1
/// @DnDHash : 29DCDB70
/// @DnDArgument : "xpos_relative" "1"
/// @DnDArgument : "ypos_relative" "1"
/// @DnDArgument : "objectid" "Obj_bullet"
/// @DnDSaveInfo : "objectid" "Obj_bullet"
instance_create_layer(x + 0, y + 0, "Instances", Obj_bullet);

/// @DnDAction : YoYo Games.Instances.Set_Alarm
/// @DnDVersion : 1
/// @DnDHash : 46906AA2
/// @DnDArgument : "steps" "180"
alarm_set(0, 180);