var keyAttack = keyboard_check_pressed(ord("H")) || keyboard_check_pressed(ord("Z"));

reset_variables();

get_input();

Calc_movement();

switch(state)
{
	case PLAYERSTATE.FREE: PlayerState_Free(); break;
	case PLAYERSTATE.ATTACK_SLASH: PlayerState_Attack_Slash(); break;
	case PLAYERSTATE.ATTACK_COMBO: PlayerState_Attack_Combo(); break;

}

