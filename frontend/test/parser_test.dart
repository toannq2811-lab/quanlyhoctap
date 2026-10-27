import 'dart:io';

import 'package:study_shared/doc_reader.dart';
import 'package:study_shared/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the bundled Pháp luật đại cương PDF', () {
    final text = extractDocumentText('a.pdf',
        File('assets/phap_luat_dai_cuong.pdf').readAsBytesSync());
    final r = parseQuizText(text);
    for (final s in r.sections) {
      final missing = s.questions.where((q) => q.answer == null).length;
      final bad = s.questions.where((q) => q.options.length != 4).map((q) => q.number);
      // ignore: avoid_print
      final nums = s.questions.map((q) => q.number).toList();
      final gaps = [for (var i = 1; i < nums.length; i++) if (nums[i] != nums[i - 1] + 1) '${nums[i - 1]}->${nums[i]}'];
      print('${s.title}: ${s.questions.length} câu, thiếu đáp án $missing, số lựa chọn khác 4: $bad, gaps $gaps');
    }
    final chapters = r.sections.where((s) => s.title.startsWith('Chương')).toList();
    expect(chapters.length, 6);
    expect(chapters.map((s) => s.questions.length), [50, 40, 50, 60, 50, 50]);
    for (final s in chapters) {
      for (final q in s.questions) {
        for (final t in [q.text, ...q.options]) {
          expect(t, isNot(contains('Trắc nghiệm Pháp luật')));
          expect(t.trim(), isNotEmpty);
        }
      }
      expect(s.questions.every((q) => q.answer != null && q.options.length == 4), isTrue);
    }
    final q2 = chapters[0].questions[1];
    expect(q2.text, startsWith('Học thuyết nào'));
    expect(q2.options, ['Thuyết thần học.', 'Thuyết gia trưởng.', 'Thuyết khế ước xã hội.', 'Thuyết bạo lực.']);
    expect(q2.answer, 2);
    expect(chapters[0].questions.last.answer, 3);
    final ch2q32 = chapters[1].questions[31];
    expect(ch2q32.options.take(2), ['2', '3']);
    expect(chapters[3].questions.last.answer, 2); // ch4 câu 60: C
    expect(chapters[5].questions.last.answer, 0); // ch6 câu 50: A
    final situations = r.sections.last;
    expect(situations.questions.first.explanation, startsWith('Tình huống mua bán'));
  });

  test('inline answers, stars and numbered questions', () {
    final r = parseQuizText('''
1. Thủ đô Việt Nam?
A. Huế  B. Hà Nội
C. Đà Nẵng  D. Sài Gòn
Đáp án: B
2. 2+2=?
a) 3
*b) 4
c) 5
''');
    expect(r.questionCount, 2);
    final qs = r.sections.single.questions;
    expect(qs[0].options, ['Huế', 'Hà Nội', 'Đà Nẵng', 'Sài Gòn']);
    expect(qs[0].answer, 1);
    expect(qs[1].answer, 1);
  });
}
