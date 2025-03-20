
function check_facing(){
	//@desc check which way we are moving and set facing
	
	var _facing = sign(x - xp);
	if _facing != 0 facing = _facing;

}

function Check_For_Player(){
	
	///敵が追いかけ始めるのにプレイヤーに十分近いかをチェック
	var _dis = distance_to_object(O_Player);
	
	
	//パスを計算する必要があるかを確認
	if calc_path_timer-- <= 0{
		//タイマーをリセット
		calc_path_timer = calc_path_delay;
		
	//プレイヤーへのパスを作成できるか？
	var _type = (x == xp and y == yp) ? 0 : 1;
	var _found_player = mp_grid_path(global.mp_grid, path, x, y, O_Player.x, O_Player.y, _type);

	//プレイヤーに到達できるならパスを開始
	if _found_player{
		path_start(path, move_spd, path_action_stop, false);
	}
	}
	//攻撃できる程の近い距離か？
	if _dis <= attack_dis{
		path_end();
	}
}

function Enemy_anim(){
switch(state){
	case states.IDLE:
		sprite_index = S_Idle;
	break;
	case states.MOVE:
		sprite_index = S_Walk;
	break;
	case states.ATTACK:
		sprite_index = S_Attack;
	break
	case states.DEAD:
		sprite_index = S_Dead;
	break;
	}
	//update previous position
	xp = x;
	yp = y;
	
	
}