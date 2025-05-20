// デバッグルーム限定でAIのオン/オフを切り替える
if (room_get_name(room) == "Rm_Debug") {
    // Pキーが押されたらAIフラグを反転（true⇔false）
    if (keyboard_check_pressed(ord("P"))) {
        global.enemyAIEnabled = !global.enemyAIEnabled;

        // オプション：ログを出力（確認用）
        show_debug_message("Enemy AI: " + string(global.enemyAIEnabled));
    }
}