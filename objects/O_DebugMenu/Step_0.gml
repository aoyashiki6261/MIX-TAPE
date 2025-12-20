if (gamepad_button_check_pressed(0, gp_face1)) { 

    if (room == Rm_Debug) {

        // インゲームへ戻る
        if (variable_global_exists("returnRoom")
        && room_exists(global.returnRoom)) {
            room_goto(global.returnRoom);
        }
        else {
            // ★ デバッグルーム起動時のフォールバック（初回起動用）
            room_goto(Rm_Main); // ← インゲーム開始ルーム
        }

    } else {

        // デバッグルームへ
        global.returnRoom = room;
        room_goto(Rm_Debug);
    }

    instance_destroy();
}
