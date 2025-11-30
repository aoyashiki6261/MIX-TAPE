/// O_Enemy Step イベント（暫定・デバッグ用）

// ★ 一旦、敵は必ずフルに処理を行う（ポーズ・AIフラグ無視）
image_speed = 1;
// -----------------------------
// デバッグルーム用：敵AI停止フラグ
// -----------------------------
if (room_get_name(room) == "Rm_Debug"
 && variable_global_exists("enemyAIEnabled")
 && !global.enemyAIEnabled
 && state != states.DEAD) {

    // ★ここで「完全に凍結」させる★
    // いまの移動は x += lengthdir_x(...) なので、
    // hsp / vsp は念のため0にしておく程度でOK
    hsp        = 0;
    vsp        = 0;
    spd        = 0;
    path_speed = 0;
    image_speed = 0; // アニメも止める

    // 必要なら、構え中の矢を手元にキープしたい等の処理をここに書く

    return; // ★このフレームはこれ以上何もしない（IDLE/MOVE/ATTACK に入らない）
}
// （必要なら）orig_blend の保持だけ残してOK
if (!variable_instance_exists(id, "orig_blend")) {
    orig_blend = image_blend;
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

// --- 念のため：不正なステートならIDLEに戻す ---
if (state != states.IDLE
 && state != states.MOVE
 && state != states.ATTACK
 && state != states.DEAD) {
    state = states.IDLE;
}
// 各ステートのAI処理（IDLE / MOVE / ATTACK）
switch (state) {
    // -------------------------
    // IDLE：プレイヤーを見つけたらMOVEへ
    // -------------------------
    case states.IDLE:
        Enemy_anim(); // 待機アニメ

        if (instance_exists(O_Player)) {
            // とりあえずプレイヤーがいればMOVEに移行
            state = states.MOVE;
        }
    break;

    // -------------------------
    // MOVE：プレイヤーに向かって直進で追尾
    // -------------------------
	   case states.MOVE:
	    if (instance_exists(O_Player)) {
	        var _dis = point_distance(x, y, O_Player.x, O_Player.y);
	        var _dir = point_direction(x, y, O_Player.x, O_Player.y);

	        // 向き更新
	        dir = _dir;
	        check_facing();

	        // 攻撃可能距離に入ったらATTACKへ
	        if (_dis <= attack_dis) {
	            path_end();     // 古いパスが残っていても一応終了
	            shootTimer = 0;
	            state = states.ATTACK;
	        } else {
	            // ★シンプル追尾移動★
	            var move_speed = 0.8; // 足の速さ。お好みで調整
	            x += lengthdir_x(move_speed, _dir);
	            y += lengthdir_y(move_speed, _dir);
	        }
	    } else {
	        // プレイヤーがいなければIDLEへ戻す
	        state = states.IDLE;
	    }

	    Enemy_anim();
	break;


     case states.ATTACK:
        // --- シグナル点滅処理 (windup 中のみ) ---
        if (shootTimer > 0 && shootTimer < windupTime) {
            var flashInterval = 8; // 8 フレームごとに切り替え
            if ((shootTimer div flashInterval) mod 2 == 0) {
                image_alpha = 0.3;  // 半透明にしてチカチカ
            } else {
                image_alpha = 1;    // 元に戻す
            }
        } else {
            // 溜め完了後は必ず不透明に戻す
            image_alpha = 1;
        }

        if (!global.gamePaused || global.stepAdvance) {

            // 発射まではプレイヤーを追尾してエイム更新
            if (instance_exists(O_Player)) {
                dir = point_direction(x, y, O_Player.x, O_Player.y);
            }
            spd = 0;

            var do_step = (!global.gamePaused || global.stepAdvance);
            if (do_step) {

                // Shotスプライトを見せるフレーム数
                var _shot_frames_to_show = max(30, (sprite_exists(S_Enemy_Shot) ? sprite_get_number(S_Enemy_Shot) : 1));

                // 1) 溜め中：S_Enemy_Charge を手動フレーム進行（ループさせない）
                if (shootTimer < windupTime) {

                    if (sprite_index != S_Enemy_Charge) {
                        sprite_index = S_Enemy_Charge;
                        image_index = 0;
                        image_speed = 0;   // 自動再生を止める（ループ防止）
                    }

                    var _frames = max(1, sprite_get_number(S_Enemy_Charge));
                    var _t = clamp(shootTimer, 0, windupTime - 1);
                    image_index = min(_frames - 1, floor(_t * _frames / windupTime));

                    // ★ここではもう矢は存在しない（事前出現をやめる）

                }
                // 2) 発射の瞬間：S_Enemy_Shot に切替えて「このフレームで矢を生成＆発射」
                else if (shootTimer == windupTime) {

                    // Shotスプライトに切り替え
                    if (sprite_index != S_Enemy_Shot) {
                        sprite_index = S_Enemy_Shot;
                        image_index = 0;
                        image_speed = 1;
                    }

                    // 最終エイム（このフレームのプレイヤー位置）を取得
                    var _final_dir = dir;
                    if (instance_exists(O_Player)) {
                        _final_dir = point_direction(x, y, O_Player.x, O_Player.y);
                    }

                    // 矢の出現位置（敵の少し前）
                    var _spawn_offset = 16;
                    var _sx = x + lengthdir_x(_spawn_offset, _final_dir);
                    var _sy = y + lengthdir_y(_spawn_offset, _final_dir);

                    // ★ここで初めて矢を生成＆即発射状態にする
                    myball = instance_create_depth(_sx, _sy, depth, O_Arrow);
                    myball.dir         = _final_dir;
                    myball.image_angle = _final_dir;
                    myball.state       = 1; // 発射状態（O_Arrow側で移動開始）

                }
                // 3) 発射後：S_Enemy_Shot を数フレームだけ見せ続ける
                else if (shootTimer > windupTime && shootTimer <= (windupTime + _shot_frames_to_show)) {

                    if (sprite_index != S_Enemy_Shot) {
                        sprite_index = S_Enemy_Shot;
                        image_index = 0;
                        image_speed = 1;
                    }
                    // ここでは矢はすでに飛んでいるので、何もしない

                }
                // 4) 発射後～硬直：Idle（Recover的な時間）
                else if (shootTimer > (windupTime + _shot_frames_to_show) && shootTimer <= windupTime + recoverTime) {

                    if (sprite_index != S_Enemy_Idle) {
                        sprite_index = S_Enemy_Idle;
                        image_index = 0;
                        image_speed = 1;
                    }
                }

                // 5) 硬直終了 → 移動へ戻る
                if (shootTimer > windupTime + recoverTime) {
                    state = states.MOVE;
                    shootTimer = 0;
                    myball = noone;

                    calc_path_timer = 0;
                    Check_For_Player(); // 追跡用のパス/方向更新
                }

                // フレーム末尾で進める
                shootTimer++;
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
