/// O_WarpZone - Collision with O_Player

// target_room が正しく設定されているか確認
if (variable_instance_exists(id, "target_room") && room_exists(target_room)) {

    // --- ワープ発動条件フラグ ---
    var do_warp = false;

    // ① ゲームパッドの L スティック押し込み（L3）
    if (gamepad_is_connected(0)) {
        if (gamepad_button_check_pressed(0, gp_stickl)) {
            do_warp = true;
        }
    }

    // ②（任意）キーボードでもテストしたい場合はコメントアウト解除
    // if (keyboard_check_pressed(ord("E"))) {
    //     do_warp = true;
    // }

    // --- 条件を満たしたらワープ実行 ---
    if (do_warp) {
        show_debug_message(
            "[Warp] from " + room_get_name(room)
            + " to " + room_get_name(target_room)
        );
        room_goto(target_room);
    }

} else {
    // target_room が未設定 / 不正だった場合の保険
    show_debug_message("[Warp] target_room が未設定 or 不正です (id=" + string(id) + ")");
}