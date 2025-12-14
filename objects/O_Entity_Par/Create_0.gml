//以前の位置を初期化
state = states.IDLE;
xp = x;
yp = y;
facing = 1;
hsp = 0;
vsp = 0;
//どれくらいの時間Entityはノックバックされているか
knockback_time = 0;

damage = DMG_INSTANCE_DAMAGE_DEFAULT;
hitConfirm = false;