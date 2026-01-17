// --- Create ---
// スプライト側のFPS設定を使って自動再生させる
image_index = 0;

// スプライトのSpeed設定に従わせる（推奨：スプライト側は「フレーム/秒」にしておく）
var spd = sprite_get_speed(sprite_index);
var typ = sprite_get_speed_type(sprite_index);

// sprite speed が「フレーム/秒」なら room_speed 基準の image_speed に変換
// 「フレーム/ゲームフレーム」ならそのまま
image_speed = (typ == spritespeed_framespersecond) ? (spd / room_speed) : spd;

// オフセット（敵からの相対位置）
if (!variable_instance_exists(id, "offset_right_x")) offset_right_x = ENEMY_SIGNAL_OFFSET_RIGHT_X;
if (!variable_instance_exists(id, "offset_right_y")) offset_right_y = ENEMY_SIGNAL_OFFSET_RIGHT_Y;
if (!variable_instance_exists(id, "offset_left_x"))  offset_left_x  = ENEMY_SIGNAL_OFFSET_LEFT_X;
if (!variable_instance_exists(id, "offset_left_y"))  offset_left_y  = ENEMY_SIGNAL_OFFSET_LEFT_Y;
