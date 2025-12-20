/// --------------------------------------
/// O_Game Room Start イベント
/// --------------------------------------

// ★ デバッグ系グローバルは上書きしない
// 代わりに O_DebugController の初回生成を行う
if (!instance_exists(O_DebugController)) {
    // 安全のため、レイヤーが存在するか確認
    var dbg_layer = "Controller";
    if (!layer_exists(dbg_layer)) {
        dbg_layer = "Instances"; // 念のため、必ず存在するレイヤーにフォールバック
        show_debug_message("Layer 'Controller' が存在しません。O_DebugController を 'Instances' に生成します。");
    }
    var dbg = instance_create_layer(0, 0, dbg_layer, O_DebugController);
    dbg.persistent = true; // Room切替やリスタートでも破棄されない
}

// ここからゲーム進行用のリセットのみ
global.gameOver = false;   // ルーム開始時はGAME OVER解除
global.kills    = 0;
global.killCount = 0;

// --------------------------------------
// 2) 重複配置の敵をルーム開始時に間引く（同座標・同オブジェクト）
// --------------------------------------

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
