// すでに開始処理中なら何もしない
if (started) exit;

// 点滅アニメ用
blink_timer++;
if (blink_timer > 30) { // 30フレームごとにON/OFF
    blink_timer = 0;
    press_visible = !press_visible;
}

// --- 入力チェック（どれか押されたらゲーム開始） ---
var start_pressed = false;

// キーボード
if (keyboard_check_pressed(vk_enter))  start_pressed = true; // Enter
if (keyboard_check_pressed(vk_space))  start_pressed = true; // Space
if (keyboard_check_pressed(ord("Z")))  start_pressed = true; // Zキーなど

// ゲームパッド（1P: index 0）
if (gamepad_is_connected(0)) {
    if (gamepad_button_check_pressed(0, gp_face1)) start_pressed = true; // A / × 相当
    if (gamepad_button_check_pressed(0, gp_start)) start_pressed = true; // STARTボタン
}

if (start_pressed) {
    started = true;

    // ★ ゲーム開始前に各種グローバルを初期化（必要に応じて）
    if (variable_global_exists("kills"))             global.kills             = 0;
    if (variable_global_exists("gamePaused"))        global.gamePaused        = false;
    if (variable_global_exists("stepAdvance"))       global.stepAdvance       = false;
    if (variable_global_exists("enemyAIEnabled"))    global.enemyAIEnabled    = true;
    if (variable_global_exists("enemyFireDirection")) global.enemyFireDirection = 4;

    // ★ 実際のゲームルームへ移動
    // ここを「普段遊んでいるルーム」の名前に変えてください
    room_goto(Rm_Main); // 例：Rm_Game / Rm_Stage1 など
}