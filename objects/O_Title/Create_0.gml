// 点滅用タイマー
blink_timer = 0;

// 「PRESS TO START」を表示するかどうか
press_visible = true;

// すでに流れているBGMを一旦全部止めて新しいBGMを再生する
audio_stop_all();
audio_play_sound(Snd_Bgm_Title, 1, true);

// すでにゲーム開始を受け付けたか（連打対策など）
started = false;