import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:study_shared/doc_reader.dart';
import 'package:study_shared/models.dart';
import 'package:study_shared/parser.dart';
import 'package:study_shared/theme.dart';
import '../admin_data.dart';
import '../widgets.dart';

/// Bộ đề: shared quiz decks — add from a file, rename, delete, edit questions.
class DecksPage extends StatefulWidget {
  const DecksPage({super.key, required this.data});

  final AdminData data;

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  bool _busy = false;

  AdminData get data => widget.data;

  Future<void> _import() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );
    if (files.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      final f = files.first;
      final bytes = await f.xFile.readAsBytes();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final id = 'd${DateTime.now().millisecondsSinceEpoch}';
      final parsed = parseQuizText(
        extractDocumentText(f.name, bytes),
        idPrefix: id,
      );
      if (parsed.questionCount == 0) {
        throw Exception('Không tìm thấy câu hỏi nào trong file');
      }
      if (!mounted) return;
      final picked = await showDialog<Deck>(
        context: context,
        builder: (_) => _ImportDialog(
          id: id,
          result: parsed,
          defaultName: f.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        ),
      );
      if (picked == null) return;
      await data.addDeck(picked);
      if (mounted) {
        showDone(
          context,
          'Đã thêm "${picked.name}" · ${picked.allQuestions.length} câu',
        );
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rename(Deck d) async {
    final c = TextEditingController(text: d.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên bộ đề'),
        content: TextField(controller: c, autofocus: true),
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
    try {
      await data.renameDeck(d, name);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete(Deck d) async {
    final ok = await confirm(
      context,
      'Xóa bộ đề "${d.name}"? Toàn bộ câu hỏi và kết quả làm bài của mọi người với bộ đề này sẽ mất.',
    );
    if (!ok) return;
    try {
      await data.deleteDeck(d);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AdminHeader(
          title: 'Bộ đề',
          subtitle: '${data.decks.length} bộ · ${data.allQuestions.length} câu',
          actions: [
            GradientButton(
              label: _busy ? 'Đang đọc file...' : 'Thêm từ file PDF / Word',
              icon: Icons.upload_file,
              expand: false,
              onPressed: _busy ? null : _import,
            ),
          ],
        ),
        for (final d in data.decks) ...[
          SoftCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeckQuestionsPage(data: data, deckId: d.id),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gavel_rounded, color: AppColors.pink),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${d.sections.length} phần · ${d.allQuestions.length} câu · '
                        '${d.allQuestions.where((q) => q.answer == null).length} câu thiếu đáp án',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Đổi tên',
                  onPressed: () => _rename(d),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  onPressed: () => _delete(d),
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
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

Future<bool> confirm(BuildContext context, String message) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ??
    false;

class _ImportDialog extends StatefulWidget {
  const _ImportDialog({
    required this.id,
    required this.result,
    required this.defaultName,
  });

  final String id;
  final ParseResult result;
  final String defaultName;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  late final _name = TextEditingController(text: widget.defaultName);
  late final _selected = List.filled(widget.result.sections.length, true);

  @override
  Widget build(BuildContext context) {
    final sections = widget.result.sections;
    return AlertDialog(
      title: Text('Tìm thấy ${widget.result.questionCount} câu hỏi'),
      content: SizedBox(
        width: 520,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên bộ đề'),
            ),
            if (widget.result.missingAnswers > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '⚠ ${widget.result.missingAnswers} câu thiếu đáp án (sửa được sau khi lưu).',
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            const SizedBox(height: 8),
            for (final (i, s) in sections.indexed)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.pink,
                value: _selected[i],
                onChanged: (v) => setState(() => _selected[i] = v ?? false),
                title: Text(s.title),
                subtitle: Text('${s.questions.length} câu'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: !_selected.contains(true)
              ? null
              : () => Navigator.pop(
                  context,
                  Deck(
                    id: widget.id,
                    name: _name.text.trim().isEmpty
                        ? widget.defaultName
                        : _name.text.trim(),
                    sections: [
                      for (final (i, s) in sections.indexed)
                        if (_selected[i]) s,
                    ],
                  ),
                ),
          child: const Text('Lưu bộ đề'),
        ),
      ],
    );
  }
}

/// All questions of a deck with search, chapter filter and editing.
class DeckQuestionsPage extends StatefulWidget {
  const DeckQuestionsPage({
    super.key,
    required this.data,
    required this.deckId,
  });

  final AdminData data;
  final String deckId;

  @override
  State<DeckQuestionsPage> createState() => _DeckQuestionsPageState();
}

class _DeckQuestionsPageState extends State<DeckQuestionsPage> {
  int? _section;
  String _query = '';
  bool _onlyMissing = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.data,
      builder: (context, _) {
        final deck = widget.data.decks
            .where((d) => d.id == widget.deckId)
            .firstOrNull;
        if (deck == null) {
          return const Scaffold(body: Center(child: Text('Bộ đề đã bị xóa')));
        }
        final q = _query.toLowerCase();
        final sections = _section == null
            ? deck.sections
            : [deck.sections[_section!]];
        final rows = [
          for (final s in sections)
            for (final question in s.questions)
              if ((!_onlyMissing || question.answer == null) &&
                  (q.isEmpty ||
                      question.text.toLowerCase().contains(q) ||
                      question.options.any((o) => o.toLowerCase().contains(q))))
                (s, question),
        ];
        return Scaffold(
          appBar: AppBar(title: Text(deck.name)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: _section == null,
                        onSelected: (_) => setState(() => _section = null),
                      ),
                      for (final (i, s) in deck.sections.indexed)
                        ChoiceChip(
                          label: Text(
                            s.title.contains(':')
                                ? s.title.split(':').first
                                : s.title,
                          ),
                          selected: _section == i,
                          onSelected: (_) => setState(() => _section = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          decoration: const InputDecoration(
                            hintText: 'Tìm trong câu hỏi và đáp án...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilterChip(
                        label: const Text('Chỉ câu thiếu đáp án'),
                        selected: _onlyMissing,
                        onSelected: (v) => setState(() => _onlyMissing = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${rows.length} câu',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  for (final (s, question) in rows) ...[
                    _QuestionCard(data: widget.data, section: s, q: question),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.data,
    required this.section,
    required this.q,
  });

  final AdminData data;
  final Section section;
  final Question q;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Câu ${q.number}. ',
                        style: const TextStyle(
                          color: AppColors.pink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: q.text,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Sửa',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _EditQuestionDialog(data: data, q: q),
                ),
              ),
              IconButton(
                tooltip: 'Xóa câu',
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                onPressed: () async {
                  if (!await confirm(context, 'Xóa câu ${q.number}?')) return;
                  try {
                    await data.deleteQuestion(q);
                  } catch (e) {
                    if (context.mounted) showError(context, e);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final (i, o) in q.options.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    i == q.answer ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: i == q.answer ? AppColors.green : AppColors.border,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${String.fromCharCode(65 + i)}. $o',
                      style: TextStyle(
                        fontWeight: i == q.answer
                            ? FontWeight.w800
                            : FontWeight.w400,
                        color: i == q.answer ? AppColors.green : AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (q.answer == null)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                '⚠ Chưa có đáp án',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (q.explanation != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Giải thích: ${q.explanation}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditQuestionDialog extends StatefulWidget {
  const _EditQuestionDialog({required this.data, required this.q});

  final AdminData data;
  final Question q;

  @override
  State<_EditQuestionDialog> createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<_EditQuestionDialog> {
  late final _text = TextEditingController(text: widget.q.text);
  late final _options = [
    for (final o in widget.q.options) TextEditingController(text: o),
  ];
  late final _explanation = TextEditingController(
    text: widget.q.explanation ?? '',
  );
  late int? _answer = widget.q.answer;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final options = [for (final c in _options) c.text.trim()]
      ..removeWhere((o) => o.isEmpty);
    try {
      await widget.data.updateQuestion(
        widget.q,
        Question(
          id: widget.q.id,
          number: widget.q.number,
          text: _text.text.trim(),
          options: options,
          answer: _answer != null && _answer! < options.length ? _answer : null,
          explanation: _explanation.text.trim().isEmpty
              ? null
              : _explanation.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sửa câu ${widget.q.number}'),
      content: SizedBox(
        width: 620,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: _text,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Câu hỏi'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lựa chọn (chọn nút tròn ở đáp án đúng)',
              style: TextStyle(color: AppColors.muted),
            ),
            RadioGroup<int>(
              groupValue: _answer,
              onChanged: (v) => setState(() => _answer = v),
              child: Column(
                children: [
                  for (final (i, c) in _options.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Radio<int>(value: i, activeColor: AppColors.green),
                          Expanded(
                            child: TextField(
                              controller: c,
                              maxLines: null,
                              decoration: InputDecoration(
                                labelText: String.fromCharCode(65 + i),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _explanation,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Giải thích (không bắt buộc)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    );
  }
}
