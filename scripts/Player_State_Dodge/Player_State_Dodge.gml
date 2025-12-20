/// @description DODGEステート一式（開始→ロール→終了 & 先行入力消費）
/// @param {bool} do_step デバッグ用：一時停止中でも1フレーム進めるときに trueとする。
function Player_State_Dodge(do_step) {
    if (!do_step) return;

    visible     = true;
    image_alpha = 1;

    // 先行入力受付（終盤のみ＝buffer_accept_window()内で判定）
    buffer_try_record(pressed_attack_i, pressed_space_i, pressed_pad_i);

    // 1. 開始アニメ完了 → ロール
    if (sprite_index == S_Player_Dodge_Start) {
        if (image_index >= image_number - image_speed) {
            sprite_index = S_Player_Dodge_Roll;
            image_index   = 0;
            image_speed   = 1;
        }
        return;
    }

    // 2. ローリング中の移動 & タイマー減算
    if (sprite_index == S_Player_Dodge_Roll) {
        x += dodge_dir_x * dodge_speed;
        y += dodge_dir_y * dodge_speed;
        dodge_timer--;
        if (dodge_timer <= 0) {
            sprite_index = S_Player_Dodge_End;
            image_index   = 0;
            image_speed   = 1;
        }
        return;
    }

    // 3. 終了アニメ完了 → 通常 or 先行入力消費
    if (sprite_index == S_Player_Dodge_End) {
        if (image_index >= image_number - image_speed) {

            // バッファ消費（あれば次を即実行）
            if (buffered_action == ACTION.ATTACK) {
                buffer_clear();
                state = PLAYERSTATE.ATTACK_SLASH;
                return;
            }
            else if (buffered_action == ACTION.DODGE) {
                // ★ クールダウン中なら回避せずバッファ消去
                if (dodge_cooldown > 0 || !choose_dodge_dir_from_input()) {
                    buffer_clear();
                    state         = PLAYERSTATE.FREE;
                    invincible    = false;
                    sprite_index  = S_Player_Idle;
                    image_index   = 0;
                    image_speed   = 1;
                    return;
                }

                buffer_clear();
                // ★ 初期化は共通関数へ
                Player_StartDodge();
                return;
            }

            // 予約なしならFREEへ
            state         = PLAYERSTATE.FREE;
            invincible    = false;
            sprite_index  = S_Player_Idle;
            image_index   = 0;
            image_speed   = 1;
        }
        return;
    }
}
