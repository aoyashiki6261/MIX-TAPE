enum states{
	IDLE,
	MOVE,
	HIT,
	ATTACK,
	DEAD,

}

global.mp_grid = 0;
global.drag = 0.93;

// ターゲットにダメージを与え、デッド状態を返す
function damage_entity( _tid, _sid, _damage, _time){
	//tid	  = ターゲットID(tid)
	//sid	  = ソースID(sid)
	//damege = 与えるダメージ(damage)
	//time   = ターゲットをノックバックさせる時間(time)
	
	with(_tid){
		hp -= _damage;
		var _dead = is_dead();
		path_end();
		//ノックバック距離を設定
		if _dead var _dis = 4 else var _dis =1;
		var _dir = point_direction(_sid.x, _sid.y, x, y);
		hsp +=lengthdir_x(_dis, _dir);
		vsp +=lengthdir_y(_dis, _dir);
		calc_path_delay = _time;
		alert = true;
		knockback_time = _time;
		return _dead;
	}
}
//これを実行しているインスタンスが停止しているかどうかを確認
function is_dead(){

	if state != states.DEAD{
		if hp <= 0{
			state = states.DEAD;
			hp = 0;
			image_index = 0;
			//死亡時のsound設定
			switch(object_index){	
				default:	
				//死亡時のsoundを再生
				break;
				case O_Player:
				//プレイヤー死亡時のsoundを再生
				break;
			}
			return true;
		}	
	}return true;
	
}