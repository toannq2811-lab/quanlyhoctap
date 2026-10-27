import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../chinese/chinese_store.dart';
import 'package:study_shared/vocab.dart';
import 'package:study_shared/theme.dart';

/// Thêm từ vựng từ file (Excel / CSV / TXT / Word / PDF).
class ImportVocabPage extends StatefulWidget {
  const ImportVocabPage({super.key, required this.zh});

  final ChineseStore zh;

  @override
  State<ImportVocabPage> createState() => _ImportVocabPageState();
}

class _ImportVocabPageState extends State<ImportVocabPage> {
  bool _busy = false;
  String? _error;

  Future<void> _pick() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv', 'tsv', 'txt', 'docx', 'pdf'],
    );
    if (files.isEmpty || !mounted) return;
    final file = files.first;
    setState(() {
      _busy = true;
      _error = null;
    });
    List<ParsedWord> words;
    try {
      final bytes = await file.xFile.readAsBytes();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      words = parseVocabRows(readVocabRows(file.name, bytes), widget.zh.dictionary);
      if (words.isEmpty) {
        throw const FormatException('Không tìm thấy chữ Hán nào trong file. Xem mẫu bên dưới nhé.');
      }
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e is FormatException ? e.message : 'Không đọc được file: $e';
      });
      return;
    }
    setState(() => _busy = false);
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _Preview(
        words: words,
        defaultName: file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
      ),
    );
    if (name == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.zh.addList(name, words);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = 'Không lưu được lên máy chủ, kiểm tra mạng rồi thử lại nhé.';
      });
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.pink,
      content: Text('Đã thêm "$name" · ${words.length} từ 💕'),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm từ vựng')),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SoftCard(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                children: [
                  Text('汉字', style: brandTitle(40)),
                  const SizedBox(height: 10),
                  const Text('Chọn file danh sách từ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Excel, CSV, TXT, Word hoặc PDF',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 18),
                  if (_busy)
                    const CircularProgressIndicator(color: AppColors.pink)
                  else
                    SizedBox(width: 200, child: GradientButton(label: 'Chọn file', onPressed: _pick)),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.red)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('File nên có dạng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            SoftCard(
              color: AppColors.blush.withValues(alpha: 0.5),
              child: const Text(
                'Excel: cột A chữ Hán · cột B pinyin · cột C nghĩa\n\n'
                'Hoặc mỗi dòng một từ:\n'
                '你好 | nǐ hǎo | xin chào\n'
                '谢谢 (xièxie): cảm ơn\n'
                '朋友 - bạn bè\n\n'
                'Thiếu pinyin cũng được: từ nào có trong HSK sẽ tự điền.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatefulWidget {
  const _Preview({required this.words, required this.defaultName});

  final List<ParsedWord> words;
  final String defaultName;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  late final _name = TextEditingController(text: widget.defaultName);

  @override
  Widget build(BuildContext context) {
    final noPinyin = widget.words.where((w) => w.pinyin.isEmpty).length;
    return AlertDialog(
      title: Text('Tìm thấy ${widget.words.length} từ 🎉'),
      content: SizedBox(
        width: 460,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Tên danh sách')),
            if (noPinyin > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('$noPinyin từ chưa có pinyin.',
                    style: const TextStyle(color: AppColors.muted)),
              ),
            const SizedBox(height: 10),
            for (final w in widget.words.take(12))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 70, child: Text(w.hanzi, style: const TextStyle(fontSize: 18))),
                    SizedBox(
                        width: 90,
                        child: Text(w.pinyin,
                            style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w700))),
                    Expanded(child: Text(w.meaning, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            if (widget.words.length > 12)
              Text('… và ${widget.words.length - 12} từ nữa',
                  style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        GradientButton(
          label: 'Lưu',
          expand: false,
          onPressed: () => Navigator.pop(
              context, _name.text.trim().isEmpty ? widget.defaultName : _name.text.trim()),
        ),
      ],
    );
  }
}
