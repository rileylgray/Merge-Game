import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// The game's sound cues.
enum Sfx {
  /// Generic UI press.
  tap('audio/tap.wav', 0.45, 2),

  /// A friend hops out of the basket.
  spawn('audio/spawn.wav', 0.70, 2),

  /// Two friends merge into one.
  merge('audio/merge.wav', 0.85, 3),

  /// A species is seen for the first time.
  discover('audio/discover.wav', 0.95, 1),

  /// Hearts spent or collected.
  coin('audio/coin.wav', 0.65, 2),

  /// An action could not be completed.
  error('audio/error.wav', 0.50, 1);

  const Sfx(this.asset, this.volume, this.voices);

  final String asset;

  /// Per-cue trim so the mix is balanced without re-rendering the WAVs.
  final double volume;

  /// How many copies of this cue may sound at once.
  ///
  /// Only the cues a player can genuinely trigger on top of themselves need
  /// more than one. A merge chain is the fast case, so it gets the most.
  final int voices;
}

/// Something that holds the music quiet while it lasts, without touching the
/// player's setting.
enum MusicInterruption {
  /// The app is in the background. Nothing should still be playing out of it.
  backgrounded,

  /// A full-screen ad is up, and it has a soundtrack of its own.
  fullScreenAd,
}

/// Plays short sound effects through a set of players dedicated per cue.
///
/// Every cue owns its own players and each of those players is handed its
/// asset exactly once, at warm-up, and never given another. That is not
/// tidiness — it is the whole reason this class is shaped the way it is.
///
/// A shared round-robin pool looks cheaper and was what this used to be, but
/// it makes players swap assets between cues, and `audioplayers` low-latency
/// mode on Android keys loaded sounds by URL across *all* players sharing a
/// `SoundPool`. A player that switches asset is never unregistered from the
/// list for its old one (`SoundPoolPlayer.reset` is a no-op), so the next
/// player to pick up that old asset copies a stale sound id from it — and if
/// that id is not loaded yet it copies `null` while inheriting `prepared:
/// true`. `SoundPoolPlayer.start` then matches neither of its branches and
/// returns having played nothing, with no error and no log. Audibly: the
/// first cue fires and the next one silently does not.
///
/// Pinning one asset per player keeps every URL list honest, so that path is
/// never entered. It also makes replay cheap — the source never changes, so a
/// cue is just stop-and-resume rather than a fresh source hand-off.
///
/// Everything here is fire-and-forget and swallows its own errors: audio is a
/// garnish, and a device with a busy or broken audio route must never break
/// the game.
class AudioService {
  AudioService();

  final Map<Sfx, List<AudioPlayer>> _voices = <Sfx, List<AudioPlayer>>{};
  final Map<Sfx, int> _next = <Sfx, int>{};
  Future<void>? _warmUp;
  bool _ready = false;

  bool enabled = true;

  // ------------------------------------------------------------------- music

  /// The looping background track, built by `tool/generate_music.dart`.
  ///
  /// It gets its own player rather than a slot in the pool: the pool recycles
  /// players round-robin, which would cut the music off on the fourth cue.
  static const String musicAsset = 'audio/music_meadow.wav';

  /// What the generator wrote, and what `test/audio_assets_test.dart` holds it
  /// to. The loop length is not decorative — the whole track is tuned to a
  /// harmonic grid derived from it, so the two must agree.
  static const int musicSampleRate = 22050;
  static const int musicLoopSeconds = 32;

  /// Where the music sits under the cues. Low on purpose — it is a bed, and
  /// the cues have to stay legible over it.
  static const double _musicVolume = .34;

  /// Long enough not to read as a switch being flipped.
  static const Duration _fadeDuration = Duration(milliseconds: 1200);
  static const Duration _fadeStep = Duration(milliseconds: 50);

  AudioPlayer? _music;
  Timer? _fade;
  Completer<void>? _fadeDone;
  bool _musicFailed = false;

  /// Whether the player wants music at all. Distinct from [_musicDucked]:
  /// this one is the setting, and it survives an ad.
  bool _musicEnabled = true;

  /// Everything currently standing on top of the music.
  ///
  /// A set rather than a flag because two of these can overlap — an ad plays,
  /// which backgrounds the app on Android — and whichever ends first must not
  /// bring the music back on the other's behalf.
  final Set<MusicInterruption> _interruptions = <MusicInterruption>{};

  bool get musicEnabled => _musicEnabled;

  set musicEnabled(bool value) {
    if (_musicEnabled == value) return;
    _musicEnabled = value;
    unawaited(_applyMusicState(fade: true));
  }

  /// Silences the music without forgetting that the player wants it.
  void duckMusic(MusicInterruption reason, {required bool ducked}) {
    final bool changed =
        ducked ? _interruptions.add(reason) : _interruptions.remove(reason);
    if (!changed) return;
    // An ad cuts in with no warning, so ducking is abrupt on the way down and
    // eased on the way back.
    unawaited(_applyMusicState(fade: !ducked));
  }

  bool get _musicShouldPlay =>
      _musicEnabled && _interruptions.isEmpty && !_musicFailed;

