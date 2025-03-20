switch(state){
	case states.IDLE:
		Check_For_Player();
		if path_index != -1 state = states.MOVE;
		Enemy_anim();
	break;
	case states.MOVE:
		Check_For_Player();
		check_facing();
		if path_index == -1 state = states.IDLE;
		Enemy_anim();
	break;
	case states.ATTACK:
		Enemy_anim();
	break
	case states.DEAD:
		Enemy_anim();
	break;
}