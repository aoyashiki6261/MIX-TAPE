// スプライトの自動アニメは止めて、自前でコマ送りする
image_speed = 0;

// 現在のコマ番号
anim_frame = 0;
image_index = 0;

// 全フレーム数（例：6フレーム）
anim_length = sprite_get_number(sprite_index);

// オフセット（敵からの相対位置）
// もし生成側から個別に渡されなかった場合は、マクロなどのデフォルト値を使う
if (!variable_instance_exists(id, "offset_right_x")) offset_right_x = ENEMY_SIGNAL_OFFSET_RIGHT_X;
if (!variable_instance_exists(id, "offset_right_y")) offset_right_y = ENEMY_SIGNAL_OFFSET_RIGHT_Y;
if (!variable_instance_exists(id, "offset_left_x"))  offset_left_x  = ENEMY_SIGNAL_OFFSET_LEFT_X;
if (!variable_instance_exists(id, "offset_left_y"))  offset_left_y  = ENEMY_SIGNAL_OFFSET_LEFT_Y;
