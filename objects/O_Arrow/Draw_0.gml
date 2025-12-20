// ※ 親が Draw を持っているなら、これは必須
event_inherited();

// 通常描画
draw_self();

// ------------------------------------
// ★ デバッグ：矢の当たり判定（実形状）可視化
// ------------------------------------
if (variable_global_exists("debugShowHitbox")
 && global.debugShowHitbox
 && mask_index != -1) {

    // 状態退避
    var _old_alpha = draw_get_alpha();
    var _old_color = draw_get_color();

    draw_set_alpha(0.5);
    draw_set_color(c_aqua);

    // ★ scale は 1 固定（重要）
    draw_sprite_ext(
        mask_index,        // ← 当たり判定用スプライト
        image_index,       // 現在のフレーム
        x, y,
        image_xscale,
        image_yscale,
        image_angle,       // ← これが超重要（回転一致）
        c_red,
        1
    );

    // 復元
    draw_set_alpha(_old_alpha);
    draw_set_color(_old_color);
}
