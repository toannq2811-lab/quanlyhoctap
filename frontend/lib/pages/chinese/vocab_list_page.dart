import 'package:flutter/material.dart';

import '../../chinese/chinese_store.dart';
import 'package:study_shared/vocab.dart';
import '../../chinese/zh_bridge.dart';
import 'package:study_shared/theme.dart';
import 'chinese_tab.dart';
import 'flashcard_page.dart';
import 'pronounce_page.dart';
import 'vocab_quiz_page.dart';
import 'writing_page.dart';

/// One vocabulary list: study modes, search and the word list.
class VocabListPage extends StatefulWidget {
  const VocabListPage({super.key, required this.zh, required this.list});

  final ChineseStore zh;
  final VocabList list;

  @override
  State<VocabListPage> createState() => _VocabListPageState();
}

class _VocabListPageState extends State<VocabListPage> {
  String _query = '';
  bool _onlyUnknown = false;

  ChineseStore get zh => widget.zh;
  VocabList get list => widget.list;

  List<VocabWord> get _words {
    final q = _query.trim().toLowerCase();
    return list.words.where((w) {
      if (_onlyUnknown && zh.of(w).known) return false;
      if (q.isEmpty) return true;
      return w.hanzi.contains(q) ||
          w.pinyin.toLowerCase().contains(q) ||
          w.meaning.toLowerCase().contains(q);
    }).toList();
  }

  bool get _canDelete {
    final me = zh.store.userId;
    return !list.builtIn && (list.createdBy == me || zh.store.profile.isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: zh,
      builder: (context, _) {
        final words = _words;
        final known = zh.knownIn(list);
        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(list.name),
                Text('${list.words.length} từ · đã thuộc $known',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
              ],
            ),
            actions: [
              if (_canDelete)
                IconButton(
                  tooltip: 'Xóa danh sách',
                  icon: const Icon(Icons.delete_outline, color: AppColors.pink),
                  onPressed: _delete,
                ),
            ],
          ),
          body: PageBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Row(
                  children: [
                    _Mode(
                      icon: Icons.style_rounded,
                      label: 'Flashcard',
                      onTap: () => openFlashcards(
                          context, zh, list.name, studyOrder(zh, words).take(30).toList()),
                    ),
                    const SizedBox(width: 10),
                    _Mode(
                      icon: Icons.quiz_rounded,
                      label: 'Trắc nghiệm',
                      onTap: () => startVocabQuiz(context, zh, list.name, words),
                    ),
                    const SizedBox(width: 10),
                    _Mode(
                      icon: Icons.draw_rounded,
                      label: 'Tập viết',
                      onTap: () => openWriting(context, zh, studyOrder(zh, words)),
                    ),
                    const SizedBox(width: 10),
                    _Mode(
                      icon: Icons.mic_rounded,
                      label: 'Phát âm',
                      onTap: () => openPronounce(context, zh, studyOrder(zh, words).take(20).toList()),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Tìm chữ Hán, pinyin hoặc nghĩa...',
                    prefixIcon: Icon(Icons.search, color: AppColors.muted),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Switch(
                      value: _onlyUnknown,
                      activeTrackColor: AppColors.pink,
                      onChanged: (v) => setState(() => _onlyUnknown = v),
                    ),
                    const Text('Chỉ hiện từ chưa thuộc',
                        style: TextStyle(color: AppColors.muted)),
                    const Spacer(),
                    Text('${words.length} từ', style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 6),
                for (final w in words) ...[
                  _WordTile(zh: zh, word: w),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('Xóa danh sách "${list.name}" cho mọi người?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await zh.removeList(list);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }
}

class _Mode extends StatelessWidget {
  const _Mode({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(gradient: AppColors.gradient, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        ),
      );
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.zh, required this.word});

  final ChineseStore zh;
  final VocabWord word;

  @override
  Widget build(BuildContext context) {
    final known = zh.of(word).known;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      onTap: () => showWordSheet(context, zh, word),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64),
            child: Text(word.hanzi,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word.pinyin,
                    style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w700)),
                Text(word.meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          if (known) const Icon(Icons.check_circle, color: AppColors.green, size: 20),
          IconButton(
            tooltip: 'Nghe',
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.pink),
            onPressed: () => speakChinese(word.hanzi),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with a big stroke-order pad and the word's details.
void showWordSheet(BuildContext context, ChineseStore zh, VocabWord word) {
  final pad = HanziPadController();
  final chars = word.hanzi.characters.toList();
  var current = 0;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => ListenableBuilder(
        listenable: zh,
        builder: (ctx, _) {
          final known = zh.of(word).known;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(word.hanzi,
                          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.pink),
                        onPressed: () => speakChinese(word.hanzi),
                      ),
                      IconButton(
                        tooltip: 'Luyện phát âm',
                        icon: const Icon(Icons.mic_rounded, color: AppColors.pink),
                        onPressed: () {
                          Navigator.pop(ctx);
                          openPronounce(context, zh, [word]);
                        },
                      ),
                    ],
                  ),
                  Text(word.pinyin,
                      style: const TextStyle(
                          color: AppColors.pink, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(word.meaning, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 14),
                  if (chars.length > 1)
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final (i, c) in chars.indexed)
                          ChoiceChip(
                            label: Text(c, style: const TextStyle(fontSize: 18)),
                            selected: i == current,
                            showCheckmark: false,
                            selectedColor: AppColors.blush,
                            onSelected: (_) => setSheet(() => current = i),
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  HanziPad(char: chars[current], size: 200, controller: pad),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pad.animate,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Xem cách viết'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GradientButton(
                          label: 'Tập viết',
                          icon: Icons.draw_rounded,
                          onPressed: () {
                            Navigator.pop(ctx);
                            openWriting(context, zh, [word]);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => zh.setKnown(word, !known),
                    icon: Icon(known ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: known ? AppColors.green : AppColors.muted),
                    label: Text(known ? 'Đã thuộc' : 'Đánh dấu đã thuộc',
                        style: TextStyle(color: known ? AppColors.green : AppColors.muted)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
