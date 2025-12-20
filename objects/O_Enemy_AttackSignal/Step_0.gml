// -----------------------------
// 一時停止 / 1フレーム進行 対応
// -----------------------------
var do_step = true;

if (variable_global_exists("gamePaused") && global.gamePaused) {
    // ポーズ中：stepAdvance が true のときだけ 1 フレーム進める
    if (variable_global_exists("stepAdvance") && global.stepAdvance) {
        do_step = true;
    } else {
        do_step = false;
    }
}

if (!do_step) {
    // 止まっている間はアニメも止める
    image_speed = 0;
    exit;
}

// ここから下は「進めるフレーム」でだけ実行される

// スプライトの自動アニメは常に停止したまま
image_speed = 0;

// 1ステップごとに1コマ進める
anim_frame += 1;

if (anim_frame >= anim_length) {
    // 最後のコマまで再生し終わったら自分で消える（ワンショット）
    instance_destroy();
} else {
    // 対応するコマを表示
    image_index = anim_frame;
}

// 敵より手前に描画
depth = owner.depth - 1;