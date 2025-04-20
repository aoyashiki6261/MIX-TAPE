event_inherited();
walk_spd = 1.5;

sprite_index = S_Player_Idle;

cursor_sprite = S_Cursor;
window_set_cursor(cr_none);

state = PLAYERSTATE.FREE;
mouseAttack = false;
hitByAttack = ds_list_create();
death_timer = 0;
deadanimstarted = false;

enum PLAYERSTATE{
	FREE,
	ATTACK_SLASH,
	ATTACK_COMBO,
	DEAD
}