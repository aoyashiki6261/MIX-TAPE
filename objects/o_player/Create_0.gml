event_inherited();
walk_spd = 0.5;

sprite_index = S_Player_Idle;

cursor_sprite = S_Cursor;
window_set_cursor(cr_none);

state = PLAYERSTATE.FREE;

//攻撃関連
mouseAttack = false;
hitByAttack = ds_list_create();

death_timer = 0;
deadanimstarted = false;

//緊急回避関連
dodge_duration = 5;           // 無敵＋移動が続くフレーム数
dodge_cooldown_max = 14;        // クールダウンの長さ（60 = 1秒）
dodge_cooldown = 0;             // カウントダウン管理用
dodge_timer = 0;                // 残り回避フレーム
invincible = false;            // 無敵状態かどうか
dodge_distance = 40; // プレイヤーの幅分移動
dash = false;

facing_dir = 0;                 // 向き

enum PLAYERSTATE{
	FREE,
	ATTACK_SLASH,
	ATTACK_COMBO,
	DEAD,
	DODGE
}