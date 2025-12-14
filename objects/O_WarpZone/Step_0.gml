if (instance_exists(O_Player)) {

    // プレイヤーがこのワープゾーンに触れているか？
    var p = instance_place(x, y, O_Player);

    if (p != noone) {
        // ★ このフレームは「触れている」とフラグを立てる
        global.warpZoneHint = true;

        // L3（左スティック押し込み）でワープ実行
        if (gamepad_button_check_pressed(0, gp_stickl)) {

            // target_room が設定されていればそこへワープ
            if (variable_instance_exists(id, "target_room") && target_room != noone) {
                room_goto(target_room);
            }
        }
    }
}