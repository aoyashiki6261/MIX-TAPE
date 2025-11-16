/// 敵を一体倒したときに一度だけキル数を加算する
function Enemy_MarkKill() {

    // プレイヤーはキル対象にしない
    if (object_index == O_Player) {
        return;
    }

    // すでにカウント済みなら何もしない
    if (!variable_instance_exists(id, "killCounted")) {
        killCounted = false;
    }

    if (!killCounted) {
        killCounted = true;

        // ★ 表示と合わせて global.kills を使う
        if (!variable_global_exists("kills")) {
            global.kills = 0;
        }
        global.kills += 1;

        show_debug_message("[Enemy_MarkKill] kills=" + string(global.kills)
            + " id=" + string(id));
    }
}
