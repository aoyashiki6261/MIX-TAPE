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

// ★追加：クールダウン進行（処理が進むフレームだけ）
if (state != states.ATTACK && state != states.DEAD) {
    if (cooldownTimer < cooldownTime) {
        cooldownTimer++;
    }
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
		
		// ★追加：死亡した瞬間にSEを鳴らす（最初の1回だけ）
	    if (audio_exists(Snd_EnemyDead)) {
	        audio_play_sound(Snd_EnemyDead, 0, false);
	    }
		
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

        // ★追加：距離とクールダウンで行動を分岐
        var _dis = point_distance(x, y, O_Player.x, O_Player.y);

        if (_dis <= attack_dis) {
            // ★追加：範囲内は「止まって待つ」＝IDLE維持
            spd = 0;
            hsp = 0;
            vsp = 0;
            path_end();

            // ★追加：クールダウンが終わっていればATTACKへ
            if (cooldownTimer >= cooldownTime) {
                cooldownTimer = 0; // ★ここで消費（次の攻撃まで待つ）
                shootTimer = 0;
                state = states.ATTACK;
	            }
	        } else {
	            // ★追加：範囲外なら追いかける
	            state = states.MOVE;
	        }
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

            // ★追加：距離に入ったら「移動を止めて待機」する（重なり防止）
            spd = 0;
            hsp = 0;
            vsp = 0;
            path_end();

            // ★追加：クールダウンが終わっていればATTACKへ
            if (cooldownTimer >= cooldownTime) {
                cooldownTimer = 0; // ★ここで消費（次の攻撃まで待つ）
                shootTimer = 0;
                state = states.ATTACK;
            } else {
		        // ★追加：MOVE中に範囲へ入った場合はIDLEへ遷移して待機する
		        state = states.IDLE;
            }

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

            // -------------------------
			// ATTACK：溜め → 発射 → 硬直
			// -------------------------
			case states.ATTACK:
			{
			    // --- 一時停止 / コマ送り対応（このフレームを進めるか？） ---
			    var do_step_attack = (!global.gamePaused || global.stepAdvance);
			    if (!do_step_attack) break;  // ポーズ中＆stepAdvanceなしなら何もしない

			    // ★ デバッグ用：固定方向発射モードかどうか（Rm_Debug かつ enemyFireDirection != OFF）
			    var use_fixed_fire = false;
			    if (room_get_name(room) == "Rm_Debug"
			     && variable_global_exists("enemyFireDirection")
			     && global.enemyFireDirection != 4) {
			        use_fixed_fire = true;
			    }

			    // ★ エイム方向更新（通常 or 固定発射）
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
			        // 通常時：プレイヤー方向にエイム
			        if (instance_exists(O_Player)) {
			            dir = point_direction(x, y, O_Player.x, O_Player.y);
			            check_facing(); // dir に応じて image_xscale 更新
			        }
			    }

			    // 移動は止めておく
			    spd = 0;

			    // ------------------------------------
			    // ★ シグナル生成：このフレームだけ 1 回
			    // ------------------------------------
			    if (shootTimer == signal_start_frame) {

			        // 既に古いシグナルが残っていたら掃除
			        if (instance_exists(attack_signal)) {
			            with (attack_signal) instance_destroy();
			        }

			        // 向きに応じてオフセットを決定（O_Enemy のインスタンス変数を利用）
			        var sx_sig, sy_sig;
			        if (facing >= 0) {
			            // 右向き
			            sx_sig = x + signal_offset_right_x;
			            sy_sig = y + signal_offset_right_y;
			        } else {
			            // 左向き
			            sx_sig = x + signal_offset_left_x;
			            sy_sig = y + signal_offset_left_y;
			        }

			        // シグナルを 1 回だけ生成
			        var sig = instance_create_depth(sx_sig, sy_sig, depth - 1, O_Enemy_AttackSignal);

			        // どの敵のシグナルか紐付け（追従用）
			        sig.owner          = id;
			        sig.offset_right_x = signal_offset_right_x;
			        sig.offset_right_y = signal_offset_right_y;
			        sig.offset_left_x  = signal_offset_left_x;
			        sig.offset_left_y  = signal_offset_left_y;

			        attack_signal = sig;
			        // 以降は O_Enemy_AttackSignal 側が寿命管理（アニメ終わりで自滅）を担当
			    }

			    // ------------------------------------
			    // ここから下は「溜め → Shot → 硬直」の既存処理
			    // ※ シグナルにはもう触らない
			    // ------------------------------------

			    // Shotスプライトを見せるフレーム数
			    var _shot_frames_to_show = max(30, (sprite_exists(S_Enemy_Shot) ? sprite_get_number(S_Enemy_Shot) : 1));

			    // 1) 溜め中：S_Enemy_Charge を手動フレーム進行（ループさせない）
			    if (shootTimer < windupTime) {
			        if (sprite_index != S_Enemy_Charge) {
			            sprite_index = S_Enemy_Charge;
			            image_index  = 0;
			            image_speed  = 0;   // 自動再生を止める（ループ防止）
			        }

			        var _frames = max(1, sprite_get_number(S_Enemy_Charge));
			        var _t = clamp(shootTimer, 0, windupTime - 1);
			        image_index = min(_frames - 1, floor(_t * _frames / windupTime));

			        // （この時点では矢はまだ存在しない）
			    }
			    // 2) 発射の瞬間：S_Enemy_Shot に切替えて「このフレームで矢を生成＆発射」
			    else if (shootTimer == windupTime) {

			        // Shotスプライトに切り替え
			        if (sprite_index != S_Enemy_Shot) {
			            sprite_index = S_Enemy_Shot;
			            image_index  = 0;
			            image_speed  = 1;
						//発射した瞬間にクールダウンを消費（満タン方式の起点）
						cooldownTimer = 0;
			        }

			        // 発射方向を決定（通常時：プレイヤー方向 / 固定発射時：ZLの方向）
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

			        // 矢の出現基準位置（左右別オフセット）
			        var bx, by;
			        if (image_xscale >= 0) {
			            // 右向き
			            bx = x + arrow_offset_right_x;
			            by = y + arrow_offset_right_y;
			        } else {
			            // 左向き
			            bx = x + arrow_offset_left_x;
			            by = y + arrow_offset_left_y;
			        }

			        // 手の位置から、矢の向きに arrow_forward 分だけ前に出す
			        var _sx = bx + lengthdir_x(arrow_forward, _final_dir);
			        var _sy = by + lengthdir_y(arrow_forward, _final_dir);

			        // ここで矢を生成＆即発射状態にする
			        myball = instance_create_depth(_sx, _sy, depth, O_Arrow);
			        myball.dir         = _final_dir;
			        myball.image_angle = _final_dir;
			        myball.state       = 1; // 発射状態
			    }
				
				
			    // 3) 発射後：S_Enemy_Shot を数フレームだけ見せ続ける
			    else if (shootTimer > windupTime && shootTimer <= (windupTime + _shot_frames_to_show)) {
			        if (sprite_index != S_Enemy_Shot) {
			            sprite_index = S_Enemy_Shot;
			            image_index  = 0;
			            image_speed  = 1;
			        }
			        // 矢はすでに飛んでいるので特に処理なし
			    }
			    // 4) 発射後～硬直：Idle（Recover的な時間）
			    else if (shootTimer > (windupTime + _shot_frames_to_show)
			          && shootTimer <= windupTime + recoverTime) {

			        if (sprite_index != S_Enemy_Idle) {
			            sprite_index = S_Enemy_Idle;
			            image_index  = 0;
			            image_speed  = 1;
			        }
			    }

			    // 5) 硬直終了 → 移動へ戻る
			    if (shootTimer > windupTime + recoverTime) {

			        // 念のため攻撃シグナルもここで消す（Animation End 側で消えていれば何もしない）
			        if (instance_exists(attack_signal)) {
			            with (attack_signal) instance_destroy();
			        }
			        attack_signal = noone;

			        state       = states.MOVE;
			        shootTimer  = 0;
			        myball      = noone;

			        calc_path_timer = 0;
			        Check_For_Player();
			    }

			    // ★ 最後に shootTimer を進める
			    shootTimer++;
			}
			break;

}