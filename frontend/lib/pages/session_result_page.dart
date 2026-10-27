import 'package:flutter/material.dart';

import 'package:study_shared/models.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'quiz_page.dart';
import 'result_widgets.dart';

/// 8. Kết quả ôn tập — shown when a quiz session ends.
class SessionResultPage extends StatefulWidget {
  const SessionResultPage({
    super.key,
    required this.store,
    required this.title,
    required this.questions,
    required this.chosen,
    required this.elapsed,
  });

  final Store store;
  final String title;
  final List<Question> questions;
  final Map<int, int> chosen;
  final Duration elapsed;

  @override
  State<SessionResultPage> createState() => _SessionResultPageState();
}

class _SessionResultPageState extends State<SessionResultPage> {
  @override
  void initState() {
    super.initState();
    if (widget.chosen.isEmpty) return;
    var right = 0, wrong = 0;
    for (final MapEntry(key: i, value: c) in widget.chosen.entries) {
      final answer = widget.questions[i].answer;
      if (answer == null) continue;
      answer == c ? right++ : wrong++;
    }
    widget.store.recordAttempt(widget.questions, right, wrong, widget.elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final qs = widget.questions;
    var right = 0;
    final wrong = <Question>[];
    for (final MapEntry(key: i, value: c) in widget.chosen.entries) {
      final answer = qs[i].answer;
      if (answer == null) continue;
      if (answer == c) {
        right++;
      } else {
        wrong.add(qs[i]);
      }
    }
    final graded = right + wrong.length;
    final percent = graded == 0 ? 0 : right * 100 / graded;
    final message = percent >= 90
        ? 'Quá giỏi luôn! 🏆💕'
        : percent >= 70
            ? 'Làm tốt lắm! 🥰'
            : percent >= 50
                ? 'Ổn rồi, ôn thêm chút nữa nha 💪'
                : 'Ôn lại câu sai rồi làm lại nhé 🌸';
    final skipped = qs.length - widget.chosen.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả ôn tập')),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Center(child: Text(message,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${widget.title} · ${formatDuration(widget.elapsed)}'
                '${skipped > 0 ? ' · bỏ qua $skipped câu' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            ResultSummary(total: qs.length, right: right, wrong: wrong.length),
            const SizedBox(height: 20),
            WrongList(store: widget.store, questions: wrong),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: PageBody(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => QuizPage(
                            store: widget.store, title: widget.title, questions: qs))),
                    child: const Text('Làm lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: wrong.isEmpty ? 'Về trang chủ' : 'Ôn câu sai',
                    onPressed: () {
                      if (wrong.isEmpty) {
                        Navigator.of(context).pop();
                        return;
                      }
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => QuizPage(
                              store: widget.store,
                              title: '${widget.title} · câu sai',
                              questions: wrong)));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
