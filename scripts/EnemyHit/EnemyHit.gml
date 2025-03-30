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
		state = states.DEAD;
	}
}