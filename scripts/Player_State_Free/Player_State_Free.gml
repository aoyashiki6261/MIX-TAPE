/// @description Calc_movement + collision + anim（Player_State_Free用）
/// 遊び値（デッドゾーン）を超えたときから速度計算を開始する仕様
function Calc_movement(do_step) {
    if (!do_step) return;

    // --- アナログスティック設定 ---
    var deadzone = PLAYER_STICK_DEADZONE_MOVE; // 遊び値（デッドゾーン） 例: 0.2 = 20%
    var gp = 0;
    var sx = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislh) : 0;  // 左スティックX軸
    var sy = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislv) : 0;  // 左スティックY軸

    // 入力の強さ（0..1）
    var mag = point_distance(0, 0, sx, sy);  // スティックの傾きの大きさ

    // デジタル入力（キーボード / D-Pad）
    var dx = keyboard_check(vk_right) - keyboard_check(vk_left);
    var dy = keyboard_check(vk_down) - keyboard_check(vk_up);

    var hmove_local = 0;
    var vmove_local = 0;

    if (mag > deadzone) {
        // --- 遊び値を超えた分だけを速度に反映 ---
        var ang = point_direction(0, 0, sx, sy);  // スティックの方向

        // 遊び値分を差し引き、残りを 0..1 に正規化
        var adj = (mag - deadzone) / (1 - deadzone);
        adj = clamp(adj, 0, 1);  // 正規化して0..1の範囲にする

        // 遊び値を超えた部分から徐々に速度が上がる
        hmove_local = lengthdir_x(walk_spd * adj, ang);
        vmove_local = lengthdir_y(walk_spd * adj, ang);

    } else if (dx != 0 || dy != 0) {
        // デジタル入力の場合は従来どおり定速移動
        var ang2 = point_direction(0, 0, dx, dy);
        hmove_local = lengthdir_x(walk_spd, ang2);
        vmove_local = lengthdir_y(walk_spd, ang2);
    }

    // 向き更新（左/右）＋マスクも左右反転
    if (hmove_local != 0) {
        facing = sign(hmove_local);
        image_xscale = facing;
    }

    // ------------------------
    // 衝突処理
    // ------------------------
    if (object_exists(O_Solid)) {
        if (place_meeting(x + hmove_local, y, O_Solid)) hmove_local = 0;
        if (place_meeting(x, y + vmove_local, O_Solid)) vmove_local = 0;
    }

    // ------------------------
    // 移動適用
    // ------------------------
    x += hmove_local;
    y += vmove_local;

    // ------------------------
    // アニメーション切替（移動時は歩きスプライト）
    // ------------------------
    if (hmove_local != 0 || vmove_local != 0) {
        sprite_index = S_Player_Walk; // 歩きのスプライト
    } else {
        sprite_index = S_Player_Idle; // アイドルのスプライト
    }
}

function collision(do_step = true) {
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
    if (!do_step) return;

    // スケールリセット（縦横比固定）
    image_yscale = 1; // 縦は常に等倍

    // 横方向は facing に従って維持（-1: 左 / +1: 右）
    if (facing < 0) {
        image_xscale = -1;
    } else {
        image_xscale = 1;
    }
}

function Player_State_Free(do_step) {
    if (!do_step) return;

    // 通常移動処理: 入力に応じて移動と衝突補正
    Calc_movement(do_step);

    // アニメ更新（※既存の実装をそのまま呼ぶ）
    anim(do_step);

    // 直近の移動方向を更新（入力があるフレームだけ）
    {
        var _dx = right - left;
        var _dy = down  - up;
        if (_dx != 0 || _dy != 0) {
            var _len = point_distance(0,0,_dx,_dy);
            if (_len != 0) {
                last_move_dir_x = _dx / _len;
                last_move_dir_y = _dy / _len;
            }
        }
    }

    // --- 回避入力判定 ---
    if (dash) {
        // クールダウンが残っていれば回避しない
        if (dodge_cooldown <= 0) {

            // ★ 方向決定は共通ヘルパに一本化（方向なし＝単押しは回避しない）
            if (choose_dodge_dir_from_input()) {
                // ★ 念のためゼロ方向対策（安全網）
                var _m = point_distance(0,0,dodge_dir_x,dodge_dir_y);
                if (_m > 0.0001) {
                    // 回避発動
                    Player_StartDodge();
                    dash = false;           // ★ 発動した瞬間に入力フラグ消費
                    return;
                }
            }
        }

        // 発動できなかった場合も入力を消費して再連打を防ぐ
        dash = false;
    }
}
