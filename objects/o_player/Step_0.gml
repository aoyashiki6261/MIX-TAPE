function reset_variables(){
	left = 0;
	right = 0;
	up = 0;
	down = 0;
	vmome = 0;
	hmove = 0;
}

function get_input(){
	if keyboard_check(ord("A"))	left	=	1;
	if keyboard_check(ord("D"))	right	=	1;
	if keyboard_check(ord("W"))	up		=	1;
	if keyboard_check(ord("S"))	down	=	1;
	if keyboard_check_pressed(vk_space) dash = true;
}



switch(state)
	{
		case PLAYERSTATE.FREE: Player_State_Free();reset_variables();
		if (mouse_check_button_pressed(mb_left)) {
		state = PLAYERSTATE.ATTACK_SLASH;
		}
		get_input();
		Calc_movement();
		anim();
	break;
		case PLAYERSTATE.ATTACK_SLASH: Player_State_Attack_Slash(); 
	break;
		
		case PLAYERSTATE.ATTACK_COMBO: Player_State_Attack_Combo(); 
	break;
	
	    case PLAYERSTATE.DEAD:
        hSpeed = 0; // 死亡処理
        vSpeed = 0;
      if (!deadanimstarted) {
        sprite_index = S_Player_Dead;
        image_index = 0;
        image_speed = 1; // 死亡時のアニメーションの速度
        deadanimstarted = true;
    }

        // 必要ならタイマーで削除やリスタートへ
        death_timer++;
        if (death_timer > 900) //プレイヤーが死んだ時に消えるまでのカウント
		{
            instance_destroy(); // 一定時間後に消える
	    }
    break;
}


	if (mouse_check_button_pressed(mb_left)) {
    mouseAttack = true;
	} else {
    mouseAttack = false;
	}

	if (mouseAttack && state != PLAYERSTATE.DEAD) {
    state = PLAYERSTATE.ATTACK_SLASH;
}
	mouseAttack = false;  // 攻撃状態をリセット
	
	