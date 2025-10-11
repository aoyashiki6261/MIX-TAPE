/// @description 回避を開始（初期化を共通化）
function Player_StartDodge() {
    state          = PLAYERSTATE.DODGE;
    sprite_index   = S_Player_Dodge_Start;
    image_index    = 0;
    image_speed    = 1;
    dodge_timer    = dodge_duration;
    dodge_cooldown = dodge_cooldown_max;
    invincible     = true;
    dash           = false;
}

/// @description 入力から回避ベクトルを決定（成功:true / 失敗:false）
function choose_dodge_dir_from_input() {
    var gp = 0;
    var stick_x = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislh) : 0;
    var stick_y = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislv) : 0;
    var mag = point_distance(0, 0, stick_x, stick_y);
    if (mag > 0.2) { dodge_dir_x = stick_x / mag; dodge_dir_y = stick_y / mag; return true; }

    var dir_x = right - left, dir_y = down - up;
    var len = point_distance(0,0,dir_x,dir_y);
    if (len != 0) { dodge_dir_x = dir_x/len; dodge_dir_y = dir_y/len; return true; }

    return false;
}

// @description 攻撃ボタン押下の共通ハンドラ
function Player_HandleAttackPress() {
    if (state == PLAYERSTATE.DEAD) return;
    if (state == PLAYERSTATE.FREE) {
        state = PLAYERSTATE.ATTACK_SLASH;
    } else {
        //ミラー変数を使用（先行入力登録）
        buffer_try_record(pressed_attack_i, pressed_space_i, pressed_pad_i);
    }
}