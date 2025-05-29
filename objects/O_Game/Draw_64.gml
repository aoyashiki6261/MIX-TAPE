// ✅ 未定義の変数を安全に初期化（必ずDrawイベントの最上部で）
if (!variable_global_exists("enemyFireDirection")) {
    global.enemyFireDirection = 4; // OFF（初期状態）
}
if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;
}

// ✅ デバッグルームでのみ表示
if (room_get_name(room) == "Rm_Debug") {

    // 敵AIのON/OFF表示
    var status = global.enemyAIEnabled ? "ON" : "OFF";
    var text_ai = "[Pkey_EnemyAI: " + status + "]";

    // 固定発射方向の状態表示
    var fire_status = "OFF";
    switch (global.enemyFireDirection) {
        case 0: fire_status = "UP"; break;
        case 1: fire_status = "LEFT"; break;
        case 2: fire_status = "DOWN"; break;
        case 3: fire_status = "RIGHT"; break;
        case 4: fire_status = "OFF"; break;
    }
    var text_fire = "[Okey_EnemyFire: " + fire_status + "]";

    // ポーズ状態（Tキー）表示
    var pause_status = global.gamePaused ? "PAUSE" : "PLAY";
    var text_pause = "[Tkey_Pause: " + pause_status + "]";

    // 共通描画設定
    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);

    // 描画位置設定（左下から順に）
    var base_y = room_height + 440; // 一番下の行から上に積む

    // 1. ポーズ状態
    draw_set_color(global.gamePaused ? c_red : c_green);
    draw_text(0, base_y, text_pause);

    // 2. 固定発射方向
    draw_set_color(c_green);
    draw_text(0, base_y + 20, text_fire);

    // 3. 敵AI状態
    draw_text(0, base_y + 40, text_ai);
}