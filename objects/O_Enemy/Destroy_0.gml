//敵が死んだ時にまだ打っていない弾を削除
if instance_exists(ballInst) && ballInst.state == 0
{
	ballInst.destroy = true;
}

//キルカウンターのパス削除
if (!kill_counted && hp <= 0) {
    Enemy_MarkKill();
}