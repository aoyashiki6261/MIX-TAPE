if (state == states.DEAD) {
	Enemy_anim(); // 死亡用アニメーション再生
	hsp = 0;
	vsp = 0;
	path_end(); // 移動停止

	death_timer++;
	if (death_timer > 900) {//敵の死体が消えるまでのカウント(1秒="60")
		instance_destroy(); // 死体を一定時間後に削除
	}
	return; // 以降の処理をスキップ
}

switch(state){
	case states.IDLE:
		calc_entity_movement();
		Check_For_Player();
		if path_index != -1 state = states.MOVE;
		Enemy_anim();
	break;
	case states.MOVE:
		calc_entity_movement();
		Check_For_Player();
		check_facing();
		if path_index == -1 state = states.IDLE;
		Enemy_anim();
	break;
	case states.DEAD:
		calc_entity_movement();
		hsp = 0;// 動きを完全に止める
		vsp = 0;
	    path_end();
		 // タイマー加算して、一定時間後に消える
		death_timer++;
		if (death_timer > 90) // 90フレーム = 1.5秒
		{ 
		instance_destroy();
		}
	break;
	case states.ATTACK:
		calc_entity_movement();
		Enemy_anim();
	break;
			}
			
#region
		
		//プレイヤーの方向取得
			if instance_exists(O_Player)
			{
				dir = point_direction(x,y,O_Player.x,O_Player.y);
			}
		
		//正しい速度に設定
			spd = 0;
			
		//アニメーションの停止(画像インデックスを手動で設定)
		image_index = 0;
		
		//弾を発射
		    shootTimer = irandom(cooldownTime);
			shootTimer++;
		
				//弾を作成
				if shootTimer == 1
				{
					state = states.ATTACK; 
					 var ballInst = instance_create_depth(x, y, depth, O_Enemy_Ball);// ローカル変数として弾を生成（他の敵と干渉しない）


			    // プレイヤーの方向に向かって飛ばす角度を計算して代入
			    if instance_exists(O_Player)
			    {
			         ballInst.dir = point_direction(x, y, O_Player.x, O_Player.y);
					 ballInst.spd = 1;  // 弾の速度を設定
					 ballInst.state = 1;  // 弾の状態をに切り替え
			    }

			    // 弾の移動スピード
			    ballInst.spd = 4;

			    // この敵の弾として記録（あとで state=1 にするため）
			    self.myball = ballInst;
				}
				
				//弾を敵の保持
				if shootTimer <= windupTime && instance_exists(self.myball)
				{
					self.myball.x = x + ballXoff * face;
					self.myball.y = y + ballYoff;
				}
				
				//準備時間が終わったら弾を発射
				if shootTimer == windupTime && instance_exists(self.myball)
				{
					//弾を移動状態に設定。
					self.myball.state = 1;
				}
			
				//回復してプレイヤーの追跡状態に戻る。
				if shootTimer > windupTime + recoverTime
				{
					//プレイヤーへの追跡再開
					state = states.MOVE;
					
					//タイマーをリセットして再び使用できるようにする
					shootTimer = 0;
					
					// 弾の参照をクリア（次回発射用に）
					self.myball = noone;
				}
				
#endregion


		//射撃ステートに移行
		var _camLeft = camera_get_view_x(view_camera[0]);
		var _camRight = _camLeft + camera_get_view_width(view_camera[0]);
		var _camTop = camera_get_view_y(view_camera[0]);
		var _camBottom = _camTop + camera_get_view_height(view_camera[0]);
				
		//画面に表示されている場合のみタイマーに追加
		if bbox_right > _camLeft && bbox_left < _camRight && bbox_bottom > _camTop && bbox_top < _camBottom
		{		
			shootTimer++;
		}
		
		
		if shootTimer > cooldownTime
		{
			state = states.MOVE;
			
			//タイマーをリセットし、射撃状態を再使用できるようにする
			shootTimer = 0;
		}
		