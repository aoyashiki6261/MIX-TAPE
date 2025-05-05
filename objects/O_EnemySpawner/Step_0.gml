spawn_timer--;

if (spawn_timer <= 0) {
    spawn_timer = 480; // スポーン間隔（フレーム） 例：1秒ごとにスポーン（60fps × 1秒）

    // スポナー一覧を作成
    var spawner_list = array_create(0);

    // スポナーIDを取得
    with (O_EnemySpawner) {
        array_push(spawner_list, id);
    }

    // スポナーが存在していれば
    if (array_length(spawner_list) > 0) {
        var index = irandom(array_length(spawner_list) - 1); // ランダム選択
        var chosen_spawner = spawner_list[index];

        // 選ばれたスポナーの位置からスポーン
        with (chosen_spawner) {
            instance_create_layer(x, y, "Enemy", O_Enemy);
        }
    }
}