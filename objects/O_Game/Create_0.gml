// AIの有効/無効を制御するグローバル変数を初期化
if (!variable_global_exists("enemyAIEnabled")) {
    global.enemyAIEnabled = true;
}