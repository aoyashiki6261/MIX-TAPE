function Calc_movement(do_step) {
    // --- 一時停止対応 ---
    if (!do_step) return;

    // 入力値から移動量を計算
    hmove = right - left;
    vmove = down - up;

    if (hmove != 0) facing = hmove;

    // 上記の値を参照にプレイヤーの移動している方向を取得
    if (hmove != 0 || vmove != 0) {
        // 座標の始点を(X=0,Y=0)としてここから移動先の方向、移動距離を取得
        var _dir = point_direction(0, 0, hmove, vmove);

        // プレイヤーの移動速度を参照に移動先の方向、移動距離を設定
        hmove = lengthdir_x(walk_spd, _dir);
        vmove = lengthdir_y(walk_spd, _dir);

        // 移動先をプレイヤーの位置に設定
        x += hmove;
        y += vmove;
    }
}

function collision(do_step) {
    // --- 一時停止対応 ---
    if (!do_step) return;

    // ターゲット値の設定
    var _tx = x;
    var _ty = y;

    // 衝突してから最後のステップ位置に戻る。
    x = xprevious;
    y = yprevious;

    // 移動したい距離の取得
    var _disx = abs(_tx - x);
    var _disy = abs(_ty - y);

    // solidにぶつかる前にxとyでできるだけ遠くまで移動
    repeat (_disx) {
        if (!place_meeting(x + sign(_tx - x), y, O_Solid)) x += sign(_tx - x);
    }
    repeat (_disy) {
        if (!place_meeting(x, y + sign(_ty - y), O_Solid)) y += sign(_ty - y);
    }
}

function anim(do_step) {
    // --- 一時停止対応 ---
    if (!do_step) return;

    if (hmove != 0 || vmove != 0) {
        sprite_index = S_Player_Walk;
    } else {
        sprite_index = S_Player_Idle;
    }

    if (keyboard_check_pressed(vk_space)) {
        // 回避などのアニメ対応があればここに記述
    }
}
