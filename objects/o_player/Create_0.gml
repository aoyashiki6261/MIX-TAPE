event_inherited();
walk_spd = PLAYER_WALK_SPEED;
facing_dir        = 0; // スプライトの向き

// --- 攻撃関連 ---
mouseAttack = false;
hitByAttack = ds_list_create();

death_timer = 0;
deadanimstarted = false;

// ★ 先にステート定義を置く（この下で state を使うため）
enum PLAYERSTATE {
    FREE,
    ATTACK_SLASH,
    DEAD,
    DODGE
}

// --- 緊急回避関連(★緊急回避の数値を変えるのはこの部分) ---
dodge_duration     = PLAYER_DODGE_DURATION_FRAMES;
dodge_speed        = PLAYER_DODGE_SPEED_PER_FRAME;
dodge_cooldown_max = PLAYER_DODGE_COOLDOWN_FRAMES;

// --- 緊急回避関連(×初期化用なので以下の数値は基本触らないこと) ---
dodge_cooldown    = 0;           // カウントダウン管理用
dodge_timer       = 0;           // 残り回避フレーム
dodge_dir         = 0;           // 緊急回避の方向（角度）
dodge_dir_x       = 0;           // 回避方向のX成分
dodge_dir_y       = 0;           // 回避方向のY成分
last_move_dir_x   = 1;           //  直近の移動方向を保持（移動時のみ緊急回避）１
last_move_dir_y   = 0;           //  直近の移動方向を保持（移動時のみ緊急回避）２
invincible        = false;       // 無敵状態かどうか
dash              = false;

sprite_index = S_Player_Idle;

cursor_sprite = S_Cursor;
window_set_cursor(cr_none);

state = PLAYERSTATE.FREE;

// --- 入力状態フラグ初期化 ---
function update_input_flags() {
    static is_space_down     = false, was_space_down     = false;
    static is_pad_down       = false, was_pad_down       = false;
    static is_attack_down    = false, was_attack_down    = false;

    was_space_down   = is_space_down;
    was_pad_down     = is_pad_down;
    was_attack_down  = is_attack_down;

    var gp = 0;
    is_space_down    = keyboard_check(vk_space);
    is_pad_down      = gamepad_is_connected(gp) && gamepad_button_check(gp, gp_face1);
    is_attack_down   = mouse_check_button(mb_left) || (gamepad_is_connected(gp) && gamepad_button_check(gp, gp_face3));

    return {
        pressed_space : (!was_space_down  && is_space_down),
        pressed_pad   : (!was_pad_down    && is_pad_down),
        pressed_attack: (!was_attack_down && is_attack_down)
    };
}

// --- プレイヤー入力状態の初期化 ---
function reset_variables() {
    left  = 0;
    right = 0;
    up    = 0;
    down  = 0;
    hmove = 0;
    vmove = 0;
    dash  = false;
}

// --- 入力取得（pressed情報も渡す） ---
function get_input(pressed_space, pressed_pad) {
    // キーボード入力
    if (keyboard_check(ord("A"))) left  = 1;
    if (keyboard_check(ord("D"))) right = 1;
    if (keyboard_check(ord("W"))) up    = 1;
    if (keyboard_check(ord("S"))) down  = 1;
    if (pressed_space)               dash  = true;

    var gp = 0;
    if (gamepad_is_connected(gp)) {
        // アナログスティック
        var sx = gamepad_axis_value(gp, gp_axislh);
        var sy = gamepad_axis_value(gp, gp_axislv);
        var th = 0.5;
        if (sx < -th) left  = 1;
        if (sx >  th) right = 1;
        if (sy < -th) up    = 1;
        if (sy >  th) down  = 1;
        // D-Pad入力
        if (gamepad_button_check(gp, gp_padu))    up    = 1;
        if (gamepad_button_check(gp, gp_padd))    down  = 1;
        if (gamepad_button_check(gp, gp_padl))    left  = 1;
        if (gamepad_button_check(gp, gp_padr))    right = 1;
        if (pressed_pad) dash = true;
    }
}

// === 先行入力（入力バッファ） ===
enum ACTION {
    NONE,
    ATTACK,
    DODGE
}

buffered_action = ACTION.NONE;   //予約中の次アクション
buffer_timer    = 0;             //先行入力の残りフレーム
buffer_window   = PLAYER_INPUT_BUFFER_WINDOW;   //★先行入力の受付フレーム数

//ステートスクリプトから参照する“先行入力のミラー”を初期化
pressed_space_i  = false;
pressed_pad_i    = false;
pressed_attack_i = false;

/// バッファを消す
function buffer_clear() {
    buffered_action = ACTION.NONE;
    buffer_timer = 0;
}

/// 今のstateが「先行入力受付OKの終盤」かどうか
function buffer_accept_window() {
    switch (state) {
        case PLAYERSTATE.ATTACK_SLASH:
            // 攻撃アニメの残りフレーム数で判定
            var remaining = sprite_get_number(sprite_index) - image_index;
            return (remaining <= buffer_window);

        case PLAYERSTATE.DODGE:
            // 回避中は Roll の残りタイマー or End中ならOK
            if (sprite_index == S_Player_Dodge_Roll) return (dodge_timer <= buffer_window);
            if (sprite_index == S_Player_Dodge_End)  return true;
            return false;

        default:
            return false;
    }
}

/// 先行入力を記録（最後の入力で上書き）
function buffer_try_record(_pressed_attack, _pressed_space, _pressed_pad) {
    if (!buffer_accept_window()) return;

    // 回避入力（スペース or pad）
    if (_pressed_space || _pressed_pad) {
        buffered_action = ACTION.DODGE;
        buffer_timer = buffer_window;
    }
    // 攻撃入力（最後に評価 → “最後の入力”が勝つ）
    if (_pressed_attack) {
        buffered_action = ACTION.ATTACK;
        buffer_timer = buffer_window;
    }
}

/// 毎フレームの寿命管理
function buffer_update() {
    if (buffer_timer > 0) {
        buffer_timer--;
        if (buffer_timer <= 0) buffer_clear();
    }
}

/// 入力方向から回避ベクトルを決定（方向が無ければ false）
function choose_dodge_dir_from_input() {
    var gp = 0;

    // スティック優先
    var stick_x = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislh) : 0;
    var stick_y = gamepad_is_connected(gp) ? gamepad_axis_value(gp, gp_axislv) : 0;
    var mag = point_distance(0, 0, stick_x, stick_y);
    if (mag > 0.2) {
        dodge_dir_x = stick_x / mag;
        dodge_dir_y = stick_y / mag;
        return true;
    }

    // デジタル（WASD / D-Pad）
    var dir_x = right - left;
    var dir_y = down  - up;
    var len   = point_distance(0, 0, dir_x, dir_y);
    if (len != 0) {
        dodge_dir_x = dir_x / len;
        dodge_dir_y = dir_y / len;
        return true;
    }

    // 方向なし
    return false;
}

