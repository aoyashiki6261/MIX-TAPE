event_inherited();
get_damaged_create();

hp_max = 1;
hp = hp_max;

// プレイヤーを追いかけているのか？
alert = false;

// プレイヤーを追いかけ始める距離
alert_dis = 16;

// プレイヤーから停止する距離を設定
attack_dis = 150;

// プレイヤーを追いかける速度
spd = 0.5;

// パスリソースを作成 → 事前に用意した GameMakerの path リソースを使用するように変更
path = path_add(); // ← 動的に作らず、静的に用意したリソースを使用

// パス計算の遅延を設定
calc_path_delay = 30;

// パスを計算するときにタイマーを設定
calc_path_timer = irandom(60);

// パス移動を有効にするための初期設定（GameMakerに移動させてもらう）
path_position = 0;
path_speed = spd;

kill_counted = false;   // 敵のキルカウントの定義