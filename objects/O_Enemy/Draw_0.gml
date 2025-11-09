// ※ 親の draw_self() には頼らず、自前で一回だけ描きます
draw_sprite_ext(
    sprite_index,
    image_index,   // スプライト
    x, y,           // 描画位置
    facing * draw_scale, // 横方向の左右反転
    draw_scale,          // 縦方向スケール
    image_angle,    // 回転角度
    image_blend,    // ブレンドカラー
    image_alpha     // 透明度（点滅制御用）
);