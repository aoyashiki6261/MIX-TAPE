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
	
		
