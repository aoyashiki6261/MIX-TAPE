function EnemyState_Hit() {
	//Just hit
	if (hitNow)
	{
		sprite_index = S_Enemy_Hit
		image_index = 0;
		hitNow = false;
		frameCount = 0;
	}

	frameCount++;
	if (frameCount > 20) 
	{
		frameCount = 0;
		state = states.IDLE;
	}


}
