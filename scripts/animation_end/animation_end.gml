/* ──────────────────────────────────────────────────────────────
■animation_end() の要点
【目的】
- 「このステップでアニメが終わるか？」を true/false で返す。
【効果】
 - 攻撃や回避の「終わり」を簡単に判定できる
 - FPS指定のスプライトや、一時停止中の“1フレだけ進める”にも対応
 - 中で room_speed は使わず、game_get_speed(gamespeed_fps) を使う

【GIF読み込みの注意】
- GIFは“連番フレーム（subimage）”として取り込まれるだけで自動停止もしないし、最後だから勝手にイベントが走ることもない。

【使い分け】
- ざっくりでOK → 組み込みの「Animation End イベント」
  （※ image_speed > 0 で回っていて、終端を越えた瞬間に1回だけ発火）
- ステート駆動／ポーズ中の一歩送りがある → この animation_end() を任意の場所で判定

【よく使うパターン】
  - ステート内で「終わったら次へ」を自分で決めたいとき
  　例：if (animation_end()) {
          // 次のステートへ or 入力バッファを消費
      }
　- 最終フレームで停止（ループさせない）
    例：if (animation_end()) {
	        image_index = sprite_get_number(sprite_index) - 1;
	        image_speed = 0;
	  }

【注意】
- Animation End イベントは「終端を越えた瞬間」にだけ発火（image_speed==0 だと進まない→発火しない）。
- 止めたい／切り替えたい挙動はコードで“明示的に”行うこと。
────────────────────────────────────────────────────────────── */

function animation_end() {

	//returns true if the animation will loop this step.

	//Script courtesy of PixellatedPope & Minty Python from the GameMaker subreddit discord 
	//https://www.reddit.com/r/gamemaker/wiki/discord

	var _sprite = sprite_index;
	var _image = image_index;

	if (argument_count > 0) _sprite = argument[0];
	if (argument_count > 1) _image = argument[1];

	var _type = sprite_get_speed_type(_sprite);
	var _spd = sprite_get_speed(_sprite) * image_speed;

	// --- 一時停止中で image_speed == 0 でも stepAdvance があれば仮の進行値を与える ---
	if (_spd == 0 && global.gamePaused && global.stepAdvance) {
		_spd = sprite_get_speed(_sprite) / game_get_speed(gamespeed_fps); // 通常の1フレーム分を進める
	}

	if (_type == spritespeed_framespersecond) {
		_spd = _spd / game_get_speed(gamespeed_fps);
	}

	if (argument_count > 2) _spd = argument[2];

	return _image + _spd >= sprite_get_number(_sprite);
}

