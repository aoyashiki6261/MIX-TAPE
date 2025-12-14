/// @description この敵のキルを一度だけ加算する
function Enemy_MarkKill() {

    // ★ 既にカウント済み or まだインスタンスが有効でないなら何もしない
    if (kill_counted) return;

    // ★ キル数を加算（最大9999まで）
    global.kills = min(global.kills + 1, 9999);
    kill_counted = true;

    // ★ デバッグ（原因追跡用）
    show_debug_message("[KILL] id=" + string(id)
        + " total=" + string(global.kills));
}
