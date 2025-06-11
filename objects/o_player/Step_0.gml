// --- フラグ: 一時停止中に1フレーム進行を許可するか ---
var do_step = (!global.gamePaused || global.stepAdvance);

// --- アニメーション速度制御 ---
image_speed = (do_step ? 1 : 0);

// 描画順
depth = -100000;

// 入力状態の更新関数（pressed_xxx を含む）
function update_input_flags() {
    static is_space_down = false;
    static was_space_down = false;
    static is_pad_down = false;
    static was_pad_down = false;
    static is_attack_down = false;
    static was_attack_down = false;

    was_space_down = is_space_down;
    was_pad_down = is_pad_down;
    was_attack_down = is_attack_down;

    var gp = 0;
    is_space_down = keyboard_check(vk_space);
    is_pad_down = gamepad_is_connected(gp) && gamepad_button_check(gp, gp_face1);
    is_attack_down = mouse_check_button(mb_left) || (gamepad_is_connected(gp) && gamepad_button_check(gp, gp_face3));

    return {
        pressed_space: (!was_space_down && is_space_down),
        pressed_pad: (!was_pad_down && is_pad_down),
        pressed_attack: (!was_attack_down && is_attack_down)
    };
}

// --- プレイヤー入力状態の初期化 ---
function reset_variables() {
    left = 0;
    right = 0;
    up = 0;
    down = 0;
    vmome = 0;
    hmove = 0;
    dash = false;
}

// --- 入力取得（pressed情報も渡す） ---
function get_input(pressed_space, pressed_pad) {
    if (keyboard_check(ord("A")))    left = 1;
    if (keyboard_check(ord("D")))    right = 1;
    if (keyboard_check(ord("W")))    up = 1;
    if (keyboard_check(ord("S")))    down = 1;
    if (pressed_space) dash = true;

    var gp = 0;
    if (gamepad_is_connected(gp)) {
        var stick_x = gamepad_axis_value(gp, gp_axislh);
        var stick_y = gamepad_axis_value(gp, gp_axislv);
        var threshold = 0.5;

        if (stick_x < -threshold) left = 1;
        if (stick_x > threshold) right = 1;
        if (stick_y < -threshold) up = 1;
        if (stick_y > threshold) down = 1;

        if (pressed_pad) dash = true;
    }
}

// --- 入力状態を更新し、戻り値を保存 ---
var input_flags = update_input_flags();
var pressed_space = input_flags.pressed_space;
var pressed_pad = input_flags.pressed_pad;
var pressed_attack = input_flags.pressed_attack;

// --- 入力取得（常に） ---
reset_variables();
get_input(pressed_space, pressed_pad);

// クールダウン減算（do_step中のみ）
if (do_step && dodge_cooldown > 0) {
    dodge_cooldown--;
}

if (do_step) {
    // --- 状態別処理 ---
    switch (state) {
        case PLAYERSTATE.FREE:
            Player_State_Free(do_step);
            reset_variables();
            get_input(pressed_space, pressed_pad);

            if (dash && dodge_cooldown <= 0) {
                var dir_x = right - left;
                var dir_y = down - up;

                if (dir_x != 0 || dir_y != 0) {
                    state = PLAYERSTATE.DODGE;
                    sprite_index = S_Player_Dodge_Start;
                    image_index = 0;
                    image_speed = 0.5;

                    dodge_timer = dodge_duration;
                    dodge_cooldown = dodge_cooldown_max;
                    invincible = true;

                    var dir = point_direction(0, 0, dir_x, dir_y);
                    var new_x = x + lengthdir_x(dodge_distance, dir);
                    var new_y = y + lengthdir_y(dodge_distance, dir);

                    if (!place_meeting(new_x, new_y, O_Solid)) {
                        x = new_x;
                        y = new_y;
                    } else {
                        var dx = lengthdir_x(1, dir);
                        var dy = lengthdir_y(1, dir);
                        var temp_x = x;
                        var temp_y = y;

                        for (var i = 0; i < dodge_distance; i++) {
                            var next_x = temp_x + dx;
                            var next_y = temp_y + dy;

                            if (!place_meeting(next_x, next_y, O_Solid)) {
                                temp_x = next_x;
                                temp_y = next_y;
                            } else {
                                break;
                            }
                        }

                        x = temp_x;
                        y = temp_y;
                    }
                }
            }
            Calc_movement(do_step);
            anim(do_step);
        break;

       // --- 回避処理中 ---
		case PLAYERSTATE.DODGE:
		    visible = true;
		    image_alpha = 1;
		    sprite_index = S_Player_Dodge_Start;
		    image_speed = 1;

		    // 毎フレーム、少しずつ移動する
		    var move_x = lengthdir_x(dodge_speed, dodge_dir);
		    var move_y = lengthdir_y(dodge_speed, dodge_dir);

		    // 壁にぶつかっていなければ移動
		    if (!place_meeting(x + move_x, y + move_y, O_Solid)) {
		        x += move_x;
		        y += move_y;
		    }

		    // タイマー減算
		    dodge_timer--;
		    if (dodge_timer <= 0) {
		        invincible = false;
		        state = PLAYERSTATE.FREE;
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
                sprite_index = S_Player_Dead;
                image_index = 0;
                image_speed = 1;
                deadanimstarted = true;
            }

            death_timer++;
            if (death_timer > 900) {
                instance_destroy();
            }
        break;
    }

    // 攻撃入力処理（緊急回避中でも受付）
    if (pressed_attack && state != PLAYERSTATE.DEAD) {
        state = PLAYERSTATE.ATTACK_SLASH;
    }

    // 1フレーム進行が完了したら解除
    if (global.stepAdvance) {
        global.stepAdvance = false;
    }
}
