import 'package:flutter/material.dart';

import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'quiz_page.dart';
import 'result_widgets.dart';

/// Kết quả tab: overall accuracy and every question currently answered wrong.
class ResultsTab extends StatelessWidget {
  const ResultsTab({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final all = store.allQuestions;
    final stats = Stats(store, all);
    final wrong = all.where((q) => store.results[q.id] == false).toList();
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Center(
            child: Text('Kết quả ôn tập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 16),
          ResultSummary(total: stats.done, right: stats.right, wrong: stats.wrong),
          const SizedBox(height: 20),
          WrongList(store: store, questions: wrong),
          const SizedBox(height: 12),
          if (wrong.isNotEmpty)
            GradientButton(
              label: 'Ôn lại ${wrong.length} câu sai',
              icon: Icons.replay,
              onPressed: () => startQuiz(context, store, 'Ôn câu sai', [...wrong]..shuffle()),
            ),
        ],
      ),
    );
  }
}
