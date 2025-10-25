function EnemyHit(argument0) {
    var _damage = argument0;

    // ★ すでに死亡しているなら何もしない（多重ヒット防止）
    if (state == states.DEAD || kill_counted) return;

    hp -= _damage;
    flash = true;

    if (hp > 0) {
		show_debug_message("[damage/EnemyHit] hp<=0 id=" + string(id));
        state  = states.HIT;
        hitNow = true;
        return; // ★ 生存中はここで終了
		
    }

    // ★ ここから死亡。死亡処理は is_dead() に一本化して呼ぶだけ
    show_debug_message("敵が死亡しました");
    is_dead(); // ← state=DEAD、キル加算は is_dead() 側で実行
    return;
}