// Inherit the parent event
event_inherited();

// いつもの見た目を描画
draw_self();

// ★ デバッグ：敵の当たり判定（コリジョンマスクのBBox）を表示
if (room_get_name(room) == "Rm_Main") { // デバッグルームだけにしたい場合
    draw_set_alpha(0.5);
    draw_set_color(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_alpha(1);
}
