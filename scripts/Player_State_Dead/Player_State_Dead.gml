/// @description DEADステート（死亡演出→アニメ再生終了で消滅）
/// @param {bool} do_step デバッグ用：一時停止中でも1フレーム進めるときに trueとする。
function Player_State_Dead(do_step) {
    // 移動を完全に停止
    hSpeed = 0;
    vSpeed = 0;
    hmove  = 0;
    vmove  = 0;

    // 初回のみ死亡アニメを開始
    if (!deadanimstarted) {
        sprite_index    = S_Player_Dead;
        image_index     = 0;
        image_speed     = 1;
        deadanimstarted = true;
    }

    // ポーズ中はアニメ進行しない
    if (!do_step) return;

    // 死亡アニメが最後まで再生されたらプレイヤーを消去
    if (image_index >= image_number - 1) {
        instance_destroy();
        return;
    }
}
