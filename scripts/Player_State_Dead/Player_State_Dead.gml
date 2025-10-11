/// @description DEADステート（死亡演出→一定時間後に消滅）
/// @param {bool} do_step デバッグ用：一時停止中でも1フレーム進めるときに trueとする。
function Player_State_Dead(do_step) {
    // 速度（移動）を止める（両系統に対応）
    hSpeed = 0; vSpeed = 0;
    hmove  = 0; vmove  = 0;

    // 初回のみ死亡アニメを開始
    if (!deadanimstarted) {
        sprite_index    = S_Player_Dead;
        image_index     = 0;
        image_speed     = 1;
        deadanimstarted = true;

    }

    // ポーズ中は進めない（stepAdvance対応は呼び出し側の do_step が担保）
    if (!do_step) return;

    // タイマー進行 → 一定時間後に消滅（元の仕様を踏襲）
    death_timer++;
    if (death_timer > 900) {
        instance_destroy();
        return;
    }
}
