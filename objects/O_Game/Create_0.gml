/// O_Game Create

// -----------------------------
// グローバル状態の初期化
// -----------------------------

// 敵の固定発射方向（デバッグ）初期値
if (!variable_global_exists("enemyFireDirection")) {
    global.enemyFireDirection = 4; // 0:UP,1:LEFT,2:DOWN,3:RIGHT,4:OFF
}

// 一時停止・1フレーム進行まわり
if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;
}
if (!variable_global_exists("stepAdvance")) {
    global.stepAdvance = false;
}
if (!variable_global_exists("stepAdvanceTimer")) {
    global.stepAdvanceTimer = 0;
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
	
// ワープゾーンのテキスト表示フラグ
if (!variable_global_exists("warpZoneHint")) {
    global.warpZoneHint = false;
}
}

// GUIをウィンドウサイズにフィット（任意）
display_set_gui_maximize();


// -----------------------------
// New Game相当の初期化（キル数リセット＋シーン切替）
// -----------------------------
/// @description New Game相当の初期化（キル数リセット＋シーン切替）
function Game_Reset_NewGame(_go_first_room = false) {
    // ★ キルカウンタとゲームオーバーをリセット
    global.kills     = 0;
    global.killCount = 0;
    global.gameOver  = false;

    // ★ 好みのリセット動作を選択
    if (_go_first_room) {
        room_goto(Rm_Main);
    } else {
        // 現在のルームを再スタート
        room_restart();
    }
}
