/// 重複配置の敵をルーム開始時に間引く（同座標・同オブジェクト）
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