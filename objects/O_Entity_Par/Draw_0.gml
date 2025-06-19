// 変更後
// “facing” は必ず ±1（左右向き）を保持するようにする。
// もし現在 hmove をそのまま入れているなら、
//   facing = sign(hmove);
// のように “–1 / 1” に置き換えてください。

var dir_sign = sign(facing);       // ← facing が ±1 の場合はこれだけでOK
draw_sprite_ext(
    sprite_index,
    image_index,
    x, y,
    dir_sign,                       // ← xscale: 符号のみ
    1,                              // ← yscale: 必ず “1” をキープ
    0,                              // ← 回転角度（必要に応じて image_angle に）
    c_white,
    1
);