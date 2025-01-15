/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 6FF96CCA
/// @DnDArgument : "expr" "view_camera[0]"
/// @DnDArgument : "var" "vc"
vc = view_camera[0];

/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 2F0192B5
/// @DnDArgument : "expr" "camera_get_view_x(vc)"
/// @DnDArgument : "var" "vx"
vx = camera_get_view_x(vc);

/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 63496F37
/// @DnDArgument : "expr" "camera_get_view_y(vc)"
/// @DnDArgument : "var" "vy"
vy = camera_get_view_y(vc);

/// @DnDAction : YoYo Games.Drawing.Set_Font
/// @DnDVersion : 1
/// @DnDHash : 77CCB5F9
/// @DnDArgument : "font" "Ft_score"
/// @DnDSaveInfo : "font" "Ft_score"
draw_set_font(Ft_score);

/// @DnDAction : YoYo Games.Drawing.Set_Color
/// @DnDVersion : 1
/// @DnDHash : 7AC995E7
draw_set_colour($FFFFFFFF & $ffffff);
var l7AC995E7_0=($FFFFFFFF >> 24);
draw_set_alpha(l7AC995E7_0 / $ff);

/// @DnDAction : YoYo Games.Drawing.Set_Alpha
/// @DnDVersion : 1
/// @DnDHash : 0CB99917
draw_set_alpha(1);

/// @DnDAction : YoYo Games.Drawing.Draw_Instance_Score
/// @DnDVersion : 1
/// @DnDHash : 339866A9
/// @DnDArgument : "x" "vx"
/// @DnDArgument : "y" "vy"
/// @DnDArgument : "caption" ""POINT: ""
if(!variable_instance_exists(id, "__dnd_score")) __dnd_score = 0;draw_text(vx, vy, string("POINT: ") + string(__dnd_score));

/// @DnDAction : YoYo Games.Drawing.Draw_Instance_Lives
/// @DnDVersion : 1
/// @DnDHash : 2FEF7239
/// @DnDArgument : "x" "vx"
/// @DnDArgument : "y" "vy + 20"
/// @DnDArgument : "sprite" "Spr_life"
/// @DnDArgument : "stackorder" "1"
/// @DnDSaveInfo : "sprite" "Spr_life"
var l2FEF7239_0 = sprite_get_height(Spr_life);var l2FEF7239_1 = 0;if(!variable_instance_exists(id, "__dnd_lives")) __dnd_lives = 0;for(var l2FEF7239_2 = __dnd_lives; l2FEF7239_2 > 0; --l2FEF7239_2) {	draw_sprite(Spr_life, 0, vx, vy + 20 + l2FEF7239_1);	l2FEF7239_1 += l2FEF7239_0;}