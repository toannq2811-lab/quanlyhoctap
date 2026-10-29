import 'package:flutter/material.dart';
import 'package:study_shared/english.dart';
import 'package:study_shared/theme.dart';
import 'package:study_shared/vocab.dart';

import '../../chinese/chinese_store.dart';
import '../chinese/chinese_tab.dart' show studyOrder;
import '../chinese/flashcard_page.dart';
import '../chinese/vocab_list_page.dart';
import 'tense_page.dart';

/// The first topic that still has unknown words.
VocabList? nextEnglishTopic(ChineseStore zh, EnglishCourse en) {
  if (en.topics.isEmpty) return null;
  return en.topics
      .map((t) => t.list)
      .firstWhere((l) => zh.knownIn(l) < l.words.length, orElse: () => en.topics.first.list);
}

/// Tiếng Anh cho người mất gốc: 12 thì + từ vựng theo chủ đề.
class EnglishTab extends StatelessWidget {
  const EnglishTab({super.key, required this.zh, required this.en});

  final ChineseStore zh;
  final EnglishCourse en;

  @override
  Widget build(BuildContext context) {
    final words = [for (final t in en.topics) ...t.list.words];
    final known = en.topics.fold(0, (s, t) => s + zh.knownIn(t.list));
    final exercisesDone = en.tenses.fold(0, (s, t) => s + tenseDone(zh, t));
    final next = nextEnglishTopic(zh, en);
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Tiếng Anh', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Text('ABC', style: brandTitle(24)),
            ],
          ),
          const Text('Học lại từ đầu, chậm mà chắc 🌱', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          SoftCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Từ đã thuộc', style: TextStyle(color: AppColors.muted)),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '$known',
                                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                            TextSpan(
                                text: ' / ${words.length}',
                                style: const TextStyle(fontSize: 16, color: AppColors.muted)),
                          ])),
                          Text('Ngữ pháp: đúng $exercisesDone/${en.allExercises.length} bài tập',
                              style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    PercentRing(
                        value: words.isEmpty ? 0 : known / words.length, size: 92, label: 'từ vựng'),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Flashcard',
                        icon: Icons.style_rounded,
                        onPressed: next == null
                            ? null
                            : () => openFlashcards(
                                context, zh, next.name, studyOrder(zh, next.words).take(20).toList()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: () =>
                            openTenseQuiz(context, zh, 'Ôn tổng hợp các thì', en.allExercises, count: 20),
                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                        label: const Text('Ôn các thì'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Ngữ pháp: 12 thì', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const Text('Học lần lượt từ trên xuống nhé — mỗi thì có bài học + 12 bài tập',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 12),
          for (final t in en.tenses) ...[
            _TenseTile(zh: zh, tense: t),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          const Text('Từ vựng theo chủ đề', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          for (final t in en.topics) ...[
            _TopicTile(zh: zh, topic: t),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _TenseTile extends StatelessWidget {
  const _TenseTile({required this.zh, required this.tense});

  final ChineseStore zh;
  final Tense tense;

  @override
  Widget build(BuildContext context) {
    final done = tenseDone(zh, tense);
    final total = tense.exercises.length;
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TensePage(zh: zh, tense: tense))),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: done == total ? AppColors.gradient : null,
              color: done == total ? null : AppColors.blush,
              borderRadius: BorderRadius.circular(12),
            ),
            child: done == total
                ? const Icon(Icons.check_rounded, color: Colors.white)
                : Text('${tense.order}',
                    style: const TextStyle(
                        color: AppColors.pink, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tense.vi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text('${tense.en} · đúng $done/$total',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 5,
                    color: AppColors.pink,
                    backgroundColor: AppColors.blush,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.zh, required this.topic});

  final ChineseStore zh;
  final EnglishTopic topic;

  @override
  Widget build(BuildContext context) {
    final l = topic.list;
    final known = zh.knownIn(l);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => VocabListPage(zh: zh, list: l))),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(12)),
            child: Text(topic.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text('${l.words.length} từ · đã thuộc $known',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: l.words.isEmpty ? 0 : known / l.words.length,
                    minHeight: 5,
                    color: AppColors.pink,
                    backgroundColor: AppColors.blush,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
