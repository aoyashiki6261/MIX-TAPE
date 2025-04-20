event_inherited();
get_damaged_create();

hp_max = 1
hp = hp_max;
//プレイヤーを追いかけているのか？
alert = false;

//プレイヤーを追いかけ始める距離
alert_dis = 160;

//プレイヤーから停止する距離を設定
attack_dis = 18;

//プレイヤーを追いかける速度
move_spd = 1;

//パスリソースを作成
path = path_add();

//パス計算の遅延を設定
calc_path_delay = 30;

//パスを計算するときにタイマーを設定
calc_path_timer = irandom(60);