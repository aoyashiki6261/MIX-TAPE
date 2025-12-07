// AIの有効/無効を制御するグローバル変数を初期化
if (!variable_global_exists("enemyAIEnabled")) {
    global.enemyAIEnabled = true;
}

//フレームコマ送りの初期化
global.gamePaused = false;         // 一時停止フラグ
global.advanceOneFrame = false;    // 1フレームだけ進めるフラグ

if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;
}
if (!variable_global_exists("stepAdvance")) {
    global.stepAdvance = false;
	
global.kills = 0;                 // 新規ゲーム開始で 0 にリセット
#macro KILL_MAX 9999              //★ 上限	
display_set_gui_maximize(); // GUIサイズをウィンドウに合わせる（安全策）

/// @description New Game相当の初期化（キル数リセット＋シーン切替）
function Game_Reset_NewGame(_go_first_room = false) {
    // ★ キルカウンタを0へ
    global.kills = 0;

    // ★ 好みのリセット動作を選択
    if (_go_first_room) {
        room_goto(Rm_Main);
    } else {
        // 現在のルームを再スタート
        room_restart();
    }
}
	
}
global.killCount = 0;
global.gameOver = false;