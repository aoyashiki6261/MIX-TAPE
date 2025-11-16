// --- フラグ: 一時停止中に1フレーム進行を許可するか ---
var do_step = (!global.gamePaused || global.stepAdvance);

// --- アニメーション速度制御 ---
image_speed = (do_step ? 1 : 0);

depth = -100000;

// ※ update_input_flags(), reset_variables(), get_input() は Create イベントで定義済みとする

// --- 入力状態を更新し、戻り値を保存 ---
var input_flags   = update_input_flags();
var pressed_space = input_flags.pressed_space;
var pressed_pad   = input_flags.pressed_pad;
var pressed_attack= input_flags.pressed_attack;

// 先行入力
pressed_space_i  = pressed_space;
pressed_pad_i    = pressed_pad;
pressed_attack_i = pressed_attack;

// --- 入力取得（常に） ---
reset_variables();
get_input(pressed_space, pressed_pad);

// クールダウン減算（do_step 中のみ）
if (do_step && dodge_cooldown > 0) dodge_cooldown--;

//先行入力の寿命管理（毎フレーム）
if (do_step) buffer_update();

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

    // ★攻撃マスク切り替え：攻撃アニメ5フレーム中の3〜4フレームだけHBを使う
    if (state == PLAYERSTATE.ATTACK_SLASH) {
        var frame = floor(image_index); // 0〜4 のどれかになる想定

        if (frame == 2 || frame == 3) {
            // 3・4フレーム目だけ、攻撃用マスクを使う
            mask_index = S_Player_Attack_HB;
        } else {
            // それ以外のフレームでは通常マスクに戻す
            mask_index = -1; // -1 = sprite_indexのマスクを使う
        }
    } else {
        // 攻撃ステート以外では常に通常マスク
        mask_index = -1;
    }

    if (pressed_attack) Player_HandleAttackPress();

    // 1フレーム進行フラグリセット
    if (global.stepAdvance) global.stepAdvance = false;
}
