enum PronunciationResult { correct, homophone, wrong }

const _toneless = {
  'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
  'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
  'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
  'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
  'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
  'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v', 'ü': 'v',
};

String _stripTones(String pinyin) =>
    pinyin.toLowerCase().split('').map((c) => _toneless[c] ?? c).join().replaceAll(RegExp(r'[^a-z]'), '');

/// Only the Chinese characters of a recognizer transcript.
String chineseOnly(String text) =>
    RegExp(r'[㐀-鿿豈-﫿]').allMatches(text).map((m) => m.group(0)).join();

/// Judges what the speech recognizer heard against the expected word.
///
/// [charPinyin] maps single characters to pinyin; it lets "他" count as a
/// homophone of "她" (both "ta"), since the recognizer can't tell them apart.
PronunciationResult judgePronunciation(
    String target, List<String> heard, Map<String, String> charPinyin) {
  final want = chineseOnly(target);
  final guesses = [for (final h in heard) chineseOnly(h)]..removeWhere((g) => g.isEmpty);
  if (want.isEmpty || guesses.isEmpty) return PronunciationResult.wrong;
  if (guesses.any((g) => g == want || g.contains(want))) return PronunciationResult.correct;

  String? sound(String chars) {
    final parts = <String>[];
    for (final c in chars.split('')) {
      final p = charPinyin[c];
      if (p == null) return null;
      parts.add(_stripTones(p));
    }
    return parts.join();
  }

  final wantSound = sound(want);
  if (wantSound != null && guesses.any((g) => sound(g) == wantSound)) {
    return PronunciationResult.homophone;
  }
  return PronunciationResult.wrong;
}
