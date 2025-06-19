// --- フラグ: 一時停止中に1フレーム進行を許可するか ---
var do_step = (!global.gamePaused || global.stepAdvance);

// --- アニメーション速度制御 ---
image_speed = (do_step ? 1 : 0);

depth = -100000;

// ※ update_input_flags(), reset_variables(), get_input() は Create イベントで定義済みとする

// --- 入力状態を更新し、戻り値を保存 ---
var input_flags   = update_input_flags();
var pressed_space = input_flags.pressed_space;
var pressed_pad   = input_flags.pressed_pad;
var pressed_attack= input_flags.pressed_attack;

// --- 入力取得（常に） ---
reset_variables();
get_input(pressed_space, pressed_pad);

// クールダウン減算（do_step 中のみ）
if (do_step && dodge_cooldown > 0) dodge_cooldown--;

// --- ステートマシン ---
if (do_step) {
    switch (state) {
        case PLAYERSTATE.FREE:
            // 通常移動処理: 入力に応じて移動と衝突補正
            Calc_movement(do_step);
            // アニメ更新
            anim(do_step);
            // --- 回避入力判定 ---
            if (dash && dodge_cooldown <= 0) {
                // スティック入力を優先してアナログ方向取得
                var gp = 0;
                var stick_x = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislh) : 0;
                var stick_y = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislv) : 0;
                var mag = point_distance(0, 0, stick_x, stick_y);
                if (mag > 0.2) {
                    dodge_dir_x = stick_x / mag;
                    dodge_dir_y = stick_y / mag;
                }
                else if (left || right || up || down) {
                    var dir_x = right - left;
                    var dir_y = down  - up;
                    var len   = point_distance(0, 0, dir_x, dir_y);
                    if (len != 0) {
                        dodge_dir_x = dir_x / len;
                        dodge_dir_y = dir_y / len;
                    }
                }
                else {
                    // 入力なしなら回避しない
                    dodge_dir_x = 0;
                    dodge_dir_y = 0;
                }
                
                // 回避ステートへ遷移
                state          = PLAYERSTATE.DODGE;
                sprite_index   = S_Player_Dodge_Start;
                image_index    = 0;
                image_speed    = 1;
                dodge_timer    = dodge_duration;
                dodge_cooldown = dodge_cooldown_max;
                invincible     = true;
                dash           = false;
            }
            break;

        case PLAYERSTATE.DODGE:
            visible     = true;
            image_alpha = 1;
            // 1. 開始アニメ完了 → ロール
            if (sprite_index == S_Player_Dodge_Start) {
                if (image_index >= image_number - image_speed) {
                    sprite_index = S_Player_Dodge_Roll;
                    image_index   = 0;
                    image_speed   = 1;
                }
            }
            // 2. ローリング中の移動 & タイマー減算
            else if (sprite_index == S_Player_Dodge_Roll) {
                x += dodge_dir_x * dodge_speed;
                y += dodge_dir_y * dodge_speed;
                dodge_timer--;
                if (dodge_timer <= 0) {
                    sprite_index = S_Player_Dodge_End;
                    image_index   = 0;
                    image_speed   = 1;
                }
            }
            // 3. 終了アニメ完了 → 通常ステートへ
            else if (sprite_index == S_Player_Dodge_End) {
                if (image_index >= image_number - image_speed) {
                    state         = PLAYERSTATE.FREE;
                    invincible    = false;
                    sprite_index  = S_Player_Idle;
                    image_index   = 0;
                    image_speed   = 1;
                }
            }
            break;

        case PLAYERSTATE.ATTACK_SLASH:
            Player_State_Attack_Slash(do_step);
            break;

        case PLAYERSTATE.ATTACK_COMBO:
            Player_State_Attack_Combo(do_step);
            break;

        case PLAYERSTATE.DEAD:
            hSpeed = 0;
            vSpeed = 0;
            if (!deadanimstarted) {
                sprite_index    = S_Player_Dead;
                image_index     = 0;
                image_speed     = 1;
                deadanimstarted = true;
            }
            death_timer++;
            if (death_timer > 900) instance_destroy();
            break;
    }
    // 攻撃入力処理（緊急回避中でも受付）
    if (pressed_attack && state != PLAYERSTATE.DEAD) {
        state = PLAYERSTATE.ATTACK_SLASH;
    }
    // 1フレーム進行フラグリセット
    if (global.stepAdvance) global.stepAdvance = false;
}
