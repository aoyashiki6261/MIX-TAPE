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

// 先行入力
pressed_space_i  = pressed_space;
pressed_pad_i    = pressed_pad;
pressed_attack_i = pressed_attack;

// --- 入力取得（常に） ---
reset_variables();
get_input(pressed_space, pressed_pad);

// クールダウン減算（do_step 中のみ）
if (do_step && dodge_cooldown > 0) dodge_cooldown--;

//先行入力の寿命管理（毎フレーム）
if (do_step) buffer_update();

// --- ステートマシン ---
if (do_step) {
    switch (state) {
        case PLAYERSTATE.FREE:
            // 通常移動処理: 入力に応じて移動と衝突補正
            Calc_movement(do_step);
            // アニメ更新
            anim(do_step);

            // ★ 直近の移動方向を更新（入力があるフレームだけ）
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
			        //無入力時は “直近の移動方向” フォールバックをやめる（単押し無効）
			        dash = false;   //入力は消費
			        break;          //DODGEへ遷移しない
			    }

			    //ゼロ方向対策：無方向なら回避を開始しない（その場アニメ再生防止）
			    var _m = point_distance(0,0,dodge_dir_x,dodge_dir_y);
			    if (_m <= 0.0001) {
			        dash = false; //入力は消費
			        break;        //DODGEへ遷移しない
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
			
            //先行入力受付
            buffer_try_record(pressed_attack_i, pressed_space_i, pressed_pad_i);
			
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
            // 3. 終了アニメ完了 → 通常 or 先行入力消費
			else if (sprite_index == S_Player_Dodge_End) {
			    if (image_index >= image_number - image_speed) {

			        // バッファ消費（あれば次を即実行）
			        if (buffered_action == ACTION.ATTACK) {
			            buffer_clear();
			            state = PLAYERSTATE.ATTACK_SLASH;
			            break;
			        } else if (buffered_action == ACTION.DODGE) {
			            // ★ 実行フレーム時点で方向入力が無ければ回避を発生させない
			            var gp = 0;
			            var stick_x = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislh) : 0;
			            var stick_y = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislv) : 0;
			            var mag = point_distance(0, 0, stick_x, stick_y);
			            var dir_ok = false;

			            if (mag > 0.2) {
			                dodge_dir_x = stick_x / mag;
			                dodge_dir_y = stick_y / mag;
			                dir_ok = true;
			            } else if (left || right || up || down) {
			                var dir_x = right - left;
			                var dir_y = down  - up;
			                var len   = point_distance(0, 0, dir_x, dir_y);
			                if (len != 0) {
			                    dodge_dir_x = dir_x / len;
			                    dodge_dir_y = dir_y / len;
			                    dir_ok = true;
			                }
			            }

			            if (!dir_ok) {
			                // ★ 方向なし → 回避は起こさずFREEへ
			                buffer_clear();
			                state         = PLAYERSTATE.FREE;
			                invincible    = false;
			                sprite_index  = S_Player_Idle;
			                image_index   = 0;
			                image_speed   = 1;
			                break;
			            }

			            buffer_clear();
			            state          = PLAYERSTATE.DODGE;
			            sprite_index   = S_Player_Dodge_Start;
			            image_index    = 0;
			            image_speed    = 1;
			            dodge_timer    = dodge_duration;
			            dodge_cooldown = dodge_cooldown_max;
			            invincible     = true;
			            dash           = false;
			            break;
			        }

			        // 予約なしならFREEへ
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
	
    // 攻撃入力処理：FREEなら即実行／それ以外は“先行入力”に回す
    if (pressed_attack && state != PLAYERSTATE.DEAD) {
        if (state == PLAYERSTATE.FREE) {
            state = PLAYERSTATE.ATTACK_SLASH;
        } else {
            // 受付OKの終盤なら先行入力登録（不可なら何もしない）
            buffer_try_record(pressed_attack, pressed_space, pressed_pad);
        }
    }
    // 1フレーム進行フラグリセット
    if (global.stepAdvance) global.stepAdvance = false;
}
