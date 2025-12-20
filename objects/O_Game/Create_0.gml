/// O_Game Create

// -----------------------------
// グローバル状態の初期化
// -----------------------------

//プレイヤー死亡時のフラグ
if (!variable_global_exists("playerDead")) {
    global.playerDead = false;
}

// キルカウンタ
if (!variable_global_exists("kills")) {
    global.kills = 0;
}

// GAME OVERフラグ
if (!variable_global_exists("gameOver")) {
    global.gameOver = false;
}

//当たり判定デバッグ表示フラグ
if (!variable_global_exists("debugShowHitbox")) {
    global.debugShowHitbox = false;
}

// 任意：古い killCount も使っているならセーフティ初期化
if (!variable_global_exists("killCount")) {
    global.killCount = 0;
}

// デバッグ用ヒットボックス表示フラグ（プレイヤー攻撃 & 敵ボディ共通）
if (!variable_global_exists("debugShowHitbox")) {
    global.debugShowHitbox = false;
}

// GUIをウィンドウサイズにフィット（任意）
display_set_gui_maximize();


// -----------------------------
// New Game相当の初期化（キル数リセット＋シーン切替）
// -----------------------------
/// @description New Game相当の初期化（キル数リセット＋シーン切替）
function Game_Reset_NewGame(_go_first_room = false) {

    // ★ ゲーム進行だけリセット
    global.playerDead = false;
    global.gameOver   = false;

    global.kills     = 0;
    global.killCount = 0;

    if (_go_first_room) {
        room_goto(Rm_Main);
    } else {
        room_restart();
    }

	global.game_pause = false;
	global.do_step = true;
	game_set_speed(60, gamespeed_fps);
}

