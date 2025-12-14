draw_set_font(Fnt_Ui);

// ★ 当たり判定デバッグ表示フラグの安全初期化
if (!variable_global_exists("debugShowHitbox")) {
    global.debugShowHitbox = false;
}

// ★ 当たり判定可視化モード中だけ、右上にテキスト表示
if (global.debugShowHitbox) {
    var gw_hit = display_get_gui_width();
    var margin = 8;

    draw_set_halign(fa_right);   // 右上
    draw_set_valign(fa_top);
    draw_set_color(c_yellow);

    draw_text(gw_hit - margin, 4, "HITBOX DEBUG: ON");
}

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
    
    //キルカウンターのテキスト表示（小さめ）
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

/// --- ここから：ワープゾーンのテキスト表示（デバッグ用） ---
/// プレイヤーが O_WarpZone に触れているときだけ、L3 でワープできることを表示
{
    var warp_hint = false;

    // プレイヤーとワープゾーンが存在するか確認
    if (instance_exists(O_Player) && instance_exists(O_WarpZone)) {

        // プレイヤーは 1 体想定なので、先頭インスタンスを取得
        var p = instance_find(O_Player, 0);

        if (p != noone) {
            // プレイヤー座標で O_WarpZone に当たっているかどうか
            if (instance_place(p.x, p.y, O_WarpZone) != noone) {
                warp_hint = true;
            }
        }
    }

    // 触れている場合だけテキストを描画
	if (global.warpZoneHint) {
	    var gw  = display_get_gui_width();
	    var gh  = display_get_gui_height();
	    var msg = "[L3 button : warp zone]";

	    draw_set_font(Fnt_Ui);

	    // 画面中央下に表示
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_bottom);

	    // 影付きで見やすく
	    draw_set_color(c_black);
	    draw_text(gw * 0.5 + 2, gh - 42, msg);
	    draw_set_color(c_white);
	    draw_text(gw * 0.5,     gh - 44, msg);
	}
}

//以下はキルカウンターの描画設定（常に表示）
{
    // セーフティ：描画状態をリセット
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var gw = display_get_gui_width();
    if (gw <= 0) gw = room_width; // 念のためフォールバック
    var xx = gw * 0.5;            //★ 画面中央上
    var yy = 20;                  //★ 表示位置Y

    var txt = string(global.kills);
    var scale_ui = 4.0;           // ★ 拡大倍率（ここを変えれば一括で大きさ調整）

    // 影付きで見やすく（拡大描画）
    draw_set_color(c_black);
    draw_text_transformed(xx+2, yy+2, txt, scale_ui, scale_ui, 0);
    draw_set_color(c_white);
    draw_text_transformed(xx, yy, txt, scale_ui, scale_ui, 0);
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
