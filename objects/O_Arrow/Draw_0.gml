// 親の処理（あれば）を実行
event_inherited();

// 通常の見た目を描画
draw_self();

// ------------------------------------
// ★ デバッグ：矢の当たり判定可視化
//  ・global.debugShowHitbox == true のときだけ
//  ・左右反転などは mask / bbox に任せる
// ------------------------------------
if (variable_global_exists("debugShowHitbox")
 && global.debugShowHitbox) {

    // 現在の描画状態を退避
    var _old_alpha = draw_get_alpha();
    var _old_color = draw_get_color();

    // 少し透過した色で枠線を描画（色はお好みで）
    draw_set_alpha(0.6);
    draw_set_color(c_aqua); // 矢用にプレイヤー・敵と色を変えておく

    // 現在の mask_index / sprite に基づく当たり判定矩形
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);

    // 元の描画状態に戻す
    draw_set_alpha(_old_alpha);
    draw_set_color(_old_color);
}