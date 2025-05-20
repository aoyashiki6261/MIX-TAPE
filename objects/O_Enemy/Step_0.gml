// AI無効時は移動と攻撃をスキップする（デバッグルーム限定）
if (room_get_name(room) == "Rm_Debug" && !global.enemyAIEnabled) {
    // パス移動停止（この1行が重要）
    path_end();

    // その場に静止（移動停止）
    hsp = 0;
    vsp = 0;

    // アニメーション停止
    image_speed = 0;

    // 静止状態のスプライトに設定（必要に応じて変更可）
    sprite_index = S_Enemy_Idle;

    // 被弾演出などは反映
    Enemy_anim();

    // 残りの処理をスキップ
    return;
}

// 死亡時の処理
if (state == states.DEAD) {
    Enemy_anim();
    hsp = 0;
    vsp = 0;
    path_end();
    death_timer++;

    // 弾がまだ存在していたら一緒に削除
    if (instance_exists(self.myball)) {
        with (self.myball) {
            instance_destroy();
        }
    }

    if (death_timer > 900) {
        instance_destroy();
    }
    return;
}

// 各ステートのAI処理（IDLE / MOVE / ATTACK）
switch (state) {
    case states.IDLE:
        calc_entity_movement();
        if (instance_exists(O_Player)) {
            Check_For_Player(); // IDLE中にもプレイヤーの位置をチェック
        }
        if (path_index != -1) state = states.MOVE;
        Enemy_anim();
    break;

    case states.MOVE:
        calc_entity_movement();

        if (instance_exists(O_Player)) {
            var _dis = distance_to_object(O_Player);

            // 攻撃可能距離に入ったらステート移行
            if (_dis <= attack_dis) {
                path_end();
                shootTimer = 0;
                state = states.ATTACK;
                break;
            }

            // 攻撃距離外ならパスを更新
            Check_For_Player();
        }

        check_facing();

        if (path_index == -1) state = states.IDLE;

        Enemy_anim();
    break;

    case states.ATTACK:
        calc_entity_movement();
        Enemy_anim();

        // プレイヤーの方向取得
        if (instance_exists(O_Player)) {
            dir = point_direction(x, y, O_Player.x, O_Player.y);
        }

        spd = 0;
        image_index = 0;

        shootTimer++;

        // 弾を作成（1フレーム目のみ）
        if (shootTimer == 1) {
            myball = instance_create_depth(x, y, depth, O_Enemy_Ball);
            if (instance_exists(O_Player)) {
                myball.dir = point_direction(x, y, O_Player.x, O_Player.y);
                myball.state = 0; // 最初は待機状態
            }
        }

        // 弾を敵の前に保持（windup中）
        if (shootTimer <= windupTime && instance_exists(self.myball)) {
            var offset = 16; // 弾の前方オフセット
            self.myball.x = x + lengthdir_x(offset, dir);
            self.myball.y = y + lengthdir_y(offset, dir);
        }

        // windup が終わったら発射
        if (shootTimer == windupTime && instance_exists(myball)) {
            myball.state = 1;
        }

        // 攻撃後、追跡に戻る
        if (shootTimer > windupTime + recoverTime) {
            state = states.MOVE;
            shootTimer = 0;
            myball = noone;
            break;
        }
    break;
}

// 画面内にいるときだけタイマーを進める（ATTACK以外）
var _camLeft = camera_get_view_x(view_camera[0]);
var _camRight = _camLeft + camera_get_view_width(view_camera[0]);
var _camTop = camera_get_view_y(view_camera[0]);
var _camBottom = _camTop + camera_get_view_height(view_camera[0]);

if (bbox_right > _camLeft && bbox_left < _camRight && bbox_bottom > _camTop && bbox_top < _camBottom) {
    if (state != states.ATTACK) shootTimer++;
}

// クールダウン経過後に攻撃可能な距離なら再攻撃
if (shootTimer > cooldownTime) {
    if (state != states.ATTACK) {
        var _dis = distance_to_object(O_Player);
        if (_dis <= attack_dis) {
            state = states.ATTACK;
            shootTimer = 0;
        }
    }
}