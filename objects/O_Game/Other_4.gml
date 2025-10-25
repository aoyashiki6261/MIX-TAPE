//グリッドとタイルサイズの設定
#macro TS	16

//ルーム内のタイルを取得
var _w = ceil(room_width / TS);
var _h = ceil(room_height / TS);

//モーションプランニンググリッドを作成(solidのすべてのインスタンスを簡単に追加できるようになる)
global.mp_grid = mp_grid_create(0, 0, _w, _h, TS, TS);

//グリッドにSolidインスタンスを追加
mp_grid_add_instances(global.mp_grid, O_Solid, false);

/// 重複配置の敵をルーム開始時に間引く（同座標・同オブジェクト）
var _seen = ds_map_create();
with (O_Enemy) {
    var _key = string(floor(x)) + "_" + string(floor(y)) + "_" + string(object_index);
    if (ds_map_exists(other._seen, _key)) {
        // 既に同じ座標・同オブジェクトが居る ⇒ 自分は削除
        instance_destroy();
    } else {
        ds_map_add(other._seen, _key, 1);
    }
}
ds_map_destroy(_seen);