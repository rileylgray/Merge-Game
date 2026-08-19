// Synthesises the background music as a seamlessly looping 16-bit PCM WAV.
//
// Run with:  dart run tool/generate_music.dart
//
// Same bargain as the creature art and the sound cues: generated rather than
// licensed, so there is nothing to clear and a change is a code edit and a
// rerun. The piece is a slow pastoral pad in D major — drone, four crossfading
// chords, and a sparse pentatonic melody — deliberately static and low on
// event, because it has to survive being heard for an hour.
//
// ---------------------------------------------------------------------------
// How the loop is made seamless
// ---------------------------------------------------------------------------
//
// A loop that merely fades out and back in still breathes once per lap, and one
// that is simply cut at a zero crossing clicks. This file avoids both by making
// the waveform genuinely periodic over the loop length, using two rules:
//
//  1. Every sustained frequency is snapped to an exact multiple of 1/L, so each
//     voice completes a whole number of cycles per lap and arrives back at the
//     phase it started with. See [_snap].
//  2. Every decaying note is written with wrap-around, so a tail that runs past
//     the end of the buffer folds onto the opening instead of being chopped
//     off at the join. See [_wrap].
//
// The result joins to itself exactly — `test/audio_assets_test.dart` measures
// the step across the join and holds it to the size of an ordinary
// sample-to-sample step inside the track.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// 22.05 kHz, half the rate the cues use.
///
/// Nothing in the piece goes above about 3 kHz, so the extra bandwidth would be
/// paid for in megabytes and heard by nobody: at 44.1 kHz this one file would
/// outweigh every other asset in the app several times over.
const int kSampleRate = 22050;

/// Loop length in seconds.
///
/// The whole harmonic grid is derived from this, so changing it retunes the
/// snapping — it is not just a length. Long enough that the repeat is not
/// obvious, short enough to stay a reasonable download.
const int kLoopSeconds = 32;

/// Peak level of the written file. The runtime trim in `AudioService` sets how
/// loud the music actually sits under the cues; this is just headroom.
const double kPeak = 0.72;

const int kSamples = kLoopSeconds * kSampleRate;

/// Fixed seed: the same source must always produce byte-identical output, or
/// every rerun shows up as a spurious asset change.
final math.Random _rng = math.Random(20260806);

void main() {
  final List<double> buf = List<double>.filled(kSamples, 0);

  _drone(buf);
  _chords(buf);
  _melody(buf);

  final Directory dir = Directory('assets/audio');
  dir.createSync(recursive: true);
  final String path = '${dir.path}/music_meadow.wav';
  _write(path, buf);

  final File file = File(path);
  stdout.writeln(
    '$path  ${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB  '
    '${kLoopSeconds}s @ ${kSampleRate}Hz mono',
  );
  _reportSeam(buf);
}

// ------------------------------------------------------------------- helpers

/// Snaps [freq] to the nearest harmonic of the loop.
///
/// This is the trick the whole file rests on. A sine whose frequency is an
/// exact multiple of 1/L completes a whole number of cycles in one lap, so its
/// value and slope at the end of the buffer are exactly what they are at the
/// start. The grid is 1/32 Hz, so no note moves by more than 0.016 Hz — about
/// a thousandth of a semitone, and far below anything anyone can hear.
double _snap(double freq) => (freq * kLoopSeconds).round() / kLoopSeconds;

/// Index into the buffer, wrapping in both directions.
int _wrap(int i) => ((i % kSamples) + kSamples) % kSamples;

/// The phase of a snapped frequency at buffer position [index].
///
/// Taking the time from the wrapped position rather than from the start of the
/// note is what makes wrap-around safe: because [freq] is snapped, this is a
/// single continuous function of position around the whole loop, so a tail
/// that folds onto the opening lands in phase with everything already there.
double _phaseAt(int index, double freq, double offset) =>
    2 * math.pi * freq * (_wrap(index) / kSampleRate) + offset;

/// A random starting phase.
///
/// Without this every voice would cross zero together at the top of the loop
/// and stack into a small thump. Any constant offset is safe — it does not
/// affect periodicity.
double _randomPhase() => _rng.nextDouble() * 2 * math.pi;

