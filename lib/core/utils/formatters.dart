/// Shared formatting helpers used across the pinboard feature.
library;

/// Formats a raw count into a compact display string.
/// 890 -> '890', 1400 -> '1.4K', 12400 -> '12.4K', 2100000 -> '2.1M'
String formatCount(int count) {
  if (count >= 1000000) {
    final value = count / 1000000;
    return '${_trim(value)}M';
  }
  if (count >= 1000) {
    final value = count / 1000;
    return '${_trim(value)}K';
  }
  return '$count';
}

String _trim(double value) {
  final text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

/// Converts a timestamp into the terminal style relative label used in the UI.
/// Examples: 'JUST NOW', '2M AGO', '1H AGO', '3D AGO', '2W AGO'.
String timeAgo(DateTime? date) {
  if (date == null) return 'JUST NOW';
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return 'JUST NOW';
  if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
  if (diff.inHours < 24) return '${diff.inHours}H AGO';
  if (diff.inDays < 7) return '${diff.inDays}D AGO';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}W AGO';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}MO AGO';
  return '${(diff.inDays / 365).floor()}Y AGO';
}
