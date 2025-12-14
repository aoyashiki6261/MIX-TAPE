/// O_DebugController Create

// --- デバッグ系グローバル変数の初期化 ---
//  既にどこかで作られていれば上書きしない

if (!variable_global_exists("enemyAIEnabled")) {
    global.enemyAIEnabled = true;
}

// 敵の固定発射方向（デバッグ用）
// 0:UP, 1:LEFT, 2:DOWN, 3:RIGHT, 4:OFF
if (!variable_global_exists("enemyFireDirection")) {
    global.enemyFireDirection = 4;
}

// 一時停止 / コマ送り関連
if (!variable_global_exists("gamePaused")) {
    global.gamePaused = false;       // Tキーで一時停止
}
if (!variable_global_exists("stepAdvance")) {
    global.stepAdvance = false;      // 「このフレームだけ進める」フラグ
}
if (!variable_global_exists("stepAdvanceFrames")) {
    global.stepAdvanceFrames = 0;    // 進めたいフレーム数（予約）
}
if (!variable_global_exists("stepAdvanceTimer")) {
    global.stepAdvanceTimer = 0;     // 長押し用タイマー
}

// ゲームパッドデバッグON/OFF（R3）
if (!variable_global_exists("gamepadDebugEnabled")) {
    global.gamepadDebugEnabled = false;
}

// デバッグ：ヒットボックス可視化フラグの初期化
if (!variable_global_exists("debugShowPlayerAttackHB")) {
    global.debugShowPlayerAttackHB = false;
}