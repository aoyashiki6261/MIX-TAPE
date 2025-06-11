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
dodge_speed = 0;       // 毎フレームの移動距離
dodge_timer = 0;                // 残り回避フレーム
dodge_distance = 65; // プレイヤーの幅分移動
dodge_dir = 0;         // 緊急回避の方向（angle）
invincible = false;            // 無敵状態かどうか
dash = false;


facing_dir = 0;                 // 向き



is_space_down = false;
was_space_down = false;
pressed_space = false;

is_pad_down = false;
was_pad_down = false;
pressed_pad = false;
is_attack_down = false;
was_attack_down = false;

enum PLAYERSTATE{
	FREE,
	ATTACK_SLASH,
	ATTACK_COMBO,
	DEAD,
	DODGE
}