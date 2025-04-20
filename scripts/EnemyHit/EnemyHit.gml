			

function EnemyHit(argument0) {
	var _damage = argument0;
	hp -= _damage;
	flash = true;
	if (hp > 0)
	{
		state = states.HIT;
		hitNow = true;
	}
	else
	{
	show_debug_message("敵が死亡しました");
	state = states.DEAD;
	}
		
		state = states.DEAD;
	}
