// Inherit the parent event
event_inherited();

dir = 0;
spd = 4.5;
hsp = 0;
vsp = 0;

//ステートコントロール
state =0;
//「ステート０」は弾を停止、敵が打つまで待機の状態
//「ステート１」はプレイヤーに向かって弾が移動

//クリーンアップ
destroy = false;
playerDestroy = true;

