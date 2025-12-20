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
		var _dis = (_dead ? 4 : 1);
		var _dir = point_direction(_sid.x, _sid.y, x, y);
		hsp +=lengthdir_x(_dis, _dir);
		vsp +=lengthdir_y(_dis, _dir);
		calc_path_delay = _time;
		alert = true;
		knockback_time = _time;
		return _dead;
	}
}
// これを実行しているインスタンスが死亡しているかどうかを確認
function is_dead(){

    // 既にDEADなら true（ここで終了）
    if (state == states.DEAD) return true;

    if (hp <= 0){
        show_debug_message("[is_dead] state->DEAD id=" + string(id)
            + " obj=" + string(object_get_name(object_index)));
        state       = states.DEAD;
        hp          = 0;
        image_index = 0;

        // ★ プレイヤーが死んだときだけゲームオーバーフラグON
        if (object_index == O_Player) {
            global.gameOver = true;

        } else {
            // ★ 敵などプレイヤー以外：キルカウントを加算
            //    Enemy_MarkKill はどこか一カ所で定義されている前提で「そのまま呼ぶ」
            Enemy_MarkKill();
        }

        //死亡時のsound設定（既存）
        switch(object_index){	
            default:   break;
            case O_Player: break;
        }

        return true;
    }

    return false; // 生存中
}
