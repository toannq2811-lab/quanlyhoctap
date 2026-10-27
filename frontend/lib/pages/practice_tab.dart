import 'package:flutter/material.dart';

import 'package:study_shared/models.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'deck_page.dart';
import 'quiz_page.dart';

/// Luyện tập tab: quick ways to start practising each deck.
class PracticeTab extends StatelessWidget {
  const PracticeTab({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Center(
            child: Text('Luyện tập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          if (store.decks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Chưa có bộ đề nào.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
            ),
          for (final (i, deck) in store.decks.indexed) ..._deckActions(context, deck, i),
        ],
      ),
    );
  }

  List<Widget> _deckActions(BuildContext context, Deck deck, int index) {
    final all = deck.allQuestions;
    final wrong = all.where((q) => store.results[q.id] == false).toList();
    final fresh = all.where((q) => store.results[q.id] == null).toList();
    return [
      const SizedBox(height: 16),
      Text(deck.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      _Action(
        icon: Icons.shuffle_rounded,
        title: 'Thi thử ngẫu nhiên',
        subtitle: 'Trộn câu hỏi từ tất cả các chương',
        onTap: () => pickRandomQuiz(context, store, deck.name, all),
      ),
      _Action(
        icon: Icons.replay_rounded,
        title: 'Ôn câu làm sai',
        subtitle: '${wrong.length} câu',
        onTap: wrong.isEmpty
            ? null
            : () => startQuiz(context, store, 'Ôn câu sai', [...wrong]..shuffle()),
      ),
      _Action(
        icon: Icons.fiber_new_rounded,
        title: 'Câu chưa làm',
        subtitle: '${fresh.length} câu',
        onTap: fresh.isEmpty ? null : () => startQuiz(context, store, deck.name, fresh),
      ),
      _Action(
        icon: Icons.format_list_numbered_rounded,
        title: 'Làm theo chương',
        subtitle: '${deck.sections.length} chương · ${all.length} câu',
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => DeckPage(store: store, deck: deck, index: index))),
      ),
    ];
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: SoftCard(
          padding: const EdgeInsets.all(14),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppColors.blush, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.pink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(subtitle,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
