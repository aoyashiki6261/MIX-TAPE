draw_set_font(Fnt_Ui);

// ★ 当たり判定デバッグ表示フラグの安全初期化（これは参照のみ）
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

// ✅ Drawイベントでは global 初期化は行わず、参照だけにする
var status_ai    = global.enemyAIEnabled ? "ON" : "OFF";
var status_fire  = "OFF";
switch (global.enemyFireDirection) {
    case 0: status_fire = "UP"; break;
    case 1: status_fire = "LEFT"; break;
    case 2: status_fire = "DOWN"; break;
    case 3: status_fire = "RIGHT"; break;
    case 4: status_fire = "OFF"; break;
}
var status_pause = global.gamePaused ? "PAUSE" : "PLAY";
var status_step  = global.stepAdvance ? "" : "1frame";

// ✅ デバッグルームでのみ表示 + 右スティック押し込みデバッグONのときのみ表示
if (room_get_name(room) == "Rm_Debug" && global.gamepadDebugEnabled) {

    var text_ai        = "[ZR button(Pkey)_EnemyAI: " + status_ai + "]";
    var text_fire      = "[ZL button(Okey)_EnemyFire: " + status_fire + "]";
    var text_pause     = "[L button(Tkey)_Pause: " + status_pause + "]";
    var text_stepadvance = "[R button(Ykey)_StepAdvance: " + status_step + "]";

    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);

    var base_y = room_height + 420;

    draw_set_color(global.stepAdvance ? c_red : c_green);
    draw_text(0, base_y, text_stepadvance);

    draw_set_color(global.gamePaused ? c_red : c_green);
    draw_text(0, base_y + 20, text_pause);

    draw_set_color(global.enemyFireDirection != 4 ? c_red : c_green);
    draw_text(0, base_y + 40, text_fire);

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
    var xx_dbg = display_get_gui_width() - 80;
    var yy_dbg = 20;
    var txt_dbg = string(global.kills);
    var scale_ui_dbg = 2.0;

    draw_set_color(c_black);
    draw_text_transformed(xx_dbg+2, yy_dbg+2, txt_dbg, scale_ui_dbg, scale_ui_dbg, 0);
    draw_set_color(c_white);
    draw_text_transformed(xx_dbg, yy_dbg, txt_dbg, scale_ui_dbg, scale_ui_dbg, 0);
}

// 以下はキルカウンターの描画設定（常に表示）
{
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var gw = display_get_gui_width();
    if (gw <= 0) gw = room_width;
    var xx = gw * 0.5;
    var yy = 20;

    var txt = string(global.kills);
    var scale_ui = 4.0;

    draw_set_color(c_black);
    draw_text_transformed(xx+2, yy+2, txt, scale_ui, scale_ui, 0);
    draw_set_color(c_white);
    draw_text_transformed(xx, yy, txt, scale_ui, scale_ui, 0);
}

// ★ GAME OVER オーバーレイの描画
if (variable_global_exists("gameOver") && global.gameOver) {

    var gw_go = display_get_gui_width();
    var gh_go = display_get_gui_height();

    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw_go, gh_go, false);
    draw_set_alpha(1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);

    draw_set_font(Fnt_GameOver);
    draw_text(gw_go * 0.5, gh_go * 0.4, "GAME OVER");

    draw_set_font(Fnt_Ui);
    draw_text(gw_go * 0.5, gh_go * 0.6, "PRESS START");
}
