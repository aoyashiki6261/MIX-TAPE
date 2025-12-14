//ダメージ計算
	//ダメージ作成イベント
	function get_damaged_create(_hp = DMG_DEFAULT_MAX_HP, _iframes = false)
	{
	    maxHp = _hp;
	    hp    = _hp;

	    if _iframes == true {
	        iframeTimer  = 0;
	        iframeNumber = DMG_IFRAME_DURATION_FRAMES;
	    }
		
		//ダメージリストの作成
		if _iframes	==	false
		{
		damageList = ds_list_create();
		}
	}
	
	//ダメージクリーンアップイベント
	function get_damaged_cleanup()
	{
		//iframesが有効なときはダメージリストは無いのでクリーンアップイベントを行わない
		
		//ダメージリストのデータを空きメモリに削除
		ds_list_destroy(damageList);
	}
	
	//ダメージステップイベント
	function get_damaged(_damageObj, _iframes = false)
	{
		
		//iframesTimer用のspecial exitを使用(無敵時間中はexitを使うことでダメージを受ける以下のコーディングを無視することができる)
		if _iframes == true && iframeTimer > 0
		{
			iframeTimer--;
			
			if iframeTimer mod 5 == 0//無敵時間中の点滅表示
			{
				if image_alpha == 1
				{
					image_alpha = 0;
				}else{
					image_alpha = 1;
				}
			}
			
			//HPクランプ
			hp = clamp(hp, 0, maxHp);
			
			exit;
		}
		
		//無敵時間の点滅表示を停止
		if _iframes == true
		{
			image_alpha = 1;
		}
		
		//ダメージを受ける
		if place_meeting(x, y, _damageObj)
		{
	
			//ダメージインスタンスのDSリストを取得(1Fで同時に弾が当たった時にダメージが正しく反映されないため設定をする必要あり)
				//DSリストを作成して、インスタンスをDSリストへコピー
					var _instList = ds_list_create();
					instance_place_list(x,y,_damageObj,_instList,false);
		
				//DSリストのサイズを取得
					var _listSize = ds_list_size(_instList);
			
				//全ての弾IDからダメージを受けている事のチェックをループ処理で確認。
					var _hitConfirm = false;
			
					for(var i = 0; i < _listSize; i++)
					{
					//DSリストからダメージを受けたインスタンスを取得
					var _inst = ds_list_find_value(_instList,i);
		
		
					//このインスタンスが既にダメージリストにあるかを確認
					if _iframes == true || ds_list_find_index(damageList, _inst) == -1
					{
						//新しいダメージインスタンスをダメージリストに追加
						if _iframes == false
						{
							ds_list_add(damageList, _inst);
						}
						
						//特定のインスタンス(弾)からダメージを受けるようにチェック
						hp -= _inst.damage;
						_hitConfirm = true;
						//ダメージインスタンスに再度衝突したことを伝える(敵に当たっても弾が消えてほしくない場合は無効化)
						_inst.hitConfirm = true;
					}
				}
		
				//ダメージをうけた場合はiframe(無敵時間)を設定
				if _iframes == true && _hitConfirm
				{
					iframeTimer = iframeNumber;
				}
		
				//DSリストを破棄してメモリ解放
					ds_list_destroy(_instList);
		}

			//もう存在しない、または接触していないオブジェクトのダメージリストをクリア
			//(今接触していない or 消えた相手」をダメージ対象から外すことで、無駄な処理やバグを防ぎ、ゲームの挙動を安定化させる重要なメンテナンス処理)
			if _iframes == false
			{
				var _damageListSize = ds_list_size(damageList);
				for(var i = 0; i< _damageListSize; i++)
				{
					//ダメージインスタンスにもう触れていない場合は、リストから削除してループを1つ戻す
					var _inst = ds_list_find_value(damageList,i);
					if !instance_exists(_inst) || !place_meeting(x,y, _inst)
					{
						ds_list_delete(damageList, i);
						i--;
						_damageListSize--;
					}
		
				}
			}
			
			//HPクランプ
			hp = clamp(hp, 0, maxHp);
			
			
	}