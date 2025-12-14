/// O_Game Step

// ------- セーフティ：グローバル変数の存在確認（保険） -------

// 敵AI ON/OFFフラグ
if (!variable_global_exists("enemyAIEnabled")) {
    global.enemyAIEnabled = true;
}

// 一時停止・1フレーム進行まわり
if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;
}
if (!variable_global_exists("stepAdvance")) {
    global.stepAdvance = false;
}
if (!variable_global_exists("stepAdvanceFrames")) {
    global.stepAdvanceFrames = 0;
}
if (!variable_global_exists("stepAdvanceTimer")) {
    global.stepAdvanceTimer = 0;
}

// 固定発射方向
if (!variable_global_exists("enemyFireDirection")) {
    global.enemyFireDirection = 4; // OFF
}

// -----------------------------
// －キー / コントローラの minus でヒットボックス可視化 ON/OFF
// -----------------------------
if (gamepad_button_check_pressed(0, gp_select)) { //－ボタン
    global.debugShowHitbox = !global.debugShowHitbox;
    show_debug_message("Debug Hitbox: " + string(global.debugShowHitbox));
}

// ゲームパッドデバッグフラグ（R3でトグル）
// ※ ここでは「存在確認」だけ。トグルは O_debugcontroller 側で行う
if (!variable_global_exists("gamepadDebugEnabled")) {
    global.gamepadDebugEnabled = false;
}

// キルカウンタ
if (!variable_global_exists("kills")) {
    global.kills = 0;
}

// GAME OVER
if (!variable_global_exists("gameOver")) {
    global.gameOver = false;
}

// ------- リスタート（Rキー / Startボタン） -------
if (keyboard_check_pressed(ord("R"))
    || gamepad_button_check_pressed(0, gp_start)) {

    // ★ 共通リセット関数にまとめる
    Game_Reset_NewGame(false); // false = 現在のルームを再スタート
}
