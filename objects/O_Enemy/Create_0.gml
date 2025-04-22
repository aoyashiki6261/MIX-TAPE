// Inherit the parent event
event_inherited();

//assign sprites
S_Idle = S_Enemy_Idle;
S_Walk = S_Enemy_Walk;
S_Attack = S_Enemy_Attack;
S_Dead = S_Enemy_Dead;
S_Hit = S_Enemy_Hit;


spd = .5;
chaseSpd = .5;
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
	windupTime = 60;
	recoverTime = 45;
	ballInst = noone;
	myball = noone; // 敵ごとに発射中の弾を記録する用
	ballXoff = 5;
	ballYoff = -8;


//スポーン時に mp_grid 内かデバッグ
var _cx = x div TS;
var _cy = y div TS;
if (!mp_grid_get_cell(global.mp_grid, _cx, _cy)) {
    show_debug_message("スポーン位置がグリッドに塞がれています: " + string(_cx) + "," + string(_cy));
}
		
