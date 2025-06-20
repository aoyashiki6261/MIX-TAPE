// Draw イベント (O_Enemy)

// ※ 親の draw_self() には頼らず、自前で一回だけ描きます

draw_sprite_ext(
    sprite_index,   // スプライト
    image_index,    // フレーム
    x, y,           // 描画位置
    facing,         // 横方向のスケール（-1 or 1）
    1,              // 縦方向のスケール固定
    image_angle,    // 回転角度
    image_blend,    // ブレンドカラー
    image_alpha     // 透明度（点滅制御用）
);