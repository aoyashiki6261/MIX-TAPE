// --- オリジナルのimage_blendを保持 ---
if (!variable_instance_exists(id, "orig_blend")) {
    orig_blend = image_blend;
}

// --- 実行制御: 一時停止モード（フレーム送り対応） ---
if (variable_global_exists("gamePaused") && global.gamePaused) {
    if (variable_global_exists("stepAdvance") && global.stepAdvance) {
        // 処理は続行
        path_speed = spd; //コマ送り時は速度を復元
    } else {
        // 一時停止中は image_speed も止める
        path_speed = 0; 
        image_speed = 0;

        // 弾を保持中は向きだけ維持（windup中など）
        if (instance_exists(myball) && myball.state == 0) {
			
		    var _draw_scale = (variable_instance_exists(id, "draw_scale") ? draw_scale : 1);
		    var base_hold_offset = 16;  // 元の基準距離（32px想定からの半身/手前くらい）
		    var offset = base_hold_offset * _draw_scale;
			
            myball.x = x + lengthdir_x(offset, dir);
            myball.y = y + lengthdir_y(offset, dir);

            //構え中は見た目の角度も維持（Preciseマスクの回転一致）
            myball.image_angle = dir;
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

        var b = instance_create_depth(x, y, depth, O_Arrow);
        b.dir = fire_dir;
        b.state = 1; // 発射状態

        // ★★ 追加: デバッグ発射時も見た目スケールを矢へ継承
        b.image_xscale = image_xscale;
        b.image_yscale = image_yscale;
        // ★★ 追加: 角度も見た目に適用
        b.image_angle = b.dir;
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
			    if (instance_exists(self.myball)) {
			        var _draw_scale = (variable_instance_exists(id, "draw_scale") ? draw_scale : 1);
			        var base_hold_offset = 16;
			        var offset = base_hold_offset * _draw_scale;
			        self.myball.x = x + lengthdir_x(offset, dir);
			        self.myball.y = y + lengthdir_y(offset, dir);
			        self.myball.image_angle = dir;
			    }

			} else if (shootTimer >= windupTime && shootTimer < windupTime + 1) {
			    // 2) 発射の瞬間：S_Enemy_Shot に切替えて即発射
			    if (sprite_index != S_Enemy_Shot) {
			        sprite_index = S_Enemy_Shot; 
			        image_index = 0; 
			        image_speed = 1;
			    }

			    // windup が終わったら発射（最終エイム反映）
			    if (instance_exists(myball)) {
			        if (instance_exists(O_Player)) {
			            var _final_dir = point_direction(x, y, O_Player.x, O_Player.y);
			            myball.dir = _final_dir;
			            myball.image_angle = _final_dir; // 見た目も一致
			        }
			        myball.state = 1;
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

                    //発射元の見た目スケールを矢へ継承（方式A）
                    myball.image_xscale = image_xscale;
                    myball.image_yscale = image_yscale;

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

            //ここで最後に汎用アニメ処理を軽く呼ぶ（深度やフラッシュの反映目的）
            //ただし sprite_index は上の分岐でコントロールしているため、Enemy_anim は呼ばないか、
            //呼ぶ場合は sprite_index を上書きしない設計にしておくこと。
            // Enemy_anim(); // ← S_Enemy_Charge / S_Enemy_Shot / S_Enemy_Idle を上書きしたくない場合は呼ばない
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
