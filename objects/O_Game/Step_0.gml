// 実行制御用の初期化（Createイベントで実行）
if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;
}
if (!variable_global_exists("stepAdvance")) {
    global.stepAdvance = false;
}

