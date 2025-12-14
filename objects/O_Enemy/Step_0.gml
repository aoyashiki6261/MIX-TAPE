// -----------------------------
// 一時停止 / 1フレーム進行 対応
// -----------------------------
/// do_step == true のときだけ、この敵のロジック・移動・AIを進める
var do_step = true;

if (variable_global_exists("gamePaused") && global.gamePaused) {
    // ポーズ中：基本的には止める
    image_speed = 0;

    if (variable_global_exists("stepAdvance") && global.stepAdvance) {
        // ★ 1フレーム送り中：このフレームだけはロジックを進める
        //   → do_step = true のまま
    } else {
        // 完全停止：このフレームは一切処理しない
        do_step = false;
    }
} else {
    // 通常再生中
    image_speed = 1;
}

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

// ★ ポーズ中かつ 1フレーム進行でもない場合は、ここで完全停止
if (!do_step) {
    return;
}
// （必要なら）orig_blend の保持だけ残してOK
if (!variable_instance_exists(id, "orig_blend")) {
    orig_blend = image_blend;
}

// --- 死亡処理は全ルームで共通処理として分離 ---
if (state == states.DEAD) {
	
    // ★ 死体の表示順（奥に行かせたい）※マクロを使用
    depth = ENEMY_DEAD_DEPTH;   // 例: 100

    // 移動やAI処理停止
    path_end();
    hsp = 0;
    vsp = 0;
	
    // ★ 死亡時もシグナルを確実に消す
    if (variable_instance_exists(id, "attack_signal") && instance_exists(attack_signal)) {
        with (attack_signal) instance_destroy();
    }
    attack_signal = noone;

    // 弾がまだ存在していたら削除
    if (instance_exists(myball)) {
        with (myball) instance_destroy();
    }

    // 死亡スプライト・アニメーションをセット（最初のみ）
    if (sprite_index != S_Enemy_Dead) {
        sprite_index = S_Enemy_Dead;
        image_index  = 0;
        image_speed  = 0.2; // 死亡アニメ進行速度（止めないこと）
    }

    death_timer++;

    // 一定時間後に敵を削除（消滅処理）※マクロを使用
    if (death_timer > ENEMY_DEATH_LIFETIME_FRAMES) { // 例: 900
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
	            var move_speed = ENEMY_CHASE_MOVE_SPEED; // 足の速さ。お好みで調整
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

            // ★ デバッグ用：固定方向発射モードかどうか（Rm_Debug かつ enemyFireDirection != OFF）
            var use_fixed_fire = false;
            if (room_get_name(room) == "Rm_Debug"
             && variable_global_exists("enemyFireDirection")
             && global.enemyFireDirection != 4) {
                use_fixed_fire = true;
            }

            // ★ 攻撃中もエイム方向を更新
            if (use_fixed_fire) {
                // ZLデバッグ用：UP/LEFT/DOWN/RIGHT に応じて dir を固定
                switch (global.enemyFireDirection) {
                    case 0: dir = 90;  break; // UP
                    case 1: dir = 180; break; // LEFT
                    case 2: dir = 270; break; // DOWN
                    case 3: dir = 0;   break; // RIGHT
                }
                // dir に合わせて左右反転だけ揃える（0±90度=右、それ以外=左）
                facing = (abs(angle_difference(dir, 0)) <= 90) ? 1 : -1;
            } else {
                // ★ 通常時：プレイヤー方向にエイムを合わせておく（最終発射方向のベース）
                if (instance_exists(O_Player)) {
                    dir = point_direction(x, y, O_Player.x, O_Player.y);
                    // 攻撃中も左右反転（image_xscale）を更新する
                    check_facing();
                }
            }

            spd = 0;

            // --- 一時停止中でも1フレームだけ shootTimer を進行 ---
            do_step = (!global.gamePaused || global.stepAdvance);
            if (do_step) {

                // ★ 攻撃シグナル（S_Enemy_Attacksignal）の制御 ★
                //    → signal_start_frame ～ windupTime の少し手前まで表示
                //    → 終わりは必ず「矢が出る瞬間（windupTime）」で消える
                var sig_start = signal_start_frame; // ← Create で決めた開始フレーム

                if (shootTimer >= sig_start && shootTimer < windupTime) {

                    // シグナルの表示位置（左右で別のオフセットを使う）
                    var sx_sig, sy_sig;

                    var _is_left_sig = false;
                    if (instance_exists(O_Player)) {
                        _is_left_sig = (O_Player.x < x); // プレイヤーが左側にいるかどうか
                    }

                    if (_is_left_sig) {
                        // 左向き側
                        sx_sig = x + signal_offset_left_x;
                        sy_sig = y + signal_offset_left_y;
                    } else {
                        // 右向き側
                        sx_sig = x + signal_offset_right_x;
                        sy_sig = y + signal_offset_right_y;
                    }

                    // シグナル生成（まだ無ければ作る）
                    if (!instance_exists(attack_signal)) {
                        attack_signal = instance_create_depth(sx_sig, sy_sig, depth - 1, O_Enemy_AttackSignal);
                        attack_signal.image_speed = 0; // ★ ループさせたくないので自動再生は止める
                    } else {
                        attack_signal.x = sx_sig;
                        attack_signal.y = sy_sig;
                    }

                    // ★ sig_start〜windupTime の進行率に応じて image_index を手動設定
                    var frames_sig = sprite_get_number(S_Enemy_Attacksignal);
                    if (frames_sig > 0) {
                        var frame_idx = shootTimer - sig_start;

                        // コマ数を超えたら最後のコマで止めてループさせない
                        if (frame_idx >= frames_sig) {
                            frame_idx = frames_sig - 1;
                        }

                        attack_signal.image_index = frame_idx;
                    }

                    attack_signal.image_angle = 0;

                } else {
                    // ★ 指定タイミング外（特に windupTime 以降）はシグナルを確実に消す
                    if (instance_exists(attack_signal)) {
                        with (attack_signal) instance_destroy();
                    }
                    attack_signal = noone;
                }

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

                    // Shotスプライトに切り替え
                    if (sprite_index != S_Enemy_Shot) {
                        sprite_index = S_Enemy_Shot;
                        image_index = 0;
                        image_speed = 1;
                    }

                    // ★ 発射方向を決定（通常時：プレイヤー方向 / 固定発射時：ZLの方向）
                    var _final_dir;

                    if (use_fixed_fire) {
                        switch (global.enemyFireDirection) {
                            case 0: _final_dir = 90;  break; // UP
                            case 1: _final_dir = 180; break; // LEFT
                            case 2: _final_dir = 270; break; // DOWN
                            case 3: _final_dir = 0;   break; // RIGHT
                        }
                    } else {
                        _final_dir = dir;
                        if (instance_exists(O_Player)) {
                            _final_dir = point_direction(x, y, O_Player.x, O_Player.y);
                        }
                    }

                    // ★ 基準となる「矢の位置」（左右別オフセット）
                    var bx, by;
                    if (image_xscale >= 0) {
                        // 右向き時の矢の出現基準
                        bx = x + arrow_offset_right_x;
                        by = y + arrow_offset_right_y;
                    } else {
                        // 左向き時の矢の出現基準
                        bx = x + arrow_offset_left_x;
                        by = y + arrow_offset_left_y;
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