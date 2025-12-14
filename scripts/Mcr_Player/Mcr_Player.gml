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
#macro DMG_DEFAULT_MAX_HP              10         // maxHp / hp の初期値（汎用）

// 無敵時間ONのときに使っている iframeNumber の値。
// 「プレイヤーがダメージを受けたあと何フレーム無敵か」を決める。
#macro DMG_IFRAME_DURATION_FRAMES      90         // iframeNumber（無敵時間の長さ）

// ダメージインスタンスのデフォルトダメージ。
// O_Entity_Par, O_DamageParent で damage = 1; としている部分の共通値。
#macro DMG_INSTANCE_DAMAGE_DEFAULT     1          // 弾など1発あたりの基本ダメージ


// --------------------------------------------------
// プレイヤーの基本ステータス / 移動
// （O_Player の Create イベント用）
// --------------------------------------------------

// プレイヤーの通常歩き速度（O_Player.walk_spd）
// 「細かくちょこちょこ動く」感じを決めるパラメータ。
#macro PLAYER_WALK_SPEED               0.25       // walk_spd の初期値

// アナログスティックのデッドゾーン（移動用）
// Calc_movement() 内の deadzone = 0.1; に対応。
// これより小さいスティック入力は無視して、意図しない微振れを消す。
#macro PLAYER_STICK_DEADZONE_MOVE      0.1        // 移動入力として受け取るスティックの最小強さ


// --------------------------------------------------
// プレイヤーの攻撃（斬り）パラメータ
// --------------------------------------------------

// 斬り攻撃1発あたりのダメージ量。
// Player_State_Attack_Slash / Player_ProcessAttack の EnemyHit(2); で使っている値。
#macro PLAYER_SLASH_DAMAGE             2          // 近接攻撃の基本ダメージ

// 攻撃アニメのうち「当たり判定を有効にするフレーム」の指定。
// O_Player_Step 内で image_index（0〜）を見て、2 or 3 フレームの時だけ
// mask_index = S_Player_Attack_HB; に切り替えている仕様に対応。
#macro PLAYER_SLASH_HIT_FRAME_START    2          // 攻撃判定ON開始フレーム（image_index）
#macro PLAYER_SLASH_HIT_FRAME_END      3          // 攻撃判定ON終了フレーム（image_index）

// 将来的に「攻撃モーションの長さ」などを管理したくなったときのためのマクロ。
// いまは animation_end() ベースなので未使用だが、調整窓口として定義しておく。
#macro PLAYER_SLASH_TOTAL_FRAMES       20         // 攻撃モーション全体の目安フレーム数


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
#macro PLAYER_DODGE_COOLDOWN_FRAMES    0          // 回避終了後の待機フレーム数

// 回避方向を決めるときのスティック入力のデッドゾーン。
// choose_dodge_dir_from_input() 内の mag > 0.2 に対応。
// これより弱い入力では回避方向が決まらない（＝回避自体が不発になる）。
#macro PLAYER_STICK_DEADZONE_DODGE     0.2        // 回避方向を決める最小スティック強さ


// --------------------------------------------------
// 先行入力（入力バッファ）
// （buffer_window, buffer_* 系に対応）
// --------------------------------------------------

// 攻撃・回避の先行入力を何フレーム保持するか。
// O_Player Create で buffer_window = 6; としている部分の窓口。
// 大きくすると「ボタン連打でかなり先まで予約」しやすくなる。
#macro PLAYER_INPUT_BUFFER_WINDOW      6          // 先行入力受付フレーム数


// --------------------------------------------------
// プレイヤー死亡演出
// （Player_State_Dead 用）
// --------------------------------------------------

// プレイヤーが死んでから消えるまでのフレーム数。
// Player_State_Dead で death_timer > 900; の判定に対応。
#macro PLAYER_DEATH_DESPAWN_FRAMES     900        // 死亡後にインスタンスを消すまでの時間