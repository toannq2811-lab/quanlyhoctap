import 'models.dart';

/// Result of parsing a document's text into quiz sections.
class ParseResult {
  ParseResult(this.sections);

  final List<Section> sections;

  int get questionCount =>
      sections.fold(0, (sum, s) => sum + s.questions.length);

  int get missingAnswers => sections.fold(
      0, (sum, s) => sum + s.questions.where((q) => q.answer == null).length);
}

class _DraftQuestion {
  _DraftQuestion(this.number, this.text);

  final int number;
  String text;
  final List<String> options = [];
  final Set<int> starred = {};
  int? answer;
  String? explanation;

  void addExplanation(String line) {
    if (line.isEmpty) return;
    explanation = explanation == null ? line : '$explanation $line';
  }
}

class _DraftSection {
  _DraftSection(this.title);

  String title;
  final List<_DraftQuestion> questions = [];
}

final _questionRe = RegExp(
    r'^(?:câu|cau|question|q)\s*(\d+)\s*[:.)\-–]?\s*(.*)$',
    caseSensitive: false);
final _numberedRe = RegExp(r'^(\d+)\s*[.)]\s+(.+)$');
final _optionRe = RegExp(r'^(\*?)\s*([A-Fa-f])\s*[.)]\s*(.*)$');
final _inlineAnswerRe = RegExp(
    r'^(?:đáp án|dap an|đa|answer|ans)\s*(?:đúng)?\s*[:\-–]?\s*\(?([A-Fa-f])\)?(?![\p{L}\d])\s*[.:\-–]?\s*(.*)$',
    caseSensitive: false,
    unicode: true);
final _explanationRe = RegExp(r'^(?:giải thích|giai thich|explanation)\s*[:\-–]?\s*(.*)$',
    caseSensitive: false);
final _answerHeaderRe =
    RegExp(r'^(?:bảng\s+)?(?:đáp án|dap an|answer key|answers)\b', caseSensitive: false);
final _sectionRe = RegExp(
    r'^(?:chương|chuong|phần|phan|bài|bai|chapter|part)\s+([0-9IVXLC]+)\b',
    caseSensitive: false);
final _answerPairRe =
    RegExp(r'(\d+)\s*[.:\-–)]?\s*([A-Fa-f])(?![\p{L}\d])', unicode: true);
final _pageNumberRe = RegExp(r'^[\s\-–]*\d+[\s\-–]*$');
final _hasLowerRe = RegExp(r'\p{Ll}', unicode: true);
final _hasLetterRe = RegExp(r'\p{L}', unicode: true);
final _wordRe = RegExp(r'\p{L}{3,}', unicode: true);
// Words after which "B." is a reference ("Cả A và B.") rather than an option.
final _joinerRe = RegExp(r'(?:^|\s)(?:và|hoặc|với|lẫn|cả|and|or)$',
    caseSensitive: false, unicode: true);

