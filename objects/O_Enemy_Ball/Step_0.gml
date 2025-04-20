// ステートマシーン
switch (state) {

	// 敵が打つまで待機（弾を停止、敵が打つまで待機の状態）
	case 0:
		// プレイヤーを狙う
		if instance_exists(O_Player) {
			dir = point_direction(x, y, O_Player.x, O_Player.y);
		}

		// 弾が目立つように敵よりも高い位置で深度を設定
		depth = -y - 50;
	break;

	// 弾の発射 / 移動
	case 1:
		// 移動のコーディング
		xspd = lengthdir_x(spd, dir);
		yspd = lengthdir_y(spd, dir);
		x += xspd;
		y += yspd;

		// 深度の更新
		depth = -y;

		// プレイヤーとの当たり判定（1撃で死亡）
		if instance_exists(O_Player) && place_meeting(x, y, O_Player) {
			var target = instance_place(x, y, O_Player);
			if (target != noone) {
				with (target) {
					if (state != PLAYERSTATE.DEAD && !deadanimstarted) {
						state = PLAYERSTATE.DEAD;
					}
				}
				instance_destroy(); // 弾を削除
			}
		}
	break;
}

// クリーンアップ

// 画面外で削除
var _pad = 16;
if bbox_right < -_pad || bbox_left > room_width + _pad || bbox_bottom < -_pad || bbox_top > room_height + _pad {
	destroy = true;
}

// プレイヤーとのフラグによる削除（任意機能）
if hitConfirm == true && playerDestroy == true {
	destroy = true;
}

// 壁との当たり判定（削除）
if place_meeting(x, y, O_Solid) {
	destroy = true;
}

// 実際に削除
if destroy == true {
	instance_destroy();
}