// カメラ情報更新
view_x = camera_get_view_x(view_camera[0]);
view_y = camera_get_view_y(view_camera[0]);
view_w = camera_get_view_width(view_camera[0]);
view_h = camera_get_view_height(view_camera[0]);

// スポーンポイント（画面外、でも近く）
spawn_points = [
	[room_width div 2, 0], // 上
	[room_width div 2, room_height - TS], // 下
	[0, room_height div 2], // 左
	[room_width - TS, room_height div 2] // 右
];

// タイマー更新
spawn_timer--;

if (spawn_timer <= 0) {
    spawn_timer = 120;

    var i = irandom(3);
    var _x = spawn_points[i][0];
    var _y = spawn_points[i][1];

    instance_create_layer(_x, _y, "Enemy", O_Enemy);
}