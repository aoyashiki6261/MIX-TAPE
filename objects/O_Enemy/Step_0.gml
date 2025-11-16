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
        // windupTime フレームの間だけ色を白⇔元に戻す
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
            if (instance_exists(O_Player)) {
                dir = point_direction(x, y, O_Player.x, O_Player.y);
            }
            spd = 0;

            // 一時停止中でも1フレームだけ shootTimer を進行
			var do_step = (!global.gamePaused || global.stepAdvance);
			if (do_step) {

			    //スプライト遷移を自然にする（Charge → Shot → Idle）
				var _shot_frames_to_show = max(30, (sprite_exists(S_Enemy_Shot) ? sprite_get_number(S_Enemy_Shot) : 1));
				
			    // ※ 溜め尺 windupTime に対し、Charge は1回だけ進むように手動でフレームを進行させる
			    if (shootTimer < windupTime) {
					
			    // 1) 溜め中：S_Enemy_Charge を手動フレーム進行（ループさせない）
			    if (sprite_index != S_Enemy_Charge) {
			        sprite_index = S_Enemy_Charge;
			        image_index = 0;
			        image_speed = 0;   // ← 自動再生を止める（ループ防止）
			    }
			    // shootTimer に比例して0→(frames-1)へ（1周で止める）
			    var _frames = max(1, sprite_get_number(S_Enemy_Charge));
			    var _t = clamp(shootTimer, 0, windupTime - 1);
			    image_index = min(_frames - 1, floor(_t * _frames / windupTime));

			    // 弾を敵の前に保持（windup中）
			    if (shootTimer <= windupTime && instance_exists(self.myball)) {
				    var base_hold_offset = 16;
				    var offset = base_hold_offset;

				    self.myball.x = x + lengthdir_x(offset, dir);
				    self.myball.y = y + lengthdir_y(offset, dir);
				    self.myball.image_angle = dir;  // 構え中の見た目角度
				}

						} else if (shootTimer == windupTime) {
			    // 2) 発射の瞬間：S_Enemy_Shot に切替えて即発射
			    if (sprite_index != S_Enemy_Shot) {
			        sprite_index = S_Enemy_Shot;
			        image_index = 0;     // ← ショットを先頭コマから
			        image_speed = 1;     // ← 再生開始
			    }

			    // windup が終わったら発射（最終エイム反映）
			    if (instance_exists(myball)) {
			        if (instance_exists(O_Player)) {
			            var _final_dir = point_direction(x, y, O_Player.x, O_Player.y);
			            myball.dir = _final_dir;
			            myball.image_angle = _final_dir; // 見た目も一致
			        }
			        myball.state = 1; // ← このステップで発射に移行
			    }

			} else if (shootTimer >= windupTime + 1 && shootTimer <= (windupTime + _shot_frames_to_show)) {
			    // 3) 発射後：S_Enemy_Shot を数フレームだけ見せ続ける（アニメ再生させる）
			    if (sprite_index != S_Enemy_Shot) {               // 念のため
			        sprite_index = S_Enemy_Shot;
			        image_index = 0;
			        image_speed = 1;
			    }
			    // ここでは何もしない（S_Enemy_Shot を再生して見せる時間）

			} else if (shootTimer > (windupTime + _shot_frames_to_show) && shootTimer <= windupTime + recoverTime) {
			    // 4) 発射後～硬直：Idle（必要なら Recover 用スプライトへ）
			    if (sprite_index != S_Enemy_Idle) {
			        sprite_index = S_Enemy_Idle;
			        image_index = 0;
			        image_speed = 1;
			    }
			}

			    // 弾を作成（1フレーム目のみ）
			    if (shootTimer == 1) {
			        myball = instance_create_depth(x, y, depth, O_Arrow);
			        if (instance_exists(O_Player)) {
			            myball.dir = point_direction(x, y, O_Player.x, O_Player.y);
			            myball.state = 0; // 待機状態
			        }

                    //発生直後から見た目角度を一致
                    myball.image_angle = myball.dir;
			    }

			    // 弾を敵の前に保持（windup中）
			    if (shootTimer <= windupTime && instance_exists(self.myball)) {
				    var _draw_scale = (variable_instance_exists(id, "draw_scale") ? draw_scale : 1);
				    var base_hold_offset = 16;
				    var offset = base_hold_offset * _draw_scale;

				    self.myball.x = x + lengthdir_x(offset, dir);
				    self.myball.y = y + lengthdir_y(offset, dir);

                    //構え中は見た目の角度も維持
                    self.myball.image_angle = dir;
				}

			    // windup が終わったら発射（shootTimer==windupTime の瞬間）
			    if (shootTimer == windupTime && instance_exists(myball)) {

                    // ★★ 追加(5): 発射直前に“最終エイム”を反映してから撃つ
                    if (instance_exists(O_Player)) {
                        var _final_dir = point_direction(x, y, O_Player.x, O_Player.y);
                        myball.dir = _final_dir;
                        myball.image_angle = _final_dir; // 見た目も一致
                    }

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
