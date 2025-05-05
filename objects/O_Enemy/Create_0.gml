// Inherit the parent event
event_inherited();

//スプライトの割り当て
S_Idle = S_Enemy_Idle;
S_Walk = S_Enemy_Walk;
S_Attack = S_Enemy_Attack;
S_Dead = S_Enemy_Dead;
S_Hit = S_Enemy_Hit;


spd = 0.3;
dir = 0;
xspd = 0;
yspd = 0;
face = 1;
death_timer = 0;

//プレイヤーに向かう
calc_path_timer = 0; // 最初からプレイヤーをチェックさせるため0で初期化(プレイヤーに向かってくるためのチェックタイマー)
calc_path_delay = 15; // 何フレームに1回パスを再計算するか(プレイヤーに向かってくるためのチェックを何フレームの頻度で行うか)
path = path_add();

//ステートマシン
state = 0;
	//弾の発射ステータス
	cooldownTime = 4*60;
	shootTimer = irandom(cooldownTime);
	windupTime = 120; //弾を撃つまでの構える時間
	recoverTime = 120;
	ballInst = noone;
	myball = noone; // 敵ごとに発射中の弾を記録する用
	ballXoff = 5;
	ballYoff = -8;


// 【デバッグメッセージ】敵が障害物（O_Solid）と重なってスポーンしていないか確認。
var _cx = x div TS;
var _cy = y div TS;
if (mp_grid_get_cell(global.mp_grid, _cx, _cy) == false) {
    show_debug_message("スポーン位置が通れない: " + string(x) + "," + string(y));	
}