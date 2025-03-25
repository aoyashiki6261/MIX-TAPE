switch(state){
	case states.IDLE:
		calc_entity_movement();
		Check_For_Player();
		if path_index != -1 state = states.MOVE;
		Enemy_anim();
	break;
	case states.MOVE:
		calc_entity_movement();
		Check_For_Player();
		check_facing();
		if path_index == -1 state = states.IDLE;
		Enemy_anim();
	break;
	case states.ATTACK:
		calc_entity_movement();
		Enemy_anim();
	break
	case states.DEAD:
		calc_entity_movement();
		Enemy_anim();
	break;
}