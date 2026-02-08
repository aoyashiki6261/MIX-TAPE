/// @description DODGEステート一式（開始→ロール→終了 & 先行入力消費）
/// @param {bool} do_step デバッグ用：一時停止中でも1フレーム進めるときに trueとする。
function Player_State_Dodge(do_step) {
    if (!do_step) return;

    visible     = true;
    image_alpha = 1;

    // 先行入力受付（終盤のみ＝buffer_accept_window()内で判定）
    // ※ buffer_try_record 内で「DODGE方向スナップ保存」している前提
    if (variable_instance_exists(id, "buffer_try_record")) {
        buffer_try_record(pressed_attack_i, pressed_space_i, pressed_pad_i);
    }

    // 1) 開始アニメ完了 → ロール
    if (sprite_index == S_Player_Dodge_Start) {
        if (image_index >= image_number - image_speed) {
            sprite_index = S_Player_Dodge_Roll;
            image_index  = 0;
            image_speed  = 1;
        }
        return;
    }

    // 2) ローリング中の移動 & タイマー減算
    if (sprite_index == S_Player_Dodge_Roll) {

        x += dodge_dir_x * dodge_speed;
        y += dodge_dir_y * dodge_speed;

        // ★ロール中も衝突補正（すり抜け防止）
        if (variable_instance_exists(id, "collision")) {
            collision(true);
        }

        dodge_timer--;
        if (dodge_timer <= 0) {
            sprite_index = S_Player_Dodge_End;
            image_index  = 0;
            image_speed  = 1;
        }
        return;
    }

    // 3) 終了アニメ完了 → 通常 or 先行入力消費
    if (sprite_index == S_Player_Dodge_End) {
        if (image_index >= image_number - image_speed) {

            // -----------------------------
            // バッファ消費（あれば次を即実行）
            // -----------------------------
            if (buffered_action == ACTION.ATTACK) {
                if (variable_instance_exists(id, "buffer_clear")) buffer_clear();
                state = PLAYERSTATE.ATTACK_SLASH;
                return;
            }
            else if (buffered_action == ACTION.DODGE) {

                // ★クールダウン中なら回避せずバッファ消去してFREEへ
                if (dodge_cooldown > 0) {
                    if (variable_instance_exists(id, "buffer_clear")) buffer_clear();

                    state        = PLAYERSTATE.FREE;
                    invincible   = false;
                    sprite_index = S_Player_Idle;
                    image_index  = 0;
                    image_speed  = 1;
                    return;
                }

                // ★重要：方向は「バッファに保存したもの」を採用（取り直さない）
				
				if (!variable_instance_exists(id, "buffered_dodge_dir_x")) buffered_dodge_dir_x = 0;
				if (!variable_instance_exists(id, "buffered_dodge_dir_y")) buffered_dodge_dir_y = 0;

				if (point_distance(0, 0, buffered_dodge_dir_x, buffered_dodge_dir_y) < 0.0001) {
				    buffered_dodge_dir_x = last_move_dir_x;
				    buffered_dodge_dir_y = last_move_dir_y;
				}
                dodge_dir_x = buffered_dodge_dir_x;
                dodge_dir_y = buffered_dodge_dir_y;

                // 念のためゼロ方向対策（最後の移動方向で補完）
                var _m = point_distance(0, 0, dodge_dir_x, dodge_dir_y);
                if (_m < 0.0001) {
                    dodge_dir_x = last_move_dir_x;
                    dodge_dir_y = last_move_dir_y;
                }

                if (variable_instance_exists(id, "buffer_clear")) buffer_clear();

                // ★初期化は共通関数へ
                Player_StartDodge();
                return;
            }

            // 予約なしならFREEへ
            state        = PLAYERSTATE.FREE;
            invincible   = false;
            sprite_index = S_Player_Idle;
            image_index  = 0;
            image_speed  = 1;
        }
        return;
    }
}
