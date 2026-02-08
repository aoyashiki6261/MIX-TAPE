// Inherit the parent event
event_inherited();

// スプライトの割り当て
S_Idle   = S_Enemy_Idle;
S_Walk   = S_Enemy_Walk;
S_Attack = S_Enemy_Charge;
S_Dead   = S_Enemy_Dead;
S_Hit    = S_Enemy_Hit;

draw_scale = 1; // スプライトサイズ

orig_blend = image_blend;  // ← 元のブレンド色を保存

hsp = 0;
vsp = 0;
xp  = x;
yp  = y;
facing = 1;

// ★ 基本速度はマクロから
spd = ENEMY_BOW_BASE_SPEED;

dir  = 0;
face = 1;
death_timer = 0;
kill_counted = false;   // 敵のキルカウントの定義
knockback_time  = 0;   // show_hurt() の knockback_time-- 用

//プレイヤーに向かう
calc_path_timer = 0;                // 最初からプレイヤーをチェックさせるため0で初期化(プレイヤーに向かってくるためのチェックタイマー)
calc_path_delay = ENEMY_PATH_DELAY_BOW; // 何フレームに1回パスを再計算するか(プレイヤーに向かってくるためのチェックを何フレームの頻度で行うか)

// ★ 弓兵固有の攻撃距離
attack_dis      = ENEMY_BOW_ATTACK_DISTANCE;  //★近づいたら攻撃に遷移する距離

path = path_add();
path_speed   = spd;
path_position = 0;

//ステートマシン
state = 0;

cooldownTime  = ENEMY_COOLDOWN_TIME_FRAMES;
cooldownTimer = cooldownTime; // ★最初の攻撃だけ即可能にする（最初から満タン）
shootTimer    = 0;// ★注意：shootTimer は ATTACK の「溜め/発射/硬直」用なので、ここでは触らない

// ★次に攻撃できるまでのクールダウン
cooldown_timer = irandom(ENEMY_COOLDOWN_TIME_FRAMES);

//★矢を撃つまでの構える時間
windupTime   = ENEMY_WINDUP_TIME;

//★矢を撃った後の硬直時間
recoverTime  = ENEMY_RECOVER_TIME;

ballInst = noone;
myball   = noone; // 敵ごとに発射中の矢を記録する用
ballXoff = 5;
ballYoff = -8;

// ★ 右向き用の攻撃シグナル出現位置
signal_offset_right_x = ENEMY_SIGNAL_OFFSET_RIGHT_X;   // 右方向
signal_offset_right_y = ENEMY_SIGNAL_OFFSET_RIGHT_Y;   // 上方向

// ★ 左向き用攻撃シグナル出現位置
signal_offset_left_x  = ENEMY_SIGNAL_OFFSET_LEFT_X;    // 左方向
signal_offset_left_y  = ENEMY_SIGNAL_OFFSET_LEFT_Y;    // 上方向

// ★ シグナルを出し始める shootTimer の値
signal_start_frame = ENEMY_SIGNAL_START_FRAME;

// ★ 右向き用の矢の出現位置
arrow_offset_right_x = ENEMY_ARROW_OFFSET_RIGHT_X;
arrow_offset_right_y = ENEMY_ARROW_OFFSET_RIGHT_Y;

// ★ 左向き用の矢の出現位置
arrow_offset_left_x  = ENEMY_ARROW_OFFSET_LEFT_X;
arrow_offset_left_y  = ENEMY_ARROW_OFFSET_LEFT_Y;

// 手元からちょっと前に矢を出す距離
arrow_forward   = ENEMY_ARROW_FORWARD;

// 攻撃シグナル用
attack_signal = noone;
