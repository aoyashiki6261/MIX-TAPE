//グリッドとタイルサイズの設定
#macro TS	16

//ルーム内のタイルを取得
var _w = ceil(room_width / TS);
var _h = ceil(room_height / TS);

//モーションプランニンググリッドを作成(solidのすべてのインスタンスを簡単に追加できるようになる)
global.mp_grid = mp_grid_create(0, 0, _w, _h, TS, TS);

//グリッドにSolidインスタンスを追加
mp_grid_add_instances(global.mp_grid, O_Solid, false);