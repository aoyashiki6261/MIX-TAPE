// ★ プレイヤー死亡時は敵を出現させない
if (global.playerDead) exit;

// ★ 同期ガード：一番若いIDのスポナーだけが処理を担当（マスター制）
var _master = instance_find(O_EnemySpawner, 0);
if (id != _master) exit;

spawn_timer--;

if (spawn_timer <= 0) {
    spawn_timer = ENEMY_SPAWN_INTERVAL_LOOP; // スポーン間隔（フレーム）

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

            // ★ プレイヤー死亡時は敵を出現させない（念のための二重ガード）
            if (global.playerDead) exit;

            // ★ 近接チェック：半径 R 以内に同種がいたらスキップ（重なり防止）
            var R = ENEMY_SPAWN_COLLISION_RADIUS; // ← 調整ポイント（広げるほど重なりにくい）
            if (collision_circle(x, y, R, O_Enemy, false, true) == noone) {

                // ★ 地形などとの重なりも避けたい場合は以下を併用
                // if (!place_meeting(x, y, O_Solid)) { ... }

                instance_create_layer(x, y, "Enemy", O_Enemy);
            }
        }
    }
}
