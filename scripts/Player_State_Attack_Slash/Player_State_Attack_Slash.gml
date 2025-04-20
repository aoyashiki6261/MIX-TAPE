function Player_State_Attack_Slash() {
    // 死亡していたら攻撃処理を一切しない
    if (state == PLAYERSTATE.DEAD) {
        return;
    }

    // 攻撃の初期化（アニメーションなど）
    if (sprite_index != S_Player_Attack) {
        sprite_index = S_Player_Attack;
        image_index = 0;
        image_speed = 1;
        ds_list_clear(hitByAttack);
    }

    // 攻撃の当たり判定処理…
    mask_index = S_Player_Attack_HB;
    var hitByAttackNow = ds_list_create();
    var hits = instance_place_list(x, y, O_Enemy, hitByAttackNow, false);
    if (hits > 0) {
        for (var i = 0; i < hits; i++) {
            var hitID = hitByAttackNow[| i];
            if (ds_list_find_index(hitByAttack, hitID) == -1) {
                ds_list_add(hitByAttack, hitID);
                with (hitID) {
                    EnemyHit(2);
                }
            }
        }
    }
    ds_list_destroy(hitByAttackNow);
    mask_index = S_Player_Idle;

    // アニメーション終了後、待機状態に戻す
    if (animation_end()) {
    if (state != PLAYERSTATE.DEAD) { // ← このチェックを追加！
        state = PLAYERSTATE.FREE;
        sprite_index = S_Player_Idle;
    }
	}
}

