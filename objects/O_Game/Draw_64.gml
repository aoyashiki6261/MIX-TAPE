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
    draw_text(0, room_height + 480, "[R3 button : debug mode]");
    
    //キルカウンターのテキスト表示
    var xx_dbg = display_get_gui_width() - 80;  //★ 右上表示のX
    var yy_dbg = 20;                             //★ Y
    var txt_dbg = string(global.kills);
    var scale_ui_dbg = 2.0;                      // ★ 拡大倍率（1=等倍, 2=2倍 など）

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
    var xx = gw - 570;             //★ 表示位置X
    var yy = 20;                  //★ 表示位置Y

    var txt = string(global.kills);
    var scale_ui = 4.0;           // ★ 拡大倍率（ここを変えれば一括で大きさ調整）

    // 影付きで見やすく（拡大描画）
    draw_set_color(c_black);
    draw_text_transformed(xx+2, yy+2, txt, scale_ui, scale_ui, 0);
    draw_set_color(c_white);
    draw_text_transformed(xx, yy, txt, scale_ui, scale_ui, 0);
}
