// AIの有効/無効を制御するグローバル変数を初期化
if (!variable_global_exists("enemyAIEnabled")) {
    global.enemyAIEnabled = true;
}

//フレームコマ送りの初期化
global.gamePaused = false;         // 一時停止フラグ
global.advanceOneFrame = false;    // 1フレームだけ進めるフラグ