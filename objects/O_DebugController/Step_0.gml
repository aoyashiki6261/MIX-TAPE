// -----------------------------
// デバッグルーム以外では処理を無効化 & 一時停止解除
// -----------------------------
if (room_get_name(room) != "Rm_Debug") {
    // デバッグルームを離れたら一時停止状態をリセット
    global.gamePaused       = false;
    global.stepAdvance      = false;
    global.stepAdvanceFrames = 0;
    global.stepAdvanceTimer  = 0;
    exit; 
}

// -----------------------------
// Pキー / ZR：敵AI ON/OFF（デバッグルーム限定）
// -----------------------------
if (keyboard_check_pressed(ord("P"))
 || (global.gamepadDebugEnabled && gamepad_button_check_pressed(0, gp_shoulderrb))) { // ZR
    global.enemyAIEnabled = !global.enemyAIEnabled;
}

// -----------------------------
// Oキー / ZL：固定発射方向の切替（全ルーム共通でOK）
// -----------------------------
if (keyboard_check_pressed(ord("O"))
 || (global.gamepadDebugEnabled && gamepad_button_check_pressed(0, gp_shoulderlb))) { // ZL
    global.enemyFireDirection = (global.enemyFireDirection + 1) mod 5;
    var dir_names = ["上", "左", "下", "右", "OFF"];
}

// -----------------------------
// Tキー / L1：一時停止 ON/OFF
// -----------------------------
if (keyboard_check_pressed(ord("T"))
 || (global.gamepadDebugEnabled && gamepad_button_check_pressed(0, gp_shoulderl))) { // L1

    global.gamePaused = !global.gamePaused;

    if (!global.gamePaused) {
        // ポーズ解除時にコマ送り関連をクリア
        global.stepAdvance       = false;
        global.stepAdvanceFrames = 0;
        global.stepAdvanceTimer  = 0;
    }
}

// -----------------------------
// Yキー / R1：1フレーム進行の「予約」
//   → 実際に stepAdvance を true にするのは O_Game Begin Step
// -----------------------------
if (global.gamePaused) {

    // 1) 短押し：押した瞬間に 1 フレーム分だけ予約
    if (keyboard_check_pressed(ord("Y"))
     || (global.gamepadDebugEnabled && gamepad_button_check_pressed(0, gp_shoulderr))) { // R1 短押し

        global.stepAdvanceFrames += 1;
        global.stepAdvanceTimer   = 0;
    }
    // 2) 長押し：一定時間後、数フレームごとに追加予約
    else if (keyboard_check(ord("Y"))
     || (global.gamepadDebugEnabled && gamepad_button_check(0, gp_shoulderr))) { // R1 長押し

        global.stepAdvanceTimer++;
        if (global.stepAdvanceTimer > 15 && global.stepAdvanceTimer mod 4 == 0) {
            global.stepAdvanceFrames += 1;
        }
    }
    // 3) Y / R1 を離したらタイマーだけリセット
    else {
        global.stepAdvanceTimer = 0;
    }
}

// -----------------------------
// R3：ゲームパッドデバッグ ON/OFF トグル
// -----------------------------
if (gamepad_button_check_pressed(0, gp_stickr)) {
    global.gamepadDebugEnabled = !global.gamepadDebugEnabled;
}
