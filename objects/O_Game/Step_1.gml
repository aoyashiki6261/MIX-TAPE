/// O_Game Begin Step

// 念のための安全初期化
if (!variable_global_exists("gamePaused"))        global.gamePaused        = false;
if (!variable_global_exists("stepAdvance"))       global.stepAdvance       = false;
if (!variable_global_exists("stepAdvanceFrames")) global.stepAdvanceFrames = 0;

// ★ ポーズ中だけ「このフレームを進めるか」を決定
if (global.gamePaused) {
    if (global.stepAdvanceFrames > 0) {
        // このフレームは 1 コマ進める
        global.stepAdvanceFrames--;
        global.stepAdvance = true;
    } else {
        // 完全停止
        global.stepAdvance = false;
    }
} else {
    // ポーズ解除中は常に普通に進行（stepAdvance は使わない）
    global.stepAdvance       = false;
    global.stepAdvanceFrames = 0;
}

global.warpZoneHint = false;
