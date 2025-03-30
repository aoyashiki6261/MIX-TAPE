function Player_State_Attack_Slash() {
    hSpeed = 0;
    vSpeed = 0;

    // スプライトが設定されていない場合に設定する
    if (sprite_index != S_Player_Attack) {
        sprite_index = S_Player_Attack;  // 攻撃スプライトに設定
        image_index = 0;  // アニメーション開始
        ds_list_clear(hitByAttack);  // 攻撃によるヒット情報をクリア
    }

    ProcessAttack(S_Player_Attack, S_Player_Attack_HB);

    if (mouseAttack && image_index > 2) {
        state = PLAYERSTATE.ATTACK_COMBO;
    }

    // sprite_indexが設定されている場合にのみanimation_end()を呼び出す
    if (sprite_index == S_Player_Attack) {
        if (animation_end()) {
            sprite_index = S_Player_Idle;  // アイドルスプライトに戻す
            state = PLAYERSTATE.FREE;  // プレイヤーの状態をFREEに設定

        }
    }
}