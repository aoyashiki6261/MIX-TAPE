function EnemyHit(_damage) {

    // ★ この関数を呼んだインスタンスが「state」を持っていないなら、何もしないで終了
    //    → プレイヤーや弾などから誤って呼ばれても安全
    if (!variable_instance_exists(self, "state")) {
        return;
    }

    // ★ すでに死亡ステートの敵には、これ以上ダメージ処理を行わない
    if (state == states.DEAD) {
        return;
    }

    hp -= _damage;
    flash = true;

    if (hp > 0) {
        state  = states.HIT;
        hitNow = true;
        return; // ★ 生存中はここで終了
		
    }

    // ★ ここから死亡。死亡処理は is_dead() に一本化して呼ぶだけ
    is_dead(); // ← state=DEAD、キル加算は is_dead() 側で実行
    return;
}
