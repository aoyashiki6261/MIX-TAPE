hSpeed = 0;
vSpeed = 0;

if (!variable_instance_exists(self, "sprite_index")) {
    sprite_index = S_Player_Idle;  // 初期化されていない場合はデフォルトのスプライトを設定
}

// 初期化の確認
if (!variable_instance_exists(self, "hitByAttack")) {
    hitByAttack = ds_list_create();  // 初期化

//攻撃の開始
if (sprite_index != S_Player_Attack)
{
	sprite_index = S_Player_Attack;
	image_index = 0;
	ds_list_clear(hitByAttack);
}

//攻撃の当たり判定＆当たった時のチェック
mask_index = S_Player_AttackHB;
var hitByAttackNow = ds_list_create();
var hits = instance_place_list(x,y,O_enemy,hitByAttackNow,false);//敵のオブジェクトを追加したらここの敵オブジェクト名を変更すること。
if (hits > 0)
{
	for(var i =0; i < hits; i++)
	{
		//このインスタンスがまだこの攻撃を受けていない場合
		var hitID = hitByAttackNow[| i];
		if(ds_list_find_index(hitByAttack,hitID) == -1)
		{
			ds_list_add(hitByAttack,hitID);
			with(hitID)
			{
				EnemyHit(2);
				
			}
			
			
		
		}
		
		
	}
}
ds_list_destroy(hitByAttackNow);
mask_index = S_Player_Idle;

if(animation_end())
{
	sprite_index = S_Player_Idlel
	state = PLAYERSTATE.FREE;
}
}