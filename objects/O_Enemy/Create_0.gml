// Inherit the parent event
event_inherited();

//スプライトの割り当て
S_Idle = S_Enemy_Idle;
S_Walk = S_Enemy_Walk;
S_Attack = S_Enemy_Attack;
S_Dead = S_Enemy_Dead;
S_Hit = S_Enemy_Hit;

orig_blend = image_blend;  // ← 元のブレンド色を保存

hsp = 0;
vsp = 0;
xp  = x;
yp  = y;
facing = 1;
spd = 0.35;
dir = 0;
face = 1;
death_timer = 0;
knockback_time  = 0;   // show_hurt() の knockback_time-- 用

//プレイヤーに向かう
calc_path_timer = 0; // 最初からプレイヤーをチェックさせるため0で初期化(プレイヤーに向かってくるためのチェックタイマー)
calc_path_delay = 15; // 何フレームに1回パスを再計算するか(プレイヤーに向かってくるためのチェックを何フレームの頻度で行うか)
attack_dis      = 120;  //★近づいたら攻撃に遷移する距離

path = path_add();
path_speed = spd;
path_position = 0;

//ステートマシン
state = 0;
	//弾の発射ステータス
	cooldownTime = 4*60;
	shootTimer = irandom(cooldownTime);
	windupTime = 90; //★弾を撃つまでの構える時間
	recoverTime = 120; //★弾を撃った後の硬直時間
	ballInst = noone;
	myball = noone; // 敵ごとに発射中の弾を記録する用
	ballXoff = 5;
	ballYoff = -8;




