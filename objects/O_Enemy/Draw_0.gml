// まずは通常描画
draw_sprite_ext(
    sprite_index,
    image_index,
    x, y,
    image_xscale,
    1,
    image_angle,
    image_blend,
    image_alpha
);

// ★ デバッグ：敵ボディの当たり判定を可視化
//  ・global.debugShowHitbox が true のときだけ
//  ・敵がまだ死亡ステートではないときだけ
if (variable_global_exists("debugShowHitbox")
 && global.debugShowHitbox
 && state != states.DEAD) {

    // 描画状態の一時退避（必要なら）
    var _old_alpha = draw_get_alpha();
    var _old_color = draw_get_color();

    // 半透明の枠でヒットボックスを描画
    draw_set_alpha(0.6);
    draw_set_color(c_red);  // 赤色（見やすければ他色でも可）
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);

    // 元の描画設定に戻す
    draw_set_alpha(_old_alpha);
    draw_set_color(_old_color);
}