// -------------------------------------------------------------------- voices

/// A sine that runs the whole lap, breathing on a slow LFO.
///
/// [lfoCycles] is a count per lap rather than a rate in Hz, because the
/// breathing has to close its own loop as exactly as the tone does.
void _pad(
  List<double> buf, {
  required double freq,
  required double amp,
  int lfoCycles = 1,
  double lfoDepth = .25,
}) {
  final double f = _snap(freq);
  final double lfo = lfoCycles / kLoopSeconds;
  final double phase = _randomPhase();
  final double lfoPhase = _randomPhase();

  for (int i = 0; i < kSamples; i++) {
    final double t = i / kSampleRate;
    final double breath = (1 - lfoDepth) +
        lfoDepth * (.5 + .5 * math.sin(2 * math.pi * lfo * t + lfoPhase));
    buf[i] += amp * breath * math.sin(2 * math.pi * f * t + phase);
  }
}

/// A chord tone that swells in and out around [centreSec].
///
/// The envelope is a Hann window written with wrap-around, so a swell centred
/// near the end of the lap bleeds into the opening rather than stopping dead.
/// Hann windows overlapped by half sum to a constant, so laying the four
/// chords out at even spacing with double-width windows crossfades them
/// without the total level pumping.
void _swell(
  List<double> buf, {
  required double centreSec,
  required double widthSec,
  required double freq,
  required double amp,
}) {
  final double f = _snap(freq);
  final double phase = _randomPhase();
  final int half = (widthSec * kSampleRate / 2).round();
  final int centre = (centreSec * kSampleRate).round();

  for (int k = -half; k <= half; k++) {
    final double p = (k + half) / (2 * half);
    final double window = .5 - .5 * math.cos(2 * math.pi * p);
    final int idx = _wrap(centre + k);
    buf[idx] += amp * window * math.sin(_phaseAt(idx, f, phase));
  }
}

/// A struck note that decays away. Its tail wraps around the join.
///
/// Three partials give it a soft mallet colour without needing a sample; the
/// upper ones decay faster, which is what stops it sounding like an organ.
void _pluck(
  List<double> buf, {
  required double atSec,
  required double freq,
  required double amp,
  required double decay,
}) {
  const List<double> partialGain = <double>[1.0, .28, .09];
  const List<double> partialDecay = <double>[1.0, .55, .35];

  for (int p = 0; p < partialGain.length; p++) {
    final double f = _snap(freq * (p + 1));
    if (f > kSampleRate * .45) continue;

    final double d = decay * partialDecay[p];
    // Four time constants is inaudible by the end; capped so a note can never
    // wrap far enough to overlap itself.
    final int length = math.min((d * 4 * kSampleRate).round(), kSamples);
    final int start = (atSec * kSampleRate).round();

    for (int i = 0; i < length; i++) {
      final double local = i / kSampleRate;
      // 12 ms attack: enough to take the edge off the onset, short enough to
      // still read as struck rather than swelled.
      final double attack = (local / .012).clamp(0.0, 1.0);
      final double env = attack * math.exp(-local / d);
      final int idx = _wrap(start + i);
      buf[idx] += amp * partialGain[p] * env * math.sin(_phaseAt(idx, f, 0));
    }
  }
}

// ---------------------------------------------------------------------- piece

// D major. Written out rather than computed so the harmony is readable.
const double d2 = 73.416;
const double a2 = 110.00;
const double d3 = 146.83;
const double fs3 = 185.00;
const double g3 = 196.00;
const double a3 = 220.00;
const double b3 = 246.94;
const double d4 = 293.66;
const double e4 = 329.63;
const double fs4 = 369.99;
const double g4 = 392.00;
const double a4 = 440.00;
const double b4 = 493.88;
const double d5 = 587.33;
const double e5 = 659.25;

/// The bed: a low D with its fifth, breathing very slowly.
void _drone(List<double> buf) {
  _pad(buf, freq: d2, amp: .30, lfoCycles: 1, lfoDepth: .18);
  _pad(buf, freq: a2, amp: .13, lfoCycles: 2, lfoDepth: .25);
  _pad(buf, freq: d3, amp: .10, lfoCycles: 3, lfoDepth: .30);
}

