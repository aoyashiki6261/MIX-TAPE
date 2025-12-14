// すでにインスタンス変数で target_room が設定されていなければ、デフォルトを Rm_Debug にする
if (!variable_instance_exists(id, "target_room")) {
    target_room = Rm_Debug; // ← 予備のデフォルト（なくてもOKなら削ってもよい）
}

// デバッグ用に可視化
visible     = true;
image_alpha = 1;