function Enemy_anim(){
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
		sprite_index = S_Enemy_Attack;
	break
	case states.DEAD:
		sprite_index = S_Enemy_Dead;
	　  image_speed = 0.2;
	break;
	}
	//深度の設定
	depth = -bbox_bottom;
	//前の位置を更新
	xp = x;
	yp = y;
}

function calc_entity_movement(){
	//敵を移動し、ドラッグ(時間の経過とともに敵の速度を遅くすること)を適用


	//移動速度(xsp,hsp)の初期化
	hsp = 0;
	vsp = 0;

	//動きを適用
	x += hsp;
	y += vsp;
	
	//遅くする
	hsp *= global.drag;
	vsp *= global.drag;
	
	
	check_if_stopped();
}

function check_if_stopped(){
	if abs(hsp) < 0.1 hsp = 0;
	if abs(vsp) < 0.1 vsp = 0;
}

function check_facing(){
	//どちらの方向に進んでいるか確認し、向きを設定
	if knockback_time <= 0{
	var _facing = sign(x - xp);
	if _facing != 0 facing = _facing;
	}

}

function show_hurt(){
	//ノックバック時にダメージを受けたスプライトを表示
	
	if knockback_time-- > 0 sprite_index = S_Enemy_Hit;

}


function Check_For_Player(){
	
	//移動ステートじゃなければ何もしない
	if state != states.MOVE {
		return;
	}
	
	///敵が追いかけ始めるのにプレイヤーに十分近いかをチェック
	var _dis = 99999; // デフォルトの大きい距離
	if (instance_exists(O_Player)) {
	    _dis = distance_to_object(O_Player);
	}
	
	
	//パスを計算する必要があるかを確認
	if calc_path_timer-- <= 0{
		//タイマーをリセット
		calc_path_timer = calc_path_delay;
		
	//プレイヤーへのパスを作成できるか？
	if (instance_exists(O_Player)) {
    var _type = (x == xp and y == yp) ? 0 : 1;
    var _found_player = mp_grid_path(global.mp_grid, path, x, y, O_Player.x, O_Player.y, _type);

	//プレイヤーに到達できるならパスを開始
    if (_found_player) {
        path_start(path, move_spd, path_action_stop, false);
    }
}
	//攻撃できる程の近い距離か？
	if _dis <= attack_dis{
		path_end();
	}
}
}
