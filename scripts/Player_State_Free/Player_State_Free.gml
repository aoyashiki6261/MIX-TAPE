/// @description Calc_movement + collision + anim（Player_State_Free用）

function Calc_movement(do_step) {
    // --- 一時停止対応 ---
    if (!do_step) return;

    // --- スティック遊び値 (デッドゾーン) の設定 ---
    var deadzone = 0.1;              // 0.1＝10% まで入力を無視したい場合
    var gp       = 0;
    var sx       = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislh) : 0;
    var sy       = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislv) : 0;
    var mag      = point_distance(0, 0, sx, sy);

    // まずデジタル入力（A/D/W/S または D-Pad）を取得
    var dx = right - left;
    var dy = down  - up;

    if (mag > deadzone) {
        // デッドゾーン超えた分を 0…1 に再マッピング
        var adj = (mag - deadzone) / (1 - deadzone);
        var ang = point_direction(0, 0, sx, sy);
        // walk_spd に adj を乗じて滑らかに加速
        hmove = lengthdir_x(walk_spd * adj, ang);
        vmove = lengthdir_y(walk_spd * adj, ang);
    }
    else if (dx != 0 || dy != 0) {
        // デジタル入力があれば従来どおり定速移動
        var ang2 = point_direction(0, 0, dx, dy);
        hmove = lengthdir_x(walk_spd, ang2);
        vmove = lengthdir_y(walk_spd, ang2);
    }
    else {
        // 入力なし
        hmove = 0;
        vmove = 0;
    }

    // 向き更新
    if (hmove != 0) facing = hmove;

    // 移動適用
    x += hmove;
    y += vmove;

}

function collision(do_step = true) {
    // --- 一時停止対応 ---
    if (!do_step) return;

    var _tx = x, _ty = y;
    // まず前フレーム位置に戻す
    x = xprevious; 
    y = yprevious;
    var _disx = abs(_tx - x);
    var _disy = abs(_ty - y);

    // solid にぶつかる前まで少しずつ移動
    repeat (_disx) {
        if (!place_meeting(x + sign(_tx - x), y, O_Solid)) {
            x += sign(_tx - x);
        }
    }
    repeat (_disy) {
        if (!place_meeting(x, y + sign(_ty - y), O_Solid)) {
            y += sign(_ty - y);
        }
    }
}

function anim(do_step) {
    // --- 一時停止対応 ---
    if (!do_step) return;

    // --- スケールリセット（縦横比固定） ---
    image_xscale = 1;
    image_yscale = 1;

    if (hmove != 0 || vmove != 0) {
        sprite_index = S_Player_Walk;
    } else {
        sprite_index = S_Player_Idle;
    }

    // 追加のキーアニメ（必要なら）
    if (keyboard_check_pressed(vk_space)) {
        // 回避などのアニメ対応
    }
}
