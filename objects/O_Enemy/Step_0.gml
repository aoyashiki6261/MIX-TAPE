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

    // 攻撃シグナル削除
    if (instance_exists(attack_signal)) {
        with (attack_signal) instance_destroy();
    }
    attack_signal = noone;

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
	
	// ★ 死亡時もシグナルを確実に消す
    if (variable_instance_exists(id, "attack_signal") && instance_exists(attack_signal)) {
        with (attack_signal) instance_destroy();
    }
    attack_signal = noone;

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

// ★ ATTACK 以外のステートでは攻撃シグナルを必ず消す（HIT/IDLE/MOVE に抜けたときの保険）
if (state != states.ATTACK) {
    if (variable_instance_exists(id, "attack_signal") && instance_exists(attack_signal)) {
        with (attack_signal) instance_destroy();
    }
    attack_signal = noone;
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
        if (!global.gamePaused || global.stepAdvance) {

            // ★ 攻撃中もプレイヤー方向にエイムを合わせておく（最終発射方向のベース）
            if (instance_exists(O_Player)) {
                dir = point_direction(x, y, O_Player.x, O_Player.y);
				// 攻撃中も左右反転（image_xscale）を更新する
                check_facing();
            }
            spd = 0;

            // ★ 攻撃シグナル（S_Enemy_Attacksignal）の制御 ★
            var glow_frames = 30;                         // 何フレーム前から光らせるか（短めのサイン）
            var glow_start  = max(0, windupTime - glow_frames);

            if (shootTimer >= glow_start && shootTimer < windupTime) {
                // 発射直前ゾーン：弓の先にシグナルを出す

                // ★ シグナルの位置（左右で別のオフセットを使う）
	            var sx, sy;

	            // ★ プレイヤーが敵のどちら側にいるかで左右を決める
	            var _is_left = false;
	            if (instance_exists(O_Player)) {
	                _is_left = (O_Player.x < x); // プレイヤーのXが敵より左ならtrue
	            }

	            if (_is_left) {
	                // 左向き側（プレイヤーが左にいる）
	                sx = x + signal_offset_left_x;
	                sy = y + signal_offset_left_y;
	            } else {
	                // 右向き側（プレイヤーが右にいる or プレイヤー不在）
	                sx = x + signal_offset_right_x;
	                sy = y + signal_offset_right_y;
	            }

                // まだシグナルがなければ生成、あれば位置を追従
                if (!instance_exists(attack_signal)) {
                    attack_signal = instance_create_depth(sx, sy, depth - 1, O_Enemy_AttackSignal);
                } else {
                    attack_signal.x = sx;
                    attack_signal.y = sy;
                }

                attack_signal.image_angle = 0;
				
            } else {
                // 発射直前ゾーン以外ではシグナルを消す
                if (instance_exists(attack_signal)) {
                    with (attack_signal) instance_destroy();
                }
                attack_signal = noone;
            }

  			// 一時停止中でも1フレームだけ shootTimer を進行
            var do_step = (!global.gamePaused || global.stepAdvance);
            if (do_step) {
                // ★この下は「溜め／Shot／硬直」の処理。今まで書いていたものをそのまま残してOK
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

                    // ★ 発射の瞬間にシグナルを消す（保険）
                    if (instance_exists(attack_signal)) {
                        with (attack_signal) instance_destroy();
                    }
                    attack_signal = noone;

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

                    // ★ 基準となる「矢の位置」（左右で別のオフセットを使う）
                    //    プレイヤーがどちら側にいるかで左右判定（シグナルと同じロジック）
                    var bx, by;
                    var _is_left_arrow = false;
                    if (instance_exists(O_Player)) {
                        _is_left_arrow = (O_Player.x < x); // プレイヤーのXが敵より左ならtrue
                    }

                    if (_is_left_arrow) {
                        // 左向き時の矢の出現基準
                        bx = x + arrow_offset_left_x;
                        by = y + arrow_offset_left_y;
                    } else {
                        // 右向き時の矢の出現基準
                        bx = x + arrow_offset_right_x;
                        by = y + arrow_offset_right_y;
                    }

					// ★ 手の位置から、矢の向きに arrow_forward 分だけ前に出す
					var _sx = bx + lengthdir_x(arrow_forward, _final_dir);
					var _sy = by + lengthdir_y(arrow_forward, _final_dir);

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

                    // ★ 念のため攻撃シグナルもここで消す
                    if (instance_exists(attack_signal)) {
                        with (attack_signal) instance_destroy();
                    }
                    attack_signal = noone;

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
