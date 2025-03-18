function Check_For_Player(){
	///敵が追いかけ始めるのにプレイヤーに十分近いかをチェック
	
	var _dis = distance_to_object(O_Player);
	
	
	//パスを計算する必要があるかを確認
	if calc_path_timer-- <= 0{
		//タイマーをリセット
		calc_path_timer = calc_path_delay;
		
	//プレイヤーへのパスを作成できるか？
	var _found_player = mp_grid_path(global.mp_grid, path, x, y, O_Player.x, O_Player.y, choose(0,1));

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
