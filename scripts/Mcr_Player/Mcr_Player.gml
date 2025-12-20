/// @description プレイヤーまわりの数値調整用マクロ集
/// ここに書かれている数字だけを触れば、
/// ・移動速度
/// ・回避の長さ / クールダウン / スティックしきい値
/// ・攻撃ダメージ
/// ・無敵時間
/// ・死亡後に消えるまでの時間
/// などをまとめて調整できる想定です。

// --------------------------------------------------
// 共通・基礎
// --------------------------------------------------

// ゲーム全体のFPS。敵用マクロなどですでに GAME_FPS を定義している前提。
// プレイヤー側で「1秒 = GAME_FPS フレーム」という考え方を共有するための別名。
#macro PLAYER_FPS                       GAME_FPS   // プレイヤー側の時間計算用ベースFPS

// --------------------------------------------------
// ダメージ / HP / 無敵時間まわり
// （get_damaged_create / get_damaged 系で参照する前提）
// --------------------------------------------------

// get_damaged_create(_hp = 10, _iframes = false) の「デフォルトHP」。
// プレイヤーに限らず、何も指定しなかったときの最大HP。
#macro DMG_DEFAULT_MAX_HP              1         // maxHp / hp の初期値（汎用）

// --------------------------------------------------
// プレイヤーの基本ステータス / 移動
// （O_Player の Create イベント用）
// --------------------------------------------------

// プレイヤーの通常歩き速度（O_Player.walk_spd）
#macro PLAYER_WALK_SPEED               1       // walk_spd の初期値

// アナログスティックのデッドゾーン（移動用）
// Calc_movement() 内の deadzone = 0.1; に対応。
// これより小さいスティック入力は無視して、意図しない微振れを消す。
// スティックの遊び値（0..1） 例:0.2=20%
#macro PLAYER_STICK_DEADZONE_MOVE        0.10


// --------------------------------------------------
// プレイヤーの攻撃（斬り）パラメータ
// --------------------------------------------------

// 斬り攻撃1発あたりのダメージ量。
// Player_State_Attack_Slash / Player_ProcessAttack の EnemyHit(2); で使っている値。
#macro PLAYER_SLASH_DAMAGE             1          // 近接攻撃の基本ダメージ

// --------------------------------------------------
// プレイヤーの緊急回避（DODGE）
// （O_Player Create / Player_State_Dodge / Player_StateHelpers 用）
// --------------------------------------------------

// 回避が続くフレーム数（dodge_duration）
// Player_StartDodge() で dodge_timer = dodge_duration; としている部分に対応。
#macro PLAYER_DODGE_DURATION_FRAMES    10         // 1回の回避にかかるフレーム数

// 回避中1フレームあたりの移動速度（dodge_speed）
// Player_State_Dodge で x += dodge_dir_x * dodge_speed; に使われる値。
#macro PLAYER_DODGE_SPEED_PER_FRAME    8          // 回避中の移動速度（ピクセル/フレーム）

// 回避後のクールダウン（dodge_cooldown_max）
// Player_StartDodge() で dodge_cooldown = dodge_cooldown_max; に使う。
// 0 ならクールダウン無し。60 なら約1秒の待ち時間（60fps想定）。
#macro PLAYER_DODGE_COOLDOWN_FRAMES    20          // 回避終了後の待機フレーム数

// --------------------------------------------------
// 先行入力（入力バッファ）
// （buffer_window, buffer_* 系に対応）
// --------------------------------------------------

// 攻撃・回避の先行入力を何フレーム保持するか。
// 大きくすると「ボタン連打でかなり先まで予約」しやすくなる。
#macro PLAYER_INPUT_BUFFER_WINDOW      6          // 先行入力受付フレーム数