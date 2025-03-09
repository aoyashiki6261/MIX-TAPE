walk_spd = 1.5;
facing = 1;

sprite_index = S_Player_Idle;

cursor_sprite = S_Cursor;
window_set_cursor(cr_none);

state = PLAYERSTATE.FREE;
hitByAttack = ds_list_create()


enum PLAYERSTATE
{
	FREE,
	ATTACK_SLASH,
	ATTACK_COMBO

}