/// --------------------------------------
/// O_Game Room Start イベント
/// --------------------------------------

// 1) デバッグ系グローバルを毎ルーム開始時に「安全な初期値」に戻す
global.gamePaused         = false; // 最初は必ずポーズ解除
global.stepAdvance        = false; // コマ送りフラグもクリア
global.enemyFireDirection = 4;     // 定方向弾デバッグOFF（0〜3はON）
global.enemyAIEnabled     = true;  // 将来用。今は参照していなくてもtrueに

/// --------------------------------------
/// 2) 重複配置の敵をルーム開始時に間引く（同座標・同オブジェクト）
/// --------------------------------------

// ※ _seen はインスタンス変数として作る（var を付けない）
if (variable_instance_exists(id, "_seen")) {
    if (is_ds_map(_seen)) ds_map_destroy(_seen);
}
_seen = ds_map_create();

with (O_Enemy) {
    // 小数ズレ対策で整数化（iround → round に修正）
    var _key = string(round(x)) + "_" + string(round(y)) + "_" + string(object_index);
    if (ds_map_exists(other._seen, _key)) {
        instance_destroy();
    } else {
        ds_map_add(other._seen, _key, 1);
    }
}

// 後片付け
ds_map_destroy(_seen);
_seen = undefined;
