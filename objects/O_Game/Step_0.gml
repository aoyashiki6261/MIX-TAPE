// 実行制御用の初期化（Createイベントで実行）
if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;
}
if (!variable_global_exists("stepAdvance")) {
    global.stepAdvance = false;
}
// ★ キルカウンター未定義対策
if (!variable_global_exists("kills")) {
    global.kills = 0;
}

// Rキー押下でリスタート
if (keyboard_check_pressed(ord("R"))) {
    global.kills = 0;   // ★ リセット時にキル数を0へ
    game_restart();
}

// コントローラーの＋ボタン（Start）でもリスタート
if (gamepad_button_check_pressed(0, gp_start)) {
    global.kills = 0;   // ★ リセット時にキル数を0へ
    game_restart();
}
