const List<String> _suffixes = <String>[
  '', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc',
  'UDc', 'DDc', 'TDc', 'QaDc', 'QiDc',
];

/// Compact idle-game number formatting: 950, 1.2K, 34.5M, 7.01B…
///
/// Deliberately locale-independent: the suffixes double as a visual shorthand
/// players learn once, and mixed decimal separators across five languages
/// would make the HUD jitter as values grow.
String formatCount(num value) {
  if (value.isNaN || value.isInfinite) return '0';
  final double v = value.toDouble();
  if (v < 0) return '-${formatCount(-v)}';
  if (v < 1000) {
    return v < 10 && v != v.roundToDouble()
        ? v.toStringAsFixed(1)
        : v.floor().toString();
  }

  // Divide rather than deriving the tier from log10: log(1000)/ln10 comes back
  // as 2.9999999999999996, which would render 1000 as "1000" instead of "1K".
  int tier = 0;
  double scaled = v;
  while (scaled >= 1000 && tier < _suffixes.length - 1) {
    scaled /= 1000;
    tier++;
  }
  // 999_999 rounds to "1000K"; promote it to "1M" instead.
  if (scaled >= 999.5 && tier < _suffixes.length - 1) {
    scaled /= 1000;
    tier++;
  }

  final String text = scaled >= 100
      ? scaled.toStringAsFixed(0)
      : scaled >= 10
          ? scaled.toStringAsFixed(1)
          : scaled.toStringAsFixed(2);

  // Trim a trailing ".0" / ".00" so 5.00M reads as 5M.
  final String trimmed = text.contains('.')
      ? text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
      : text;

  return '$trimmed${_suffixes[tier]}';
}

/// mm:ss for short countdowns, h:mm:ss once it passes an hour.
String formatDuration(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final int h = d.inHours;
  final int m = d.inMinutes.remainder(60);
  final int s = d.inSeconds.remainder(60);
  final String mm = m.toString().padLeft(2, '0');
  final String ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}
