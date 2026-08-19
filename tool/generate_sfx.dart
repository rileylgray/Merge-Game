// Synthesises the game's sound effects as 16-bit PCM WAV files.
//
// Run with:  dart run tool/generate_sfx.dart
//
// Like the creature art, the audio is generated rather than sourced. That
// keeps the whole app free of licensed binary assets, keeps the bundle tiny
// (every cue is a few KB), and means a tweak is a code change and a rerun.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int kSampleRate = 44100;

void main() {
  final Directory dir = Directory('assets/audio');
  dir.createSync(recursive: true);

  _write('${dir.path}/tap.wav', _tap());
  _write('${dir.path}/spawn.wav', _spawn());
  _write('${dir.path}/merge.wav', _merge());
  _write('${dir.path}/discover.wav', _discover());
  _write('${dir.path}/coin.wav', _coin());
  _write('${dir.path}/error.wav', _error());

  for (final FileSystemEntity f in dir.listSync()) {
    if (f is File) {
      stdout.writeln('${f.path}  ${(f.lengthSync() / 1024).toStringAsFixed(1)} KB');
    }
  }
}

// --------------------------------------------------------------------- voices

/// A struck-bell partial: sine at [freq] decaying over [decay] seconds.
void _bell(
  List<double> buf, {
  required double startSec,
  required double freq,
  required double amp,
  required double decay,
  double detune = 0,
}) {
  final int start = (startSec * kSampleRate).round();
  final int length = (decay * 3.2 * kSampleRate).round();
  for (int i = 0; i < length; i++) {
    final int idx = start + i;
    if (idx >= buf.length) break;
    final double t = i / kSampleRate;
    // 4 ms attack ramp keeps the onset from clicking.
    final double attack = (t / 0.004).clamp(0.0, 1.0);
    final double env = attack * math.exp(-t / decay);
    buf[idx] += amp * env * math.sin(2 * math.pi * (freq + detune) * t);
  }
}

/// A short tone that glides from [from] to [to] Hz.
void _sweep(
  List<double> buf, {
  required double startSec,
  required double durSec,
  required double from,
  required double to,
  required double amp,
  double decay = 0.10,
}) {
  final int start = (startSec * kSampleRate).round();
  final int length = (durSec * kSampleRate).round();
  double phase = 0;
  for (int i = 0; i < length; i++) {
    final int idx = start + i;
    if (idx >= buf.length) break;
    final double t = i / kSampleRate;
    final double p = i / length;
    final double freq = from + (to - from) * p;
    phase += 2 * math.pi * freq / kSampleRate;
    final double attack = (t / 0.004).clamp(0.0, 1.0);
    final double env = attack * math.exp(-t / decay);
    buf[idx] += amp * env * math.sin(phase);
  }
}

List<double> _buffer(double seconds) =>
    List<double>.filled((seconds * kSampleRate).round(), 0);

// ---------------------------------------------------------------------- cues

/// Soft UI click.
List<double> _tap() {
  final List<double> b = _buffer(0.10);
  _bell(b, startSec: 0, freq: 1180, amp: .22, decay: .022);
  _bell(b, startSec: 0, freq: 2360, amp: .07, decay: .014);
  return b;
}

/// A friend hops out of the basket: a little rising pop.
List<double> _spawn() {
  final List<double> b = _buffer(0.24);
  _sweep(b, startSec: 0, durSec: .12, from: 520, to: 960, amp: .26, decay: .055);
  _bell(b, startSec: .06, freq: 1320, amp: .12, decay: .045);
  return b;
}

/// Two friends become one: a bright two-note chime, a major third apart.
List<double> _merge() {
  final List<double> b = _buffer(0.55);
  // C6 then E6.
  _bell(b, startSec: 0, freq: 1046.5, amp: .30, decay: .085);
  _bell(b, startSec: 0, freq: 2093.0, amp: .10, decay: .055);
  _bell(b, startSec: .075, freq: 1318.5, amp: .30, decay: .130);
  _bell(b, startSec: .075, freq: 2637.0, amp: .09, decay: .070);
  _bell(b, startSec: .075, freq: 3955.5, amp: .04, decay: .045);
  return b;
}

/// New species discovered: a four-note arpeggio that lands an octave up.
List<double> _discover() {
  final List<double> b = _buffer(1.15);
  const List<double> notes = <double>[523.25, 659.25, 783.99, 1046.5];
  for (int i = 0; i < notes.length; i++) {
    final double at = i * .085;
    final bool last = i == notes.length - 1;
    _bell(b, startSec: at, freq: notes[i], amp: .26, decay: last ? .34 : .13);
    _bell(b, startSec: at, freq: notes[i] * 2, amp: .09, decay: last ? .22 : .08);
    _bell(b, startSec: at, freq: notes[i] * 3, amp: .035, decay: .06);
  }
  // A sparkle tail so the fanfare resolves rather than just stopping.
  _bell(b, startSec: .40, freq: 2093, amp: .07, decay: .22);
  _bell(b, startSec: .48, freq: 2637, amp: .05, decay: .20);
  return b;
}

/// Hearts spent or collected.
List<double> _coin() {
  final List<double> b = _buffer(0.34);
  _bell(b, startSec: 0, freq: 1568, amp: .24, decay: .045);
  _bell(b, startSec: .045, freq: 2349, amp: .20, decay: .105);
  _bell(b, startSec: .045, freq: 3136, amp: .07, decay: .060);
  return b;
}

/// Something could not happen — deliberately gentle, never a buzzer.
List<double> _error() {
  final List<double> b = _buffer(0.28);
  _sweep(b, startSec: 0, durSec: .16, from: 300, to: 196, amp: .22, decay: .075);
  return b;
}

// ------------------------------------------------------------------ encoding

void _write(String path, List<double> samples) {
  // Normalise to a consistent headroom so no cue is jarringly louder than the
  // rest, then apply a short fade-out to guarantee a click-free ending.
  double peak = 0;
  for (final double s in samples) {
    peak = math.max(peak, s.abs());
  }
  final double gain = peak == 0 ? 1 : 0.82 / peak;

  final int fade = math.min(samples.length, (0.008 * kSampleRate).round());
  final Int16List pcm = Int16List(samples.length);
  for (int i = 0; i < samples.length; i++) {
    double v = samples[i] * gain;
    final int fromEnd = samples.length - i;
    if (fromEnd < fade) v *= fromEnd / fade;
    pcm[i] = (v.clamp(-1.0, 1.0) * 32767).round();
  }

  File(path).writeAsBytesSync(_wav(pcm));
}

Uint8List _wav(Int16List pcm) {
  const int channels = 1;
  const int bitsPerSample = 16;
  final int dataBytes = pcm.length * 2;
  final int byteRate = kSampleRate * channels * bitsPerSample ~/ 8;

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
