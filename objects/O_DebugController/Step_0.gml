// デバッグルーム限定でAIのオン/オフを切り替える
if (room_get_name(room) == "Rm_Debug") {
    // Pキーが押されたらAIフラグを反転（true⇔false）
    if (keyboard_check_pressed(ord("P"))) {
        global.enemyAIEnabled = !global.enemyAIEnabled;

        // オプション：ログを出力（確認用）
        show_debug_message("Enemy AI: " + string(global.enemyAIEnabled));
    }
}

// Oキーで弾の発射方向を切り替える（上→左→下→右→OFF）
if (keyboard_check_pressed(ord("O"))) {
    if (!variable_global_exists("enemyFireDirection")) {
        global.enemyFireDirection = -1;
    }

    global.enemyFireDirection = (global.enemyFireDirection + 1) mod 5;

    var dir_names = ["上", "左", "下", "右", "OFF"];
    show_debug_message("敵弾の発射方向を変更: " + dir_names[global.enemyFireDirection]);
}

// Tキーで一時停止のON/OFF切替
if (keyboard_check_pressed(ord("T"))) {
    global.gamePaused = !global.gamePaused;
    global.stepAdvance = false; // OFF直後のYキーを無効にする
    show_debug_message("ゲーム " + (global.gamePaused ? "一時停止" : "再開"));
}

// Yキー短押し or 長押しで1フレーム進行（停止中のみ）
if (global.gamePaused) {
    if (keyboard_check_pressed(ord("Y"))) {
        // 短押し：押した瞬間に1フレーム進行
        global.stepAdvance = true;
        global.stepAdvanceTimer = 0;
        show_debug_message("▶ 1フレーム進行（stepAdvance = true）");
    } else if (keyboard_check(ord("Y"))) {
        // 長押し：押しっぱなしで間隔付き進行
        global.stepAdvanceTimer++;
        if (global.stepAdvanceTimer > 15 && global.stepAdvanceTimer mod 4 == 0) {
            global.stepAdvance = true;
            show_debug_message("▶ 1フレーム進行（stepAdvance = true）");
        } else {
            global.stepAdvance = false;
        }
    } else {
        // Yキーが離されたとき
        global.stepAdvanceTimer = 0;
        global.stepAdvance = false;
    }
}