import 'package:flutter/material.dart';

import 'package:study_shared/models.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'quiz_page.dart';

/// "Chương 1: lý luận chung..." -> "Chương 1"
String shortSectionName(String title) {
  final i = title.indexOf(':');
  return i > 0 && i < 20 ? title.substring(0, i) : title;
}

/// 5. Danh sách bộ đề — questions of one deck, filterable by chapter.
class DeckPage extends StatefulWidget {
  const DeckPage({super.key, required this.store, required this.deck, required this.index});

  final Store store;
  final Deck deck;
  final int index;

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  int? _section; // null = all chapters
  String _query = '';

  Store get store => widget.store;
  Deck get deck => widget.deck;

  List<Question> get _scope =>
      _section == null ? deck.allQuestions : deck.sections[_section!].questions;

  String get _scopeTitle => _section == null ? deck.name : deck.sections[_section!].title;

  List<Question> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _scope;
    return _scope
        .where((x) => x.text.toLowerCase().contains(q) || '${x.number}' == q)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(deck.name),
                Text('${deck.allQuestions.length} câu · ${store.attempts[deck.id] ?? 0} lần làm',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings_outlined, color: AppColors.pink),
                onSelected: _onMenu,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                  PopupMenuItem(value: 'reset', child: Text('Làm lại từ đầu')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa bộ đề')),
                ],
              ),
            ],
          ),
          body: PageBody(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                        color: AppColors.blush, borderRadius: BorderRadius.circular(10)),
                    labelColor: AppColors.pink,
                    unselectedLabelColor: AppColors.muted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                    tabs: const [Tab(text: 'Danh sách câu', height: 38), Tab(text: 'Thông tin', height: 38)],
                  ),
                ),
                Expanded(
                  child: TabBarView(children: [_questionList(), _info()]),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PageBody(
                child: GradientButton(label: 'Bắt đầu làm bài', onPressed: _chooseMode),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _questionList() {
    final qs = _filtered;
    return Column(
      children: [
        if (deck.sections.length > 1)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _chip('Tất cả', null),
                for (final (i, s) in deck.sections.indexed) _chip(shortSectionName(s.title), i),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm câu hỏi...',
              prefixIcon: Icon(Icons.search, color: AppColors.muted),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            itemCount: qs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final q = qs[i];
              final r = store.results[q.id];
              final color = r == null ? AppColors.pink : (r ? AppColors.green : AppColors.red);
              return SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                onTap: () => startQuiz(context, store, _scopeTitle, qs, startAt: i),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${q.number}',
                          style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(q.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, int? section) {
    final selected = _section == section;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _section = section),
        selectedColor: AppColors.pink,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? AppColors.pink : AppColors.border),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _info() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      children: [
        for (final s in deck.sections) ...[
          SoftCard(
            child: Builder(builder: (context) {
              final st = Stats(store, s.questions);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('${st.total} câu · đã làm ${st.done} · '
                      'đúng ${st.right} · sai ${st.wrong}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: st.total == 0 ? 0 : st.done / st.total,
                      minHeight: 6,
                      color: AppColors.pink,
                      backgroundColor: AppColors.blush,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _chooseMode() async {
    final qs = _scope;
    final fresh = qs.where((q) => store.results[q.id] == null).toList();
    final wrong = qs.where((q) => store.results[q.id] == false).toList();
    final mode = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_scopeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _modeTile(ctx, 'order', Icons.format_list_numbered, 'Làm theo thứ tự (${qs.length} câu)'),
            _modeTile(ctx, 'shuffle', Icons.shuffle, 'Trộn thứ tự câu hỏi'),
            _modeTile(ctx, 'random', Icons.casino_outlined, 'Thi thử: chọn số câu ngẫu nhiên'),
            _modeTile(ctx, 'new', Icons.fiber_new_outlined, 'Câu chưa làm (${fresh.length})',
                enabled: fresh.isNotEmpty),
            _modeTile(ctx, 'wrong', Icons.replay, 'Ôn lại câu làm sai (${wrong.length})',
                enabled: wrong.isNotEmpty),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (mode == null || !mounted) return;
    if (mode == 'random') {
      await pickRandomQuiz(context, store, _scopeTitle, qs);
      return;
    }
    final list = switch (mode) {
      'shuffle' => [...qs]..shuffle(),
      'new' => fresh,
      'wrong' => wrong,
      _ => qs,
    };
    startQuiz(context, store, _scopeTitle, list);
  }

  Widget _modeTile(BuildContext ctx, String value, IconData icon, String title,
          {bool enabled = true}) =>
      ListTile(
        enabled: enabled,
        leading: Icon(icon, color: AppColors.pink),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        onTap: () => Navigator.pop(ctx, value),
      );

  Future<void> _onMenu(String action) async {
    try {
      await _runMenu(action);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg.length < 120 ? msg : 'Không thực hiện được, kiểm tra mạng nhé'),
      ));
    }
  }

  Future<void> _runMenu(String action) async {
    switch (action) {
      case 'rename':
        final controller = TextEditingController(text: deck.name);
        final name = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Đổi tên'),
            content: TextField(controller: controller, autofocus: true),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  child: const Text('Lưu')),
            ],
          ),
        );
        if (name != null && name.isNotEmpty) await store.renameDeck(deck, name);
      case 'reset':
        if (await _confirm('Xóa kết quả đã làm của "${deck.name}"?')) {
          await store.resetProgress(deck.allQuestions);
        }
      case 'delete':
        if (await _confirm('Xóa bộ đề "${deck.name}"?')) {
          await store.removeDeck(deck);
          if (mounted) Navigator.of(context).pop();
        }
    }
  }

  Future<bool> _confirm(String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đồng ý')),
        ],
      ),
    );
    return ok ?? false;
  }
}
