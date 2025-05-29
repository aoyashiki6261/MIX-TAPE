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
    show_debug_message("🔁 敵弾の発射方向を変更: " + dir_names[global.enemyFireDirection]);
}

// Tキー：時間の一時停止/再開
if (keyboard_check_pressed(ord("T"))) {
    global.gamePaused = !global.gamePaused;
    show_debug_message("ゲーム " + (global.gamePaused ? "一時停止" : "再開"));
}

// Yキー：停止中のみ、1フレームだけ進める
if (global.gamePaused && keyboard_check_pressed(ord("Y"))) {
    global.advanceOneFrame = true;
}