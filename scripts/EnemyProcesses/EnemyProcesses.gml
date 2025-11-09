// グローバル変数が未定義なら初期化
if (!variable_global_exists("enemyAIEnabled")) {
    global.enemyAIEnabled = true;
}

// AI無効時は移動と攻撃をスキップする（デバッグルーム限定）
if (room_get_name(room) == "Rm_Debug" && !global.enemyAIEnabled) {
    // AIオフ中：スプライトの表示とアニメ処理だけ（移動・攻撃処理は行わない）
    Enemy_anim();
    return;
}

function Enemy_anim(){
	// AI無効時はアニメーションを停止（ただしスプライトの切り替えは行う）
	if (room_get_name(room) == "Rm_Debug" && !global.enemyAIEnabled) {
		image_speed = 0;
		sprite_index = S_Enemy_Idle; // ← 止まるときに表示したいスプライトに変更
		depth = -bbox_bottom;
		xp = x;
		yp = y;
		return;
	}

	// 状態に応じたスプライト切り替え
	switch(state){
		case states.IDLE:
			sprite_index = S_Enemy_Idle;
			show_hurt();
		break;
		case states.MOVE:
			sprite_index = S_Enemy_Walk;
			show_hurt();
		break;
		case states.ATTACK:
			// ★ ATTACK中はStep側が S_Enemy_Charge / S_Enemy_Shot / Idle を制御するため、ここでは上書きしない
			//   （必要なら show_hurt() だけは通してOK）
			show_hurt();
		break;
		case states.DEAD:
			sprite_index = S_Enemy_Dead;
			image_speed = 0.2;
		break;
	}

	// アニメーション速度を通常に戻す（AIが有効なときだけ）
	image_speed = 1;

	// 深度の設定
	depth = -bbox_bottom;
	// 前の位置を更新
	xp = x;
	yp = y;
}

function calc_entity_movement() {
    if (path_index == -1) {
	// 敵を移動し、ドラッグ（時間の経過とともに敵の速度を遅くすること）を適用

	// 移動速度（xsp, hsp）の初期化
	hsp = 0;
	vsp = 0;

	// 動きを適用
	x += hsp;
	y += vsp;

	// 遅くする
	hsp *= global.drag;
	vsp *= global.drag;
	}
	check_if_stopped();
}

function check_if_stopped(){

    if (is_undefined(hsp)) hsp = 0;
    if (is_undefined(vsp)) vsp = 0;

    if (abs(hsp) < 0.1) hsp = 0;
    if (abs(vsp) < 0.1) vsp = 0;
}

function check_facing(){
	if knockback_time <= 0 {
		if instance_exists(O_Player) {
			var _dir = point_direction(x, y, O_Player.x, O_Player.y);
			facing = (abs(angle_difference(_dir, 0)) <= 90) ? 1 : -1;
		}
	}
}

function show_hurt(){
    // ノックバック時にダメージを受けたスプライトを表示
    if (is_undefined(knockback_time)) knockback_time = 0; // 念のため保険

    if (knockback_time > 0) {
        sprite_index = S_Enemy_Hit;
        knockback_time--; // ← 条件式の外で減算
    }
}

function Check_For_Player(){

    var _dis = 99999;
    if (instance_exists(O_Player)) {
        _dis = distance_to_object(O_Player);
    }

    if (is_undefined(calc_path_timer)) calc_path_timer = 0;   // 念のため保険
    if (is_undefined(calc_path_delay)) calc_path_delay = 15;  // 念のため保険

    if (calc_path_timer <= 0) {            // ← 先に判定
        calc_path_timer = calc_path_delay; // ← それからリセット

        if (instance_exists(O_Player)) {
            var _type = (x == xp && y == yp) ? 0 : 1;
            var _found_player = mp_grid_path(global.mp_grid, path, x, y, O_Player.x, O_Player.y, _type);

            if (_found_player) {
                path_start(path, spd, path_action_stop, false);
            }
        }

        if (_dis <= attack_dis) {
            path_end();
            state = states.ATTACK;
        }
    }

    calc_path_timer--; // ← 判定の後に減算
	
/// @description この敵のキルを一度だけ加算する
function Enemy_MarkKill() {
    // ★ 既にカウント済み or まだインスタンスが有効でないなら何もしない
    if (kill_counted) return;

    global.kills = min(global.kills + 1, 9999);
    kill_counted = true;

    // ★ デバッグ（原因追跡用）
    show_debug_message("[KILL] id=" + string(id)
        + " total=" + string(global.kills));
	}
}