  /// Brings what is actually happening into line with [_musicShouldPlay].
  ///
  /// Safe to call repeatedly and from anywhere; it is the only thing that
  /// starts, stops or retunes the music player.
  Future<void> _applyMusicState({required bool fade}) async {
    _cancelFade();

    if (!_musicShouldPlay) {
      final AudioPlayer? player = _music;
      if (player == null) return;
      if (fade) {
        await _rampVolume(player, from: _musicVolume, to: 0);
      }
      try {
        await player.pause();
        await player.setVolume(0);
      } on Object catch (e) {
        debugPrint('Mergelings: could not pause music — $e');
      }
      return;
    }

    try {
      AudioPlayer? player = _music;
      if (player == null) {
        player = AudioPlayer(playerId: 'music');
        // Gapless repeat on both platforms. The asset is built to join to
        // itself exactly, so there is nothing to cover up at the seam.
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setAudioContext(_musicContext());
        await player.setVolume(0);
        await player.play(AssetSource(musicAsset), volume: 0);
        _music = player;
      } else {
        await player.setVolume(0);
        await player.resume();
      }
      await _rampVolume(player, from: 0, to: _musicVolume, immediate: !fade);
    } on Object catch (e) {
      // One failure is enough: a device that cannot play the track will not
      // start managing it on the next toggle either.
      _musicFailed = true;
      debugPrint('Mergelings: music unavailable — $e');
    }
  }

  /// Steps the volume between two levels. `audioplayers` has no fade of its
  /// own, and a track this quiet appearing at full level still reads as a jolt.
  Future<void> _rampVolume(
    AudioPlayer player, {
    required double from,
    required double to,
    bool immediate = false,
  }) async {
    if (immediate) {
      try {
        await player.setVolume(to);
      } on Object {
        // Nothing useful to do; the next call will try again.
      }
      return;
    }

    final int steps =
        (_fadeDuration.inMilliseconds / _fadeStep.inMilliseconds).round();
    final Completer<void> done = Completer<void>();
    _fadeDone = done;
    int step = 0;

    _fade = Timer.periodic(_fadeStep, (Timer timer) async {
      step++;
      final double v = from + (to - from) * (step / steps);
      try {
        await player.setVolume(v.clamp(0.0, 1.0));
      } on Object {
        // A dead player will surface on the next start; keep the ramp going.
      }
      if (step >= steps) _cancelFade();
    });

    return done.future;
  }

  /// Stops any ramp in progress and releases whoever is waiting on it.
  ///
  /// Completing the future matters: a toggle flipped mid-fade cancels the
  /// previous ramp, and without this the call that started it would sit
  /// awaiting a timer that will never tick again.
  void _cancelFade() {
    _fade?.cancel();
    _fade = null;
    final Completer<void>? done = _fadeDone;
    _fadeDone = null;
    if (done != null && !done.isCompleted) done.complete();
  }

  /// Mirrors the cue context: never take audio focus, never duck whatever the
  /// player is already listening to. A game soundtrack is the last thing that
  /// should interrupt someone's podcast.
  AudioContext _musicContext() => AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const <AVAudioSessionOptions>{
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      );

  /// Starts the track if the setting allows. Called once the app is up.
  Future<void> startMusic() => _applyMusicState(fade: true);

  /// Mirrors the music context: never take audio focus, never duck whatever
  /// the player is already listening to.
  AudioContext _sfxContext() => AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const <AVAudioSessionOptions>{
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      );

  /// Creates the players and loads every cue up front, so the first merge is
  /// not delayed by platform channel setup or by an asset decode.
  ///
  /// Idempotent by held future rather than by flag: [play] calls this too, and
  /// the boot call is deliberately not awaited. A flag checked before the
  /// first `await` would let a cue racing start-up build a second set of
  /// players under playerIds that already exist, which on Android silently
  /// replaces the first set's platform players and event channels.
  Future<void> warmUp() => _warmUp ??= _warmUp0();

  Future<void> _warmUp0() async {
    for (final Sfx sfx in Sfx.values) {
      final List<AudioPlayer> voices = <AudioPlayer>[];
      for (int i = 0; i < sfx.voices; i++) {
        try {
          final AudioPlayer player = AudioPlayer(playerId: 'sfx_${sfx.name}_$i');
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setPlayerMode(PlayerMode.lowLatency);
          await player.setAudioContext(_sfxContext());
          // The one and only source this player will ever hold. Everything in
          // this class depends on that staying true — see the class comment.
          await player.setSource(AssetSource(sfx.asset));
          await player.setVolume(sfx.volume);
          voices.add(player);
        } on Object catch (e) {
          // One bad cue must not cost us the rest of the mix.
          debugPrint('Mergelings: ${sfx.name} unavailable — $e');
        }
      }
      if (voices.isNotEmpty) {
        _voices[sfx] = voices;
        _next[sfx] = 0;
      }
    }
    _ready = true;
  }

  /// Fire-and-forget. Safe to call from anywhere, including build-adjacent
  /// callbacks, and safe to call before [warmUp] has finished.
  void play(Sfx sfx) {
    if (!enabled) return;
    unawaited(_play(sfx));
  }

  Future<void> _play(Sfx sfx) async {
    if (!_ready) await warmUp();
    final List<AudioPlayer>? voices = _voices[sfx];
    if (voices == null || voices.isEmpty) return;

    // Round-robin within the cue, so a merge landing on top of the previous
    // one lets it ring out instead of chopping it off.
    final int i = _next[sfx]!;
    _next[sfx] = (i + 1) % voices.length;
    final AudioPlayer player = voices[i];

    try {
      // Rewind and go. The source is already set and stays set: this never
      // hands the platform a new one, which is what keeps rapid cues from
      // dropping.
      await player.stop();
      await player.resume();
    } on Object catch (e) {
      debugPrint('Mergelings: could not play ${sfx.name} — $e');
    }
  }

  Future<void> dispose() async {
    _cancelFade();
    for (final AudioPlayer player in <AudioPlayer?>[
      ..._voices.values.expand((List<AudioPlayer> v) => v),
      _music,
    ].whereType<AudioPlayer>()) {
      try {
        await player.dispose();
      } on Object {
        // Disposal races with platform teardown; nothing useful to do.
      }
    }
    _voices.clear();
    _next.clear();
    _music = null;
    _ready = false;
    _warmUp = null;
  }
}
