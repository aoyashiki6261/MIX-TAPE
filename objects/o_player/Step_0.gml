/// O_Player Step

// --- フラグ: 一時停止中に1フレーム進行を許可するか ---
//   ・通常時        : global.gamePaused == false → do_step = true
//   ・一時停止中    : global.gamePaused == true かつ global.stepAdvance == true のフレームだけ do_step = true
var do_step = (!global.gamePaused || global.stepAdvance);

// --- アニメーション速度制御 ---
image_speed = (do_step ? 1 : 0);

// プレイヤーを常に最前面に
depth = -100000;

// ※ update_input_flags(), reset_variables(), get_input() は Create イベントで定義済み

// --- 入力状態を更新し、押しっぱなし/押した瞬間を取得 ---
var input_flags   = update_input_flags();
var pressed_space = input_flags.pressed_space;
var pressed_pad   = input_flags.pressed_pad;
var pressed_attack= input_flags.pressed_attack;

// 先行入力用ミラー（各ステートスクリプトから参照）
pressed_space_i  = pressed_space;
pressed_pad_i    = pressed_pad;
pressed_attack_i = pressed_attack;

// --- 入力取得（常に） ---
//    一時停止中でも「どの方向を押しているか」「どのボタンを押したか」は拾っておく
reset_variables();
get_input(pressed_space, pressed_pad);

// --- クールダウン減算（処理が進むフレームだけ） ---
if (do_step && dodge_cooldown > 0) {
    dodge_cooldown--;
}

// --- 先行入力バッファの寿命管理（処理が進むフレームだけ） ---
if (do_step) {
    buffer_update();
}

// --- ステートマシン ---
if (do_step) {
    switch (state) {
        case PLAYERSTATE.FREE:
            Player_State_Free(do_step);
            break;

        case PLAYERSTATE.DODGE:
            Player_State_Dodge(do_step);
            break;

        case PLAYERSTATE.ATTACK_SLASH:
            Player_State_Attack_Slash(do_step);
            break;

        case PLAYERSTATE.DEAD:
            Player_State_Dead(do_step);
            break;
    }

    // ★攻撃マスク切り替え：攻撃アニメ 5フレーム中の 3〜4 フレームだけHBを使う
    if (state == PLAYERSTATE.ATTACK_SLASH) {
        var frame = floor(image_index); // 0〜4 のどれかになる想定

        if (frame == 2 || frame == 3) {
            // 3・4フレーム目だけ、攻撃用マスクを使う
            mask_index = S_Player_Attack_HB;
        } else {
            // それ以外のフレームでは通常マスクに戻す
            mask_index = -1; // -1 = sprite_index のマスクを使う
        }
    } else {
        // 攻撃ステート以外では常に通常マスク
        mask_index = -1;
    }

    // 攻撃ボタン押下の共通処理（先行入力もここで処理）
    if (pressed_attack) {
        Player_HandleAttackPress();
    }
}

// ★ プレイヤーが死亡ステートになっていたら GAME OVER フラグを立てる
//   （一時停止中でも毎フレームチェックする）
if (state == PLAYERSTATE.DEAD) {
    if (!global.playerDead) {
        global.playerDead = true;
        global.gameOver  = true;
    }
}