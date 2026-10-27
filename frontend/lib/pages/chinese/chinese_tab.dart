import 'package:flutter/material.dart';

import '../../chinese/chinese_store.dart';
import 'package:study_shared/vocab.dart';
import 'package:study_shared/theme.dart';
import 'flashcard_page.dart';
import 'import_vocab_page.dart';
import 'vocab_list_page.dart';
import 'vocab_quiz_page.dart';

/// Words to study first: not yet known, then the rest.
List<VocabWord> studyOrder(ChineseStore zh, List<VocabWord> words) {
  final unknown = words.where((w) => !zh.of(w).known).toList()..shuffle();
  final known = words.where((w) => zh.of(w).known).toList()..shuffle();
  return [...unknown, ...known];
}

/// The list to continue with: the first one that still has unknown words.
VocabList? nextList(ChineseStore zh) => zh.lists.isEmpty
    ? null
    : zh.lists.firstWhere((l) => zh.knownIn(l) < l.words.length, orElse: () => zh.lists.first);

/// Tiếng Trung tab: vocabulary lists and the three ways to study them.
class ChineseTab extends StatelessWidget {
  const ChineseTab({super.key, required this.zh});

  final ChineseStore zh;

  @override
  Widget build(BuildContext context) {
    final total = zh.allWords.length;
    final known = zh.lists.fold(0, (s, l) => s + zh.knownIn(l));
    final current = nextList(zh);
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Tiếng Trung',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Text('中文', style: brandTitle(24)),
            ],
          ),
          const Text('Mỗi ngày vài từ, tích tiểu thành đại nha 🌸',
              style: TextStyle(color: AppColors.muted)),
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
                                text: ' / $total',
                                style: const TextStyle(fontSize: 16, color: AppColors.muted)),
                          ])),
                          if (current != null)
                            Text('Đang học: ${current.name}',
                                style: const TextStyle(
                                    color: AppColors.pink, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    PercentRing(value: total == 0 ? 0 : known / total, size: 92, label: 'đã thuộc'),
                  ],
                ),
                if (current != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'Flashcard',
                          icon: Icons.style_rounded,
                          onPressed: () => openFlashcards(context, zh, current.name,
                              studyOrder(zh, current.words).take(20).toList()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                          onPressed: () => startVocabQuiz(context, zh, current.name, current.words),
                          icon: const Icon(Icons.quiz_outlined, size: 18),
                          label: const Text('Trắc nghiệm'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!zh.serverReady)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                  'Tiến độ tiếng Trung tạm lưu trên máy này, sẽ đồng bộ khi máy chủ sẵn sàng.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
          const SizedBox(height: 24),
          const Text('Danh sách từ vựng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          for (final l in zh.lists) ...[
            _ListTile(zh: zh, list: l),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          GradientButton(
            label: 'Thêm từ vựng từ file',
            icon: Icons.add,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => ImportVocabPage(zh: zh))),
          ),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({required this.zh, required this.list});

  final ChineseStore zh;
  final VocabList list;

  @override
  Widget build(BuildContext context) {
    final known = zh.knownIn(list);
    final total = list.words.length;
    final badge = list.builtIn ? list.name.replaceAll('HSK ', '') : '自';
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => VocabListPage(zh: zh, list: list))),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: list.builtIn ? AppColors.gradient : null,
              color: list.builtIn ? null : AppColors.blush,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (list.builtIn)
                  const Text('HSK',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                Text(badge,
                    style: TextStyle(
                        color: list.builtIn ? Colors.white : AppColors.pink,
                        fontSize: list.builtIn ? 18 : 22,
                        height: 1.1,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(list.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('$total từ · đã thuộc $known',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : known / total,
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
