/// O_DebugController Create

// --- 永続化 ---
// room_restart() や room_goto() でもインスタンスを破棄させない
persistent = true;

// --- デバッグ系グローバル変数の初期化 ---
// ★ 初回生成インスタンスのみ実行するガード
var first_debug_ctrl = instance_find(O_DebugController, 0); // 最初のインスタンスを取得
if (id == first_debug_ctrl) {

    // 敵AIデバッグON/OFF
    if (!variable_global_exists("enemyAIEnabled")) {
        global.enemyAIEnabled = true;
    }

    // 敵の固定発射方向（0:UP,1:LEFT,2:DOWN,3:RIGHT,4:OFF）
    if (!variable_global_exists("enemyFireDirection")) {
        global.enemyFireDirection = 4;
    }

    // 一時停止 / コマ送り関連
    if (!variable_global_exists("gamePaused")) {
        global.gamePaused = false;
    }
    if (!variable_global_exists("stepAdvance")) {
        global.stepAdvance = false;
    }
    if (!variable_global_exists("stepAdvanceFrames")) {
        global.stepAdvanceFrames = 0;
    }
    if (!variable_global_exists("stepAdvanceTimer")) {
        global.stepAdvanceTimer = 0;
    }

    // ゲームパッドデバッグON/OFF（R3）
    if (!variable_global_exists("gamepadDebugEnabled")) {
        global.gamepadDebugEnabled = false;
    }

    // デバッグ：ヒットボックス可視化フラグ
    if (!variable_global_exists("debugShowPlayerAttackHB")) {
        global.debugShowPlayerAttackHB = false;
    }
}
