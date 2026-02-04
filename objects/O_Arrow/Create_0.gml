// Inherit the parent event
event_inherited();

draw_scale = 1; // スプライトサイズ

dir = 0;
spd = ARROW_SPEED;  // ★ マクロ化
hsp = 0;
vsp = 0;

//ステートコントロール
state =0;
//「ステート０」は弾を停止、敵が打つまで待機の状態
//「ステート１」はプレイヤーに向かって弾が移動

//クリーンアップ
destroy = false;
playerDestroy = true;

image_angle = dir;	//角度を見た目にも反映

mask_index = S_Arrow_Mask;

audio_play_sound(Snd_EnemyShot, 1, false)//発射音を流す