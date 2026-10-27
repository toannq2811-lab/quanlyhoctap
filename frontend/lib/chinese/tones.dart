import 'dart:math';

/// Tone numbers (1–4, 5 = neutral) of each syllable in [pinyin], in order.
/// Unmarked syllables are only found when syllables are separated by spaces.
List<int> pinyinTones(String pinyin) {
  const marks = {
    'āēīōūǖ': 1,
    'áéíóúǘ': 2,
    'ǎěǐǒǔǚ': 3,
    'àèìòùǜ': 4,
  };
  int toneOf(String syllable) {
    for (final ch in syllable.split('')) {
      for (final e in marks.entries) {
        if (e.key.contains(ch)) return e.value;
      }
    }
    return 5;
  }

  final parts = pinyin.trim().split(RegExp(r"[\s'’\-]+")).where((p) => p.isNotEmpty).toList();
  if (parts.length > 1) return [for (final p in parts) toneOf(p)];
  // "bàba", "xièxie": one mark per syllable, unmarked trailing syllable = neutral.
  final tones = <int>[];
  for (final ch in pinyin.split('')) {
    for (final e in marks.entries) {
      if (e.key.contains(ch)) tones.add(e.value);
    }
  }
  return tones.isEmpty ? [5] : tones;
}

const toneNames = {
  1: 'thanh 1 (ngang, cao)',
  2: 'thanh 2 (đi lên)',
  3: 'thanh 3 (xuống thấp rồi lên)',
  4: 'thanh 4 (đi xuống mạnh)',
  5: 'thanh nhẹ',
};

const toneTips = {
  1: 'Giữ giọng cao và đều, như hát một nốt dài.',
  2: 'Bắt đầu vừa rồi kéo giọng lên, như khi hỏi "Hả?"',
  3: 'Hạ giọng xuống thật thấp rồi mới nhấc lên một chút.',
  4: 'Nói dứt khoát từ cao xuống thấp, như khi ra lệnh "Đi!"',
  5: 'Đọc nhẹ và ngắn.',
};

/// Pitch in semitones relative to the speaker's median, smoothed; empty if
/// there are too few voiced frames.
List<double> pitchContour(List<double> hz) {
  final voiced = [for (final f in hz) if (f > 0) f];
  if (voiced.length < 6) return [];
  final sorted = [...voiced]..sort();
  final median = sorted[sorted.length ~/ 2];
  var st = [for (final f in voiced) 12 * log(f / median) / ln2];
  // Drop octave errors.
  st = [for (final v in st) if (v.abs() < 9) v];
  if (st.length < 6) return [];
  // 5-point median smoothing.
  final out = <double>[];
  for (var i = 0; i < st.length; i++) {
    final w = [for (var j = max(0, i - 2); j <= min(st.length - 1, i + 2); j++) st[j]]..sort();
    out.add(w[w.length ~/ 2]);
  }
  return out;
}

/// Guesses the tone (1–4) of a single syllable from its pitch track, or null.
int? classifyTone(List<double> hz) {
  final c = pitchContour(hz);
  if (c.length < 6) return null;
  final cut = (c.length * 0.1).floor();
  final core = c.sublist(cut, c.length - cut);
  final n = core.length;
  final part = max(1, (n * 0.2).round());
  double mean(Iterable<double> xs) => xs.reduce((a, b) => a + b) / xs.length;
  final start = mean(core.take(part));
  final end = mean(core.skip(n - part));
  var minV = core.first, minI = 0, maxV = core.first;
  for (var i = 0; i < n; i++) {
    if (core[i] < minV) {
      minV = core[i];
      minI = i;
    }
    maxV = max(maxV, core[i]);
  }
  final range = maxV - minV;
  final minPos = minI / max(1, n - 1);
  if (range < 1.8) return 1;
  if (minPos > 0.2 && minPos < 0.8 && start - minV > 1.2 && end - minV > 1.2) return 3;
  if (end - start > 1.5) return 2;
  if (start - end > 2.5) return 4;
  if (start - end > 0.8) return 3; // short low fall ("half third tone")
  return 1;
}
