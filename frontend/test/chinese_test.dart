import 'dart:convert';
import 'dart:typed_data';

import 'package:dien_ham/chinese/pronunciation.dart';
import 'package:dien_ham/chinese/tones.dart';
import 'package:study_shared/vocab.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _bytes(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  const dict = {'你好': 'nǐ hǎo', '朋友': 'péngyou'};

  test('reads free-form lines, tables and CSV', () {
    final txt = readVocabRows('a.txt', _bytes('''
1. 你好 (nǐ hǎo): xin chào
谢谢 | xièxie | cảm ơn
朋友 - bạn bè
爱 yêu, thích
không có chữ Hán thì bỏ qua
'''));
    final words = parseVocabRows(txt, dict);
    expect(words.map((w) => w.hanzi), ['你好', '谢谢', '朋友', '爱']);
    expect(words[0].pinyin, 'nǐ hǎo');
    expect(words[0].meaning, 'xin chào');
    expect(words[1].pinyin, 'xièxie');
    expect(words[1].meaning, 'cảm ơn');
    expect(words[2].pinyin, 'péngyou', reason: 'filled from the dictionary');
    expect(words[2].meaning, 'bạn bè');
    expect(words[3].meaning, 'yêu, thích');

    final csv = parseVocabRows(
        readVocabRows('a.csv', _bytes('汉字,pinyin,nghĩa\n学生,xuésheng,"học sinh, sinh viên"\n')), dict);
    expect(csv.single.hanzi, '学生');
    expect(csv.single.meaning, 'học sinh, sinh viên');
  });

  test('judges pronunciation, accepting homophones', () {
    const chars = {'他': 'tā', '她': 'tā', '好': 'hǎo', '你': 'nǐ'};
    expect(judgePronunciation('她', ['她。'], chars), PronunciationResult.correct);
    expect(judgePronunciation('她', ['他'], chars), PronunciationResult.homophone);
    expect(judgePronunciation('你好', ['你好吗'], chars), PronunciationResult.correct);
    expect(judgePronunciation('你好', ['好'], chars), PronunciationResult.wrong);
    expect(judgePronunciation('你', [''], chars), PronunciationResult.wrong);
  });

  test('reads tones from pinyin', () {
    expect(pinyinTones('nǐ hǎo'), [3, 3]);
    expect(pinyinTones('bàba'), [4]);
    expect(pinyinTones('mā'), [1]);
    expect(pinyinTones('ma'), [5]);
    expect(pinyinTones('xièxie'), [4]);
  });

  test('classifies the four tones from a pitch track', () {
    expect(classifyTone(_glide([230, 232, 229, 231])), 1);
    expect(classifyTone(_glide([180, 200, 240, 280])), 2);
    expect(classifyTone(_glide([200, 160, 150, 185])), 3);
    expect(classifyTone(_glide([290, 250, 200, 160])), 4);
    expect(classifyTone([0, 0, 220, 0]), isNull);
  });
}

List<double> _glide(List<double> points, {int frames = 40}) {
  // Piecewise-linear pitch (Hz) through [points], with silent frames around it.
  final out = <double>[0, 0, 0];
  for (var i = 0; i < frames; i++) {
    final t = i / (frames - 1) * (points.length - 1);
    final k = t.floor().clamp(0, points.length - 2);
    final f = t - k;
    out.add(points[k] * (1 - f) + points[k + 1] * f);
  }
  return out..addAll([0, 0]);
}

