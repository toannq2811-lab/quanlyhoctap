import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:study_shared/vocab.dart';
import 'package:study_shared/theme.dart';
import '../admin_data.dart';
import '../widgets.dart';
import 'decks_page.dart' show confirm;

/// Từ vựng: built-in HSK lists (read-only) and lists imported from files.
class VocabPage extends StatefulWidget {
  const VocabPage({super.key, required this.data});

  final AdminData data;

  @override
  State<VocabPage> createState() => _VocabPageState();
}

class _VocabPageState extends State<VocabPage> {
  bool _busy = false;

  AdminData get data => widget.data;

  Future<void> _import() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv', 'tsv', 'txt', 'docx', 'pdf'],
    );
    if (files.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      final f = files.first;
      final dict = {
        for (final l in data.vocabLists.where((l) => l.builtIn))
          for (final w in l.words) w.hanzi: w.pinyin,
      };
      final words = parseVocabRows(
        readVocabRows(f.name, await f.xFile.readAsBytes()),
        dict,
      );
      if (words.isEmpty) {
        throw Exception('Không tìm thấy chữ Hán nào trong file');
      }
      if (!mounted) return;
      final c = TextEditingController(
        text: f.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
      );
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Tìm thấy ${words.length} từ'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: c,
                  decoration: const InputDecoration(labelText: 'Tên danh sách'),
                ),
                const SizedBox(height: 10),
                for (final w in words.take(8))
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          w.hanzi,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(
                          w.pinyin,
                          style: const TextStyle(color: AppColors.pink),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          w.meaning,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Lưu'),
            ),
          ],
        ),
      );
      if (name == null || name.isEmpty) return;
      await data.addVocabList(name, words);
      if (mounted) showDone(context, 'Đã thêm "$name" · ${words.length} từ');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = data.students;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AdminHeader(
          title: 'Từ vựng tiếng Trung',
          subtitle: '${data.vocabLists.length} danh sách',
          actions: [
            GradientButton(
              label: _busy ? 'Đang đọc file...' : 'Thêm từ file Excel / TXT',
              icon: Icons.upload_file,
              expand: false,
              onPressed: _busy || !data.chineseReady ? null : _import,
            ),
          ],
        ),
        if (!data.chineseReady)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '⚠ Chạy migration 002_chinese_activity.sql để thêm danh sách từ.',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        for (final l in data.vocabLists) ...[
          SoftCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _WordsPage(data: data, listId: l.id),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: l.builtIn ? AppColors.gradient : null,
                    color: l.builtIn ? null : AppColors.blush,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l.id.startsWith('en-')
                        ? 'En'
                        : l.builtIn
                            ? l.name.replaceAll('HSK ', '')
                            : '自',
                    style: TextStyle(
                      color: l.builtIn ? Colors.white : AppColors.pink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${l.words.length} từ${l.builtIn ? ' · có sẵn' : ''}'
                        '${students.isEmpty ? '' : ' · ${students.map((s) => '${s.displayName} thuộc ${l.words.where((w) => s.words[w.id]?.known ?? false).length}').join(', ')}'}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!l.builtIn)
                  IconButton(
                    tooltip: 'Xóa danh sách',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.red,
                    ),
                    onPressed: () async {
                      if (!await confirm(context, 'Xóa danh sách "${l.name}"?')) {
                        return;
                      }
                      try {
                        await data.deleteVocabList(l);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                    },
                  ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _WordsPage extends StatefulWidget {
  const _WordsPage({required this.data, required this.listId});

  final AdminData data;
  final String listId;

  @override
  State<_WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<_WordsPage> {
  String _query = '';

  Future<void> _edit(VocabWord w) async {
    final p = TextEditingController(text: w.pinyin);
    final m = TextEditingController(text: w.meaning);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(w.hanzi, style: const TextStyle(fontSize: 30)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: p,
                decoration: const InputDecoration(labelText: 'Pinyin'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: m,
                decoration: const InputDecoration(labelText: 'Nghĩa'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.data.updateWord(
        w,
        pinyin: p.text.trim(),
        meaning: m.text.trim(),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.data,
      builder: (context, _) {
        final list = widget.data.vocabLists
            .where((l) => l.id == widget.listId)
            .firstOrNull;
        if (list == null) {
          return const Scaffold(
            body: Center(child: Text('Danh sách đã bị xóa')),
          );
        }
        final q = _query.toLowerCase();
        final words = list.words
            .where(
              (w) =>
                  q.isEmpty ||
                  w.hanzi.contains(q) ||
                  w.pinyin.toLowerCase().contains(q) ||
                  w.meaning.toLowerCase().contains(q),
            )
            .toList();
        final students = widget.data.students;
        return Scaffold(
          appBar: AppBar(title: Text(list.name)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Tìm chữ Hán, pinyin, nghĩa...',
                      prefixIcon: Icon(Icons.search, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Column(
                      children: [
                        for (final w in words)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    w.hanzi,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    w.pinyin,
                                    style: const TextStyle(
                                      color: AppColors.pink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(child: Text(w.meaning)),
                                for (final s in students)
                                  Tooltip(
                                    message: s.displayName,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Icon(
                                        (s.words[w.id]?.known ?? false)
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 18,
                                        color: (s.words[w.id]?.known ?? false)
                                            ? AppColors.green
                                            : AppColors.border,
                                      ),
                                    ),
                                  ),
                                if (!list.builtIn)
                                  IconButton(
                                    tooltip: 'Sửa',
                                    onPressed: () => _edit(w),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
