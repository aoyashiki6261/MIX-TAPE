if (global.gamePaused && !global.stepAdvance) {
    return; // 更新スキップ
}
//弾がプレイヤーに触れた場合削除
if hitConfirm == true{instance_destroy();};

// フレーム送りが実行されたらリセット
if (global.stepAdvance) {
    global.stepAdvance = false;
}