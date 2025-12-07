var gw = display_get_gui_width();
var gh = display_get_gui_height();

// 共通設定
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);

// ★ タイトル用フォント
draw_set_font(Fnt_Title); // 自分で作ったフォント名に合わせてください

// --- タイトル文字（日本語） ---
var scale_title = 1.5;           // タイトルの拡大倍率
var title_y     = gh * 0.3;      // タイトルのY位置

draw_text_transformed(gw * 0.5, title_y, "ゲームタイトル", scale_title, scale_title, 0);
// ↑ ここを実際のタイトルに変更（例：「ドット侍サバイバー」など）

// --- PRESS TO START / 日本語でもOK ---
if (press_visible) {
    var start_y = gh * 0.6;

    draw_set_font(Fnt_Ui);

    draw_text(gw * 0.5, start_y, "PRESS TO START");
    // → 「ボタンを押してスタート」など日本語にしてもOK
}