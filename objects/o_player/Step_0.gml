// 描画順をプレイヤーが常に一番手前に表示
depth = -100000;

function reset_variables() {
	left = 0;
	right = 0;
	up = 0;
	down = 0;
	vmome = 0;
	hmove = 0;
	dash = false;
}

function get_input() {
	if keyboard_check(ord("A"))	left = 1;
	if keyboard_check(ord("D"))	right = 1;
	if keyboard_check(ord("W"))	up = 1;
	if keyboard_check(ord("S"))	down = 1;
	if keyboard_check_pressed(vk_space) dash = true;

	// ゲームパッド対応（左スティックで方向、×で回避）
	var gp = 0;
	if (gamepad_is_connected(gp)) {
		var stick_x = gamepad_axis_value(gp, gp_axislh);
		var stick_y = gamepad_axis_value(gp, gp_axislv);
		var threshold = 0.5;

		if (stick_x < -threshold) left = 1;
		if (stick_x > threshold) right = 1;
		if (stick_y < -threshold) up = 1;
		if (stick_y > threshold) down = 1;

		// ×ボタンで回避
		if (gamepad_button_check_pressed(gp, gp_face1)) {
			dash = true;
		}
	}
}

// クールダウン減算
if (dodge_cooldown > 0) {
	dodge_cooldown--;
}

switch(state) {
	case PLAYERSTATE.FREE:
		Player_State_Free();
		reset_variables();
		get_input();

		// 回避条件：スペース押下＋クールダウン完了
		if (dash && dodge_cooldown <= 0) {

			// 入力された方向を計算（未入力時は回避しない）
			var dir_x = right - left;
			var dir_y = down - up;

			if (dir_x != 0 || dir_y != 0) { // ← 入力があるときだけ回避
				state = PLAYERSTATE.DODGE;

				// スプライトをS_Player_Dodgeに切り替えて再生（最初にやる）
				sprite_index = S_Player_Dodge;
				image_index = 0;
				image_speed = 0.5;

				// 状態変更＆無敵化
				state = PLAYERSTATE.DODGE;
				dodge_timer = dodge_duration;
				dodge_cooldown = dodge_cooldown_max;
				invincible = true;

				// 最終入力方向を取得
				var dir = point_direction(0, 0, dir_x, dir_y);

				// 目標地点を計算
				var new_x = x + lengthdir_x(dodge_distance, dir);
				var new_y = y + lengthdir_y(dodge_distance, dir);

				// 目標地点に障害物がなければそのまま移動（優先）
				if (!place_meeting(new_x, new_y, O_Solid)) {
					x = new_x;
					y = new_y;
				} else {
					// 壁があるなら、1ピクセルずつ前進（被らない範囲まで）
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
							break; // 壁に当たるなら停止
						}
					}

					x = temp_x;
					y = temp_y;
				}
			}
		}

		Calc_movement();
		anim();
	break;

	case PLAYERSTATE.DODGE:
		visible = true;
		image_alpha = 1;
		sprite_index = S_Player_Dodge;
		image_speed = 1;

		dodge_timer--;
		if (dodge_timer <= 0) {
			invincible = false;
			state = PLAYERSTATE.FREE;
		}
	break;

	case PLAYERSTATE.ATTACK_SLASH:
		Player_State_Attack_Slash(); 
	break;

	case PLAYERSTATE.ATTACK_COMBO:
		Player_State_Attack_Combo(); 
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
// □ボタンで攻撃
mouseAttack = mouse_check_button_pressed(mb_left) || gamepad_button_check_pressed(0, gp_face3);

if (mouseAttack && state != PLAYERSTATE.DEAD) {
	state = PLAYERSTATE.ATTACK_SLASH;
}
mouseAttack = false;