// --- 実行制御: 一時停止モード（フレーム送り対応） ---
if (variable_global_exists("gamePaused") && global.gamePaused) {
    if (variable_global_exists("stepAdvance") && global.stepAdvance) {
        global.stepAdvance = false; // このフレームだけ処理許可
        // 処理は続行
    } else {
        // 一時停止中は image_speed も止める
        image_speed = 0;

        // 弾を保持中は向きだけ維持（windup中など）
        if (instance_exists(myball) && myball.state == 0) {
            var offset = 16;
            myball.x = x + lengthdir_x(offset, dir);
            myball.y = y + lengthdir_y(offset, dir);
        }

        return; // 通常処理はスキップ
    }
}
// デバッグモード: Oキーで方向固定の弾を撃つ（上・左・下・右・OFF切替）
// global.enemyFireDirection: 0=上, 1=左, 2=下, 3=右, 4=OFF
if (state != states.DEAD && variable_global_exists("enemyFireDirection") && global.enemyFireDirection != 4) {
    // 強制停止（移動＆パスキャンセル）
    path_end();
    hsp = 0;
    vsp = 0;
    spd = 0;

    // 弾を一定間隔で撃つ（例：30フレームごと）
    if (shootTimer % 30 == 0) {
        var fire_dir;

        switch (global.enemyFireDirection) {
            case 0: fire_dir = 90; break;   // 上
            case 1: fire_dir = 180; break;  // 左
            case 2: fire_dir = 270; break;  // 下
            case 3: fire_dir = 0; break;    // 右
        }

        var b = instance_create_depth(x, y, depth, O_Enemy_Ball);
        b.dir = fire_dir;
        b.state = 1; // 発射状態
    }

    shootTimer++; // デバッグ用カウンタ進行
    return; // 通常のAI処理はスキップ
}

// AI無効時は移動と攻撃をスキップする（デバッグルーム限定、ただし死亡している敵は除外）
if (room_get_name(room) == "Rm_Debug" && !global.enemyAIEnabled && state != states.DEAD) {
    path_end();
    hsp = 0;
    vsp = 0;
    image_speed = 0;
    sprite_index = S_Enemy_Idle; // 通常待機スプライト
    Enemy_anim();
    return;
}

// --- 死亡処理は全ルームで共通処理として分離 ---
if (state == states.DEAD) {
    // 移動やAI処理停止
    path_end();
    hsp = 0;
    vsp = 0;

    // 死亡スプライト・アニメーションをセット（最初のみ）
    if (sprite_index != S_Enemy_Dead) {
        sprite_index = S_Enemy_Dead;
        image_index = 0;
        image_speed = 0.2; // 死亡アニメ進行速度（止めないこと）
    }

    death_timer++;

    // 弾がまだ存在していたら削除
    if (instance_exists(self.myball)) {
        with (self.myball) {
            instance_destroy();
        }
    }

    // 一定時間後に敵を削除（消滅処理）
    if (death_timer > 900) {
        instance_destroy();
    }

    return; // 他の処理をスキップ
}

// 各ステートのAI処理（IDLE / MOVE / ATTACK）
switch (state) {
    case states.IDLE:
        // calc_entity_movement() は削除
        if (instance_exists(O_Player)) {
            Check_For_Player(); // IDLE中にもプレイヤーの位置をチェック
        }
        if (path_index != -1) state = states.MOVE;
        Enemy_anim();
    break;

    case states.MOVE:
        spd = 0.31;

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
        Enemy_anim();

        // パスがなければIDLEに戻す（Check_For_Player の後に判断）
        if (path_index == -1) {
            state = states.IDLE;
        }
    break;

    case states.ATTACK:
        // calc_entity_movement() は削除
        Enemy_anim();
		
		if (!global.gamePaused || global.stepAdvance) {
        if (instance_exists(O_Player)) {
             dir = point_direction(x, y, O_Player.x, O_Player.y);
            }
        spd = 0;
        image_index = 0;

    //一時停止中でも1フレームだけ shootTimer を進行
    var do_step = (!global.gamePaused || global.stepAdvance);
    if (do_step) {
        shootTimer++;

            // 弾を作成（1フレーム目のみ）
		    if (shootTimer == 1) {
		        myball = instance_create_depth(x, y, depth, O_Enemy_Ball);
		        if (instance_exists(O_Player)) {
		            myball.dir = point_direction(x, y, O_Player.x, O_Player.y);
		            myball.state = 0; // 待機状態
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

                // パスをすぐ再計算させるためにタイマーをリセット
                calc_path_timer = 0;

                // 追跡用のパスを再設定
                Check_For_Player();
            }
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
	}
}
}