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



switch(state){
		case PLAYERSTATE.FREE: Player_State_Free();reset_variables();
		get_input();
		Calc_movement();
		anim();
	break;
		case PLAYERSTATE.ATTACK_SLASH: Player_State_Attack_Slash(); break;
		case PLAYERSTATE.ATTACK_COMBO: Player_State_Attack_Combo(); break;
	
	
}