/// Splits plain text of a quiz document into sections and questions.
///
/// Understands:
///  - `Câu 1: ...` / `1. ...` question starts
///  - `A. ...` options, including several options on one line
///  - answer tables after a `ĐÁP ÁN ...` heading (`1 C 11 B ...`, optionally
///    followed by an explanation)
///  - inline answers (`Đáp án: B`) and starred options (`*B. ...`)
ParseResult parseQuizText(String rawText, {String idPrefix = 'q'}) {
  final lines = rawText
      .replaceAll('\r', '\n')
      .replaceAll(' ', ' ')
      .replaceAll('\t', '    ')
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !_pageNumberRe.hasMatch(l))
      .toList();

  // Running headers/footers repeat on every page; drop them.
  final counts = <String, int>{};
  for (final l in lines) {
    counts[l] = (counts[l] ?? 0) + 1;
  }
  bool isBoilerplate(String l) =>
      counts[l]! >= 3 &&
      !_optionRe.hasMatch(l) &&
      !_questionRe.hasMatch(l) &&
      !_answerPairRe.hasMatch(l) &&
      !_answerHeaderRe.hasMatch(l);

  final sections = <_DraftSection>[];
  var pending = <_DraftSection>[]; // sections whose answer table hasn't come yet
  _DraftSection? section;
  _DraftQuestion? question;
  _DraftQuestion? lastAnswered;
  var inAnswers = false;

  _DraftSection currentSection() {
    if (section == null) {
      section = _DraftSection('Câu hỏi');
      sections.add(section!);
      pending.add(section!);
    }
    return section!;
  }

  void startSection(String title) {
    inAnswers = false;
    question = null;
    if (section != null && section!.questions.isEmpty) {
      section!.title = title;
      return;
    }
    section = _DraftSection(title);
    sections.add(section!);
    pending.add(section!);
  }

  void startQuestion(int number, String text) {
    if (inAnswers) {
      inAnswers = false;
      pending = [];
      if (section != null) pending.add(section!);
    }
    question = _DraftQuestion(number, text);
    currentSection().questions.add(question!);
  }

  void assignAnswer(int number, String letter, String rest) {
    final index = letter.toUpperCase().codeUnitAt(0) - 65;
    for (final s in pending) {
      for (final q in s.questions) {
        if (q.number == number && q.answer == null) {
          q.answer = index;
          q.addExplanation(rest);
          lastAnswered = q;
          return;
        }
      }
    }
    lastAnswered = null;
  }

  void addOptionText(String text, bool star) {
    final q = question!;
    // Split "A. foo. B. bar." into separate options.
    var remaining = text;
    var starNext = star;
    while (true) {
      final next = String.fromCharCode(65 + q.options.length + 1);
      final splitRe = RegExp(
          '\\s+(\\*?)\\s*[$next${next.toLowerCase()}][.)]\\s+(?=\\S)');
      final before = remaining;
      final m = splitRe.allMatches(remaining).where((m) {
        final head = before.substring(0, m.start).trimRight();
        return head.isNotEmpty && !_joinerRe.hasMatch(head);
      }).firstOrNull;
      if (m == null) break;
      if (starNext) q.starred.add(q.options.length);
      q.options.add(remaining.substring(0, m.start).trim());
      starNext = m.group(1) == '*';
      remaining = remaining.substring(m.end);
    }
    if (starNext) q.starred.add(q.options.length);
    q.options.add(remaining.trim());
  }

  void appendText(String line) {
    final q = question;
    if (q == null) return;
    if (q.explanation != null) {
      q.addExplanation(line);
    } else if (q.options.isEmpty) {
      q.text = q.text.isEmpty ? line : '${q.text} $line';
    } else {
      q.options[q.options.length - 1] = '${q.options.last} $line';
    }
  }

  for (final line in lines) {
    if (isBoilerplate(line)) continue;

    if (_answerHeaderRe.hasMatch(line) && !_inlineAnswerRe.hasMatch(line)) {
      inAnswers = true;
      question = null;
      lastAnswered = null;
      continue;
    }

    final qm = _questionRe.firstMatch(line);
    if (qm != null) {
      startQuestion(int.parse(qm.group(1)!), qm.group(2)!.trim());
      continue;
    }

    if (_sectionRe.hasMatch(line) ||
        (_isAllCapsHeading(line) && !_optionRe.hasMatch(line))) {
      startSection(line);
      continue;
    }

    if (inAnswers) {
      final pairs = _answerPairRe.allMatches(line).toList();
      if (pairs.isNotEmpty && pairs.first.start == 0) {
        final leftover = line.replaceAll(_answerPairRe, '').trim();
        if (pairs.length == 1) {
          final p = pairs.first;
          assignAnswer(int.parse(p.group(1)!), p.group(2)!,
              line.substring(p.end).trim());
        } else if (!_hasLetterRe.hasMatch(leftover)) {
          for (final p in pairs) {
            assignAnswer(int.parse(p.group(1)!), p.group(2)!, '');
          }
          lastAnswered = null;
        }
        continue;
      }
      if (lastAnswered != null && !line.toLowerCase().startsWith('câu')) {
        lastAnswered!.addExplanation(line);
      }
      continue;
    }

    final q = question;
    if (q != null) {
      final am = _inlineAnswerRe.firstMatch(line);
      if (am != null && q.options.length >= 2) {
        q.answer = am.group(1)!.toUpperCase().codeUnitAt(0) - 65;
        q.explanation = null;
        q.addExplanation(am.group(2)!.trim());
        q.explanation ??= '';
        continue;
      }
      final em = _explanationRe.firstMatch(line);
      if (em != null && q.options.isNotEmpty) {
        q.explanation = null;
        q.addExplanation(em.group(1)!.trim());
        q.explanation ??= '';
        continue;
      }
      final om = _optionRe.firstMatch(line);
      if (om != null &&
          q.explanation == null &&
          om.group(2)!.toUpperCase().codeUnitAt(0) - 65 == q.options.length) {
        addOptionText(om.group(3)!, om.group(1) == '*');
        continue;
      }
      final nm = _numberedRe.firstMatch(line);
      if (nm != null &&
          q.options.length >= 2 &&
          int.parse(nm.group(1)!) == q.number + 1) {
        startQuestion(q.number + 1, nm.group(2)!.trim());
        continue;
      }
      appendText(line);
    } else {
      final nm = _numberedRe.firstMatch(line);
      if (nm != null && int.parse(nm.group(1)!) == 1) {
        startQuestion(1, nm.group(2)!.trim());
      }
    }
  }

  final result = <Section>[];
  for (final (si, s) in sections.indexed) {
    final qs = <Question>[];
    for (final (qi, d) in s.questions.indexed) {
      if (d.options.length < 2) continue;
      var answer = d.answer;
      if (answer == null && d.starred.length == 1) answer = d.starred.first;
      if (answer != null && answer >= d.options.length) answer = null;
      final expl = d.explanation?.trim();
      qs.add(Question(
        id: '$idPrefix-$si-$qi',
        number: d.number,
        text: d.text,
        options: d.options,
        answer: answer,
        explanation: (expl == null || expl.isEmpty) ? null : expl,
      ));
    }
    if (qs.isNotEmpty) result.add(Section(title: _prettyTitle(s.title), questions: qs));
  }
  return ParseResult(result);
}

bool _isAllCapsHeading(String line) {
  if (line.length < 8 || line.length > 150) return false;
  if (!_hasLetterRe.hasMatch(line) || _hasLowerRe.hasMatch(line)) return false;
  return line.split(RegExp(r'\s+')).length >= 2 && _wordRe.hasMatch(line);
}

/// "CHƯƠNG 1: LÝ LUẬN CHUNG" -> "Chương 1: Lý luận chung"
String _prettyTitle(String title) {
  if (_hasLowerRe.hasMatch(title)) return title;
  final lower = title.toLowerCase();
  return lower.isEmpty ? lower : lower[0].toUpperCase() + lower.substring(1);
}
