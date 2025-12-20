
// 通常の見た目
draw_self();

// ------------------------------------
// ★ デバッグ：敵の bbox（四角）を可視化
// ------------------------------------
if (variable_global_exists("debugShowHitbox")
&& global.debugShowHitbox
&& state != states.DEAD) {

    // 描画状態を退避
    var _old_alpha = draw_get_alpha();
    var _old_color = draw_get_color();

    // 半透明の四角
    draw_set_alpha(0.5);
    draw_set_color(c_red);

    // ★ bbox をそのまま描画
    draw_rectangle(
        bbox_left,
        bbox_top,
        bbox_right,
        bbox_bottom,
        false
    );

    // 復元
    draw_set_alpha(_old_alpha);
    draw_set_color(_old_color);
}