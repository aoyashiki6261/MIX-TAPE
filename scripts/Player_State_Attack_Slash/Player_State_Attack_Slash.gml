function Player_State_Attack_Slash(do_step) {
    // 死亡していたら攻撃処理を一切しない
    if (state == PLAYERSTATE.DEAD) {
        return;
    }

    // --- 一時停止時の処理スキップ ---
    if (!do_step) {
        return;
    }

    // 攻撃の初期化（アニメーションなど）
    if (sprite_index != S_Player_Attack) {
        sprite_index = S_Player_Attack;
        image_index = 0;
        image_speed = 1;
        ds_list_clear(hitByAttack);
    }
    
    //先行入力受付（関数内で“終盤のみ”判定します）
    buffer_try_record(pressed_attack_i, pressed_space_i, pressed_pad_i);

    // 攻撃の当たり判定処理…
    mask_index = S_Player_Attack_HB;

    //安全のため、必ずこのスコープで一時リストを生成
    var hitByAttackNow = ds_list_create();

    var hits = instance_place_list(x, y, O_Enemy, hitByAttackNow, false);
    if (hits > 0) {
        for (var i = 0; i < hits; i++) {
            var hitID = hitByAttackNow[| i];
            if (ds_list_find_index(hitByAttack, hitID) == -1) {
                ds_list_add(hitByAttack, hitID);
                with (hitID) EnemyHit(2);
            }
        }
    }

    //マスクを元に戻す
    mask_index = S_Player_Idle;

    //一時リストは存在確認の上で破棄（未生成/多重破棄クラッシュ防止）
    if (ds_exists(hitByAttackNow, ds_type_list)) {
        ds_list_destroy(hitByAttackNow);
    }

    // アニメーション終了後：バッファ消費 → 次へ
    if (animation_end()) {
        if (state != PLAYERSTATE.DEAD) {

            // 先行入力の消費（最後の入力が優先）
            if (buffered_action == ACTION.ATTACK) {
                buffer_clear();
                state = PLAYERSTATE.ATTACK_SLASH;   //攻撃
                return;
            } else if (buffered_action == ACTION.DODGE) {
                buffer_clear();
                state = PLAYERSTATE.DODGE;          // 回避へ

                // 回避初期化（FREE時と同じセットをする場合はここに）
                sprite_index   = S_Player_Dodge_Start;
                image_index    = 0;
                image_speed    = 1;
                dodge_timer    = dodge_duration;
                dodge_cooldown = dodge_cooldown_max;
                invincible     = true;
                dash           = false;
                return;
            }

            // 予約なしならFREEへ
            state = PLAYERSTATE.FREE;
            sprite_index = S_Player_Idle;
        }
    }
}