/// Four chords, one every eight seconds, each swelling across sixteen so that
/// neighbours overlap by half. D – G – Bm – A: diatonic, no leading tone
/// pulling anywhere, so the lap has no obvious seam musically either.
void _chords(List<double> buf) {
  const List<List<double>> voicings = <List<double>>[
    <double>[d3, fs3, a3, d4], // D
    <double>[g3, b3, d4, g4], // G
    <double>[fs3, b3, d4, fs4], // Bm
    <double>[a3, e4, a4, b4], // A(sus2)
  ];

  const double spacing = kLoopSeconds / 4;
  for (int c = 0; c < voicings.length; c++) {
    final double centre = c * spacing + spacing / 2;
    final List<double> notes = voicings[c];
    for (int n = 0; n < notes.length; n++) {
      // Upper voices sit back, or the chords crowd the melody.
      final double amp = .105 / (1 + n * .55);
      _swell(
        buf,
        centreSec: centre,
        widthSec: spacing * 2,
        freq: notes[n],
        amp: amp,
      );
    }
  }
}

/// A sparse D-major-pentatonic line. Notes are placed off the chord changes
/// rather than on them, and the last one is late enough that its tail is what
/// the loop opens on.
void _melody(List<double> buf) {
  const List<(double, double)> notes = <(double, double)>[
    (0.6, a4),
    (3.2, fs4),
    (6.0, d5),
    (9.4, b4),
    (12.1, d5),
    (15.0, g4),
    (17.8, fs4),
    (20.5, b4),
    (23.2, d5),
    (26.0, e5),
    (29.0, a4),
    (31.2, fs4),
  ];

  for (final (double at, double freq) in notes) {
    _pluck(buf, atSec: at, freq: freq, amp: .085, decay: 1.6);
  }
}

// ------------------------------------------------------------------ encoding

void _write(String path, List<double> samples) {
  double peak = 0;
  for (final double s in samples) {
    peak = math.max(peak, s.abs());
  }
  // A flat gain, and nothing else. No fade at the edges: a fade is exactly the
  // seam this file exists to avoid.
  final double gain = peak == 0 ? 1 : kPeak / peak;

  final Int16List pcm = Int16List(samples.length);
  for (int i = 0; i < samples.length; i++) {
    pcm[i] = ((samples[i] * gain).clamp(-1.0, 1.0) * 32767).round();
  }

  File(path).writeAsBytesSync(_wav(pcm));
}

/// Prints how big the step across the join is next to the biggest step found
/// anywhere inside the track. The first number should be no larger than the
/// second — that is what "seamless" means here.
void _reportSeam(List<double> samples) {
  double worst = 0;
  for (int i = 1; i < samples.length; i++) {
    worst = math.max(worst, (samples[i] - samples[i - 1]).abs());
  }
  final double seam = (samples.first - samples.last).abs();
  stdout.writeln(
    'seam step ${seam.toStringAsExponential(2)} '
    'vs worst internal step ${worst.toStringAsExponential(2)}',
  );
}

Uint8List _wav(Int16List pcm) {
  const int channels = 1;
  const int bitsPerSample = 16;
  final int dataBytes = pcm.length * 2;
  const int byteRate = kSampleRate * channels * bitsPerSample ~/ 8;

  final BytesBuilder out = BytesBuilder();
  void ascii(String s) => out.add(s.codeUnits);
  void u32(int v) => out.add(Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little));
  void u16(int v) => out.add(Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little));

  ascii('RIFF');
  u32(36 + dataBytes);
  ascii('WAVE');
  ascii('fmt ');
  u32(16);
  u16(1); // PCM
  u16(channels);
  u32(kSampleRate);
  u32(byteRate);
  u16(channels * bitsPerSample ~/ 8);
  u16(bitsPerSample);
  ascii('data');
  u32(dataBytes);
  out.add(pcm.buffer.asUint8List(0, dataBytes));

  return out.toBytes();
}
