// Inherit the parent event
event_inherited();

draw_scale = 0.5; // スプライトサイズを縮小して表示
mask_index = S_Arrow_Mask;  // 当たり判定の設定

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

mask_index = S_Arrow_Mask;	//スプライトから当たり判定の設定

image_angle = dir;	//角度を見た目にも反映