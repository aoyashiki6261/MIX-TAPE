// ✅ 未定義の変数を安全に初期化（必ずDrawイベントの最上部で）
if (!variable_global_exists("enemyFireDirection")) {
    global.enemyFireDirection = 4; // OFF（初期状態）
}
if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;
}
// ★ キルカウンタ用の安全初期化（ルーム開始直後でも落ちないように）
if (!variable_global_exists("kills")) {
    global.kills = 0;
}

// ★ 1フレーム進行フラグの安全初期化（念のため）
if (!variable_global_exists("stepAdvance")) {
    global.stepAdvance = false;
}

// ★ ゲームオーバーフラグの安全初期化
if (!variable_global_exists("gameOver")) {
    global.gameOver = false;
}

// ✅ デバッグルームでのみ表示 + 右スティック押し込みデバッグONのときのみ表示
if (room_get_name(room) == "Rm_Debug" && global.gamepadDebugEnabled) {

    // 敵AIのON/OFF表示
    var status = global.enemyAIEnabled ? "ON" : "OFF";
    var text_ai = "[ZR button(Pkey)_EnemyAI: " + status + "]";

    // 固定発射方向の状態表示
    var fire_status = "OFF";
    switch (global.enemyFireDirection) {
        case 0: fire_status = "UP"; break;
        case 1: fire_status = "LEFT"; break;
        case 2: fire_status = "DOWN"; break;
        case 3: fire_status = "RIGHT"; break;
        case 4: fire_status = "OFF"; break;
    }
    var text_fire = "[ZL button(Okey)_EnemyFire: " + fire_status + "]";

    // ポーズ状態（Tキー）表示
    var pause_status = global.gamePaused ? "PAUSE" : "PLAY";
    var text_pause = "[L button(Tkey)_Pause: " + pause_status + "]";

    // 1フレーム進行状態（Yキー / R1ボタン）表示
    var stepadvance_status = global.stepAdvance ? "" : "1frame";
    var text_stepadvance = "[R button(Ykey)_StepAdvance: " + stepadvance_status + "]";

    // 共通描画設定
    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);

    // ★ デバッグテキスト用にUIフォントを固定
    draw_set_font(Fnt_Ui);

    // 描画位置設定（左下から順に）
    var base_y = room_height + 420; // 一番下の行から上に積む

    // 1. 1フレーム進行状態
    draw_set_color(global.stepAdvance ? c_red : c_green);
    draw_text(0, base_y, text_stepadvance);

    // 2. ポーズ状態
    draw_set_color(global.gamePaused ? c_red : c_green);
    draw_text(0, base_y + 20, text_pause);

    // 3. 固定発射方向（OFF以外は赤字）
    draw_set_color(global.enemyFireDirection != 4 ? c_red : c_green);
    draw_text(0, base_y + 40, text_fire);

    // 4. 敵AI状態（OFFのときは赤字）
    draw_set_color(global.enemyAIEnabled ? c_green : c_red);
    draw_text(0, base_y + 60, text_ai);
}

// ✅ デバッグルームで右スティック押し込みOFFのときのみヒント表示
if (room_get_name(room) == "Rm_Debug" && !global.gamepadDebugEnabled) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);

    // ★ ここもUI用フォントを明示
    draw_set_font(Fnt_Ui);

    draw_text(0, room_height + 480, "[R3 button : debug mode]");
    
    //キルカウンターのテキスト表示
    var xx_dbg = display_get_gui_width() - 80;  //★ 右上表示のX
    var yy_dbg = 20;                             //★ Y
    var txt_dbg = string(global.kills);
    var scale_ui_dbg = 2.0;                      // ★ 拡大倍率（1=等倍, 2=2倍 など）

    // ★ デバッグ用のキル数表示はキルカウンタフォントに統一
    draw_set_font(Fnt_KillCounter);

    // 影付きで視認性アップ（拡大描画）
    draw_set_color(c_black);
    draw_text_transformed(xx_dbg+2, yy_dbg+2, txt_dbg, scale_ui_dbg, scale_ui_dbg, 0);
    draw_set_color(c_white);
    draw_text_transformed(xx_dbg, yy_dbg, txt_dbg, scale_ui_dbg, scale_ui_dbg, 0);
}

//以下はキルカウンターの描画設定
{
     // セーフティ：描画状態をリセット
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var gw = display_get_gui_width();
    if (gw <= 0) gw = room_width; // 念のためフォールバック
    var xx = gw - 680;             //★ 表示位置X
    var yy = 20;                  //★ 表示位置Y

    var txt = string(global.kills);
    var scale_ui = 1.0;           // ★ 拡大倍率（※今回は等倍にしてフォントサイズ側で調整）

    // ★ キルカウンター用フォントを使用
    draw_set_font(Fnt_KillCounter);

    // 影付きで見やすく（等倍描画）
    draw_set_color(c_black);
    draw_text(xx+2, yy+2, txt);   // 影
    draw_set_color(c_white);
    draw_text(xx, yy, txt);       // 本体
}

// ★ GAME OVER オーバーレイの描画（最後に描いて上からかぶせる）
if (variable_global_exists("gameOver") && global.gameOver) {

    var gw_go = display_get_gui_width();
    var gh_go = display_get_gui_height();

    // 画面全体をうっすら暗くする
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw_go, gh_go, false);
    draw_set_alpha(1);

    // テキスト描画設定
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);

    // ★ GAME OVER用フォントに切り替え
    draw_set_font(Fnt_GameOver);
	
	// GAME OVER（大きく中央に）
    var y_go_title = gh_go * 0.4;
    draw_text(gw_go * 0.5, y_go_title, "GAME OVER");

    // ★ PRESS STARTをUiフォントに切り替え
    draw_set_font(Fnt_Ui);

    // PRESS START
    var y_go_press = gh_go * 0.6;
    draw_text(gw_go * 0.5, y_go_press, "PRESS START");
}
