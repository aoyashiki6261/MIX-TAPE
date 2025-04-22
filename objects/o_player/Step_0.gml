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
			
			// 最終入力方向へ緊急回避
			var dir = point_direction(0, 0, right - left, down - up);
			x += lengthdir_x(dodge_distance, dir);
			y += lengthdir_y(dodge_distance, dir);

			sprite_index = S_Player_Dodge;
			image_index = 0;
			image_speed = 1;
			break;
		}

		if (mouse_check_button_pressed(mb_left)) {
			state = PLAYERSTATE.ATTACK_SLASH;
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
mouseAttack = mouse_check_button_pressed(mb_left);

if (mouseAttack && state != PLAYERSTATE.DEAD) {
	state = PLAYERSTATE.ATTACK_SLASH;
}
mouseAttack = false;