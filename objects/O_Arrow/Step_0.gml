/// O_Arrow Step イベント

// 見た目の向きを常に弾の進行角に合わせる
image_angle = dir;

// -----------------------------
// 実行制御: 一時停止 / 1フレーム進行対応
// -----------------------------
/// doStep == true のフレームだけ「ロジック＆移動」を進める
var doStep = true;
if (variable_global_exists("gamePaused") && global.gamePaused) {
    image_speed = 0;
    if (variable_global_exists("stepAdvance") && global.stepAdvance) {
        // 1コマだけ進める（doStep は true のまま）
    } else {
        doStep = false;
    }
} else {
    image_speed = 1;
}

// 見た目の向きを常に弾の進行角に合わせる
image_angle = dir;

// 構え中の向き・深度調整（見た目だけ更新したいなら doStep の外でもOK）
if (state == 0) {
    if (instance_exists(O_Player)) {
        dir = point_direction(x, y, O_Player.x, O_Player.y);
    }
    depth = -y - 50;
}

// ここから下は doStep のときだけロジックを進める
if (!doStep) {
    exit;
}

// ★ 追加：SEフラグが未定義なら初期化（Createでやるのが理想だがStep内でも安全にする）
if (!variable_instance_exists(id, "shotSEPlayed")) {
    shotSEPlayed = false;
}


// === ステートマシン ===
switch (state) {

    // -------------------------
    // 0: 敵が撃つまで待機（構え中）
    // -------------------------
    case 0:
        // プレイヤーを狙う（構え中。位置は動かさない）
        if (instance_exists(O_Player)) {
            dir = point_direction(x, y, O_Player.x, O_Player.y);
        }
        depth = -y - 50;
    break;


    // -------------------------
    // 1: 弾の発射 / 移動
    // -------------------------
    case 1:
        // ★ 追加：発射開始の瞬間に1回だけ鳴らす
        if (!shotSEPlayed) {
            audio_play_sound(Snd_EnemyShot, 1, false);
            shotSEPlayed = true;
        }

        // 移動量を計算
        hsp = lengthdir_x(spd, dir);
        vsp = lengthdir_y(spd, dir);

        // 実際に移動
        x += hsp;
        y += vsp;

        // 深度の更新（手前のものほど小さい値に）
        depth = -y;

        // プレイヤーとの当たり判定（1撃で死亡）
        if (instance_exists(O_Player) && place_meeting(x, y, O_Player)) {
            var target = instance_place(x, y, O_Player);
            if (target != noone) {
                with (target) {
                    if (state != PLAYERSTATE.DEAD && !deadanimstarted) {
                        state = PLAYERSTATE.DEAD;
                    }
                }
                instance_destroy(); // 弾を削除して終了
                exit;
            }
        }
    break;
}


// -----------------------------
// クリーンアップ（削除条件）
// -----------------------------

// 画面外で削除
var _pad = ARROW_CULL_PADDING; // ★ マクロを使う（なければ 16 にしてOK）
if (bbox_right  < -_pad
 || bbox_left   > room_width  + _pad
 || bbox_bottom < -_pad
 || bbox_top    > room_height + _pad) {
    destroy = true;
}

// プレイヤーとのフラグによる削除（任意機能）
if (hitConfirm == true && playerDestroy == true) {
    destroy = true;
}

// 壁との当たり判定（削除）
if (place_meeting(x, y, O_Solid)) {
    destroy = true;
}

// 実際に削除
if (destroy == true) {
    instance_destroy();
}
