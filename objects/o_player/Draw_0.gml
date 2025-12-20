// Inherit the parent event
event_inherited();
// ================================
// ★ デバッグ：プレイヤー攻撃ヒットボックスの可視化
// ================================
if (variable_global_exists("debugShowHitbox")
&& global.debugShowHitbox
&& state == PLAYERSTATE.ATTACK_SLASH) {

    var _old_alpha = draw_get_alpha();
    var _old_color = draw_get_color();

    draw_set_alpha(0.6);
    draw_set_color(c_orange);

    // ★ 攻撃用ヒットボックス（マスクそのものを描画）
    draw_sprite_ext(
        S_Player_Attack_HB,
        image_index,
        x,
        y,
        image_xscale,
        image_yscale,
        image_angle,
        c_orange,
        0.6
    );

    draw_set_alpha(_old_alpha);
    draw_set_color(_old_color);
}

// ================================
// ★ デバッグ：プレイヤー本体の当たり判定可視化
//  ・デバッグ用フラグ ON のときだけ
//  ・死亡中（DEAD）は除外
// ================================
if (variable_global_exists("debugShowHitbox")
 && global.debugShowHitbox
 && state != PLAYERSTATE.DEAD) {

    // 現在の描画状態を退避
    var _old_mask2  = mask_index;
    var _old_alpha2 = draw_get_alpha();
    var _old_color2 = draw_get_color();

    // 本体の当たり判定として「通常の体のマスク」を見たいので Idle を基準に
    mask_index = S_Player_Idle;

    // 本体HB用の矩形を描画（ライムグリーン）
    draw_set_alpha(0.4);
    draw_set_color(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);

    // 元の状態に戻す
    mask_index = _old_mask2;
    draw_set_alpha(_old_alpha2);
    draw_set_color(_old_color2);
}
