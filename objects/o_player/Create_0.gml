event_inherited();
walk_spd = 0.75;
facing_dir        = 0; // スプライトの向き

// --- 攻撃関連 ---
mouseAttack = false;
hitByAttack = ds_list_create();

death_timer = 0;
deadanimstarted = false;

// --- 緊急回避関連(★緊急回避の数値を変えるのはこの部分) ---
dodge_duration     = 10;          // 移動が続くフレーム数
dodge_speed        = 8;           // 緊急回避の移動距離
dodge_cooldown_max = 0;          // クールダウンの長さ（60 = 1秒）

// --- 緊急回避関連(×初期化用なので以下の数値は基本触らないこと) ---
dodge_cooldown    = 0;           // カウントダウン管理用
dodge_timer       = 0;           // 残り回避フレーム
dodge_dir         = 0;           // 緊急回避の方向（角度）
dodge_dir_x       = 0;           // 回避方向のX成分
dodge_dir_y       = 0;           // 回避方向のY成分
invincible        = false;       // 無敵状態かどうか
dash              = false;

sprite_index = S_Player_Idle;

cursor_sprite = S_Cursor;
window_set_cursor(cr_none);

state = PLAYERSTATE.FREE;

// --- 入力状態フラグ初期化 ---
enum PLAYERSTATE {
    FREE,
    ATTACK_SLASH,
    ATTACK_COMBO,
    DEAD,
    DODGE
}

// --- 入力状態の更新関数（pressed_xxx を含む） ---
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
