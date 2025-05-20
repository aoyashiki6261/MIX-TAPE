// デバッグルームでのみAI状態を表示
if (room_get_name(room) == "Rm_Debug") {
    var status = global.enemyAIEnabled ? "ON" : "OFF";
    var text = "[Pkey_EnemyAI:" + status + "]";
    
	draw_set_color(c_green);
	draw_set_halign(fa_left);  // 左寄せに変更
	draw_set_valign(fa_bottom); // 下寄せを追加
	draw_text(0, room_height + 480, text);  // 左下に描画
	}