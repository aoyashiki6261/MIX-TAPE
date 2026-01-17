// --- Step ---

// -----------------------------
// 一時停止 / 1フレーム進行 対応
// -----------------------------
var do_step = true;

if (variable_global_exists("gamePaused") && global.gamePaused) {
    if (variable_global_exists("stepAdvance") && global.stepAdvance) {
        do_step = true;   // 1フレームだけ進める
    } else {
        do_step = false;  // 停止
    }
}

if (!do_step) {
    image_speed = 0; // ポーズ中は停止
    exit;
}

// 進めるフレームでは、スプライト側FPSに戻す
var spd = sprite_get_speed(sprite_index);
var typ = sprite_get_speed_type(sprite_index);
image_speed = (typ == spritespeed_framespersecond) ? (spd / room_speed) : spd;

// ワンショット終了判定：最後まで行ったら消す
// image_speed で進むので image_index を見て判定する
if (image_index >= image_number - image_speed) {
    instance_destroy();
    exit;
}

// 敵より手前に描画
depth = owner.depth - 1;
