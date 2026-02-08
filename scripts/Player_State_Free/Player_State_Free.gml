function Player_State_Free(do_step) {
    if (!do_step) return;

    // =========================================================
    // 通常移動処理
    //  - Calc_movement があればそれを使う
    //  - 無ければフォールバックで最低限動かす（WASD停止の回避）
    // =========================================================
    if (variable_instance_exists(id, "Calc_movement")) {
        Calc_movement(do_step);
    } else {
        static _warn_move = false;
        if (!_warn_move) {
            _warn_move = true;
        }

        // -------- フォールバック移動（アナログ優先→デジタル） --------
        var deadzone = PLAYER_STICK_DEADZONE_MOVE;
        var gp = 0;

        var sx = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislh) : 0;
        var sy = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislv) : 0;
        var mag = point_distance(0, 0, sx, sy);

        var dx = right - left;
        var dy = down  - up;

        var hmove_local = 0;
        var vmove_local = 0;

        if (mag > deadzone) {
            var ang = point_direction(0, 0, sx, sy);
            var adj = (mag - deadzone) / (1 - deadzone);
            adj = clamp(adj, 0, 1);

            hmove_local = lengthdir_x(walk_spd * adj, ang);
            vmove_local = lengthdir_y(walk_spd * adj, ang);
        }
        else if (dx != 0 || dy != 0) {
            var ang2 = point_direction(0, 0, dx, dy);
            hmove_local = lengthdir_x(walk_spd, ang2);
            vmove_local = lengthdir_y(walk_spd, ang2);
        }

        // 向き更新
        if (hmove_local != 0) facing = sign(hmove_local);

        // 簡易衝突
        if (object_exists(O_Solid)) {
            if (place_meeting(x + hmove_local, y, O_Solid)) hmove_local = 0;
            if (place_meeting(x, y + vmove_local, O_Solid)) vmove_local = 0;
        }

        x += hmove_local;
        y += vmove_local;

        // スプライト切替（S_Player_Walk が無い/未使用なら Idle のままでもOK）
        if ((hmove_local != 0 || vmove_local != 0) && asset_get_type(S_Player_Walk) == asset_sprite) {
            sprite_index = S_Player_Walk;
        } else {
            sprite_index = S_Player_Idle;
        }
    }

    // =========================================================
    // アニメ（左右反転）
    // =========================================================
    if (variable_instance_exists(id, "anim")) {
        anim(do_step);
    } else {
        // フォールバック：最低限の縦固定＆左右反転
        image_yscale = 1;
        image_xscale = (facing < 0) ? -1 : 1;
    }

    // =========================================================
    // 直近の移動方向を更新（入力があるフレームだけ）
    // =========================================================
    {
        var _dx = right - left;
        var _dy = down  - up;

        if (_dx != 0 || _dy != 0) {
            var _len = point_distance(0, 0, _dx, _dy);
            if (_len != 0) {
                last_move_dir_x = _dx / _len;
                last_move_dir_y = _dy / _len;
            }
        }
    }

    // =========================================================
    // ① 先行入力（バッファ）からの回避を優先して消費する
    // =========================================================
    if (buffered_action == ACTION.DODGE) {
        if (dodge_cooldown <= 0) {

            // 保存しておいた方向を採用（入力を取り直さない）
            dodge_dir_x = buffered_dodge_dir_x;
            dodge_dir_y = buffered_dodge_dir_y;

            // ゼロ方向対策
            var _m0 = point_distance(0, 0, dodge_dir_x, dodge_dir_y);
            if (_m0 < 0.0001) {
                dodge_dir_x = last_move_dir_x;
                dodge_dir_y = last_move_dir_y;
            }

            // バッファ消去（buffer_clear があれば使う／無ければ直消し）
            if (variable_instance_exists(id, "buffer_clear")) {
                buffer_clear();
            } else {
                buffered_action = ACTION.NONE;
                buffer_timer = 0;
                buffered_dodge_dir_x = 0;
                buffered_dodge_dir_y = 0;
                buffered_dodge_has_dir = false;
            }

            Player_StartDodge();
            return;

        } else {
            // クールダウン中は暴発防止で消す（安全側）
            if (variable_instance_exists(id, "buffer_clear")) {
                buffer_clear();
            } else {
                buffered_action = ACTION.NONE;
                buffer_timer = 0;
                buffered_dodge_dir_x = 0;
                buffered_dodge_dir_y = 0;
                buffered_dodge_has_dir = false;
            }
        }
    }

    // =========================================================
    // ② 通常の回避入力（dash）で回避開始
    // =========================================================
    if (dash) {
        if (dodge_cooldown <= 0) {

            var snap_ok = false;
            var snap_x  = 0;
            var snap_y  = 0;

            if (variable_instance_exists(id, "get_dodge_dir_snapshot")) {
                var snap = get_dodge_dir_snapshot();
                snap_ok = snap.ok;
                snap_x  = snap.x;
                snap_y  = snap.y;
            } else {
                // フォールバック
                var gp2 = 0;
                var stick_x = gamepad_is_connected(gp2) ? gamepad_axis_value(gp2, gp_axislh) : 0;
                var stick_y = gamepad_is_connected(gp2) ? gamepad_axis_value(gp2, gp_axislv) : 0;

                var mag2 = point_distance(0, 0, stick_x, stick_y);
                if (mag2 > 0.2) {
                    snap_ok = true;
                    snap_x  = stick_x / mag2;
                    snap_y  = stick_y / mag2;
                } else {
                    var _dx2 = right - left;
                    var _dy2 = down  - up;
                    var _len2 = point_distance(0, 0, _dx2, _dy2);
                    if (_len2 != 0) {
                        snap_ok = true;
                        snap_x  = _dx2 / _len2;
                        snap_y  = _dy2 / _len2;
                    }
                }
            }

            if (snap_ok) {
                dodge_dir_x = snap_x;
                dodge_dir_y = snap_y;
            } else {
                dodge_dir_x = last_move_dir_x;
                dodge_dir_y = last_move_dir_y;
            }

            var _m1 = point_distance(0, 0, dodge_dir_x, dodge_dir_y);
            if (_m1 > 0.0001) {
             
                Player_StartDodge();
                dash = false;
                return;
            }
        }

        dash = false;
    }
}
