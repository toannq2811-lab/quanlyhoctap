import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:study_shared/doc_reader.dart';
import 'package:study_shared/models.dart';
import 'package:study_shared/parser.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';

const usageGuide = '''1. Thêm tài liệu PDF (hoặc Word / TXT) có câu hỏi và đáp án.
2. Mở bộ đề, chọn chương rồi bấm "Bắt đầu làm bài".
3. Chọn đáp án — app báo ngay đúng hay sai.
4. Vào tab Kết quả để ôn lại các câu làm sai.
5. Tab Tiếng Trung: flashcard, trắc nghiệm từ vựng, tập viết nét chữ và luyện phát âm bằng micro.

Định dạng tài liệu nên là:
Câu 1: Nội dung câu hỏi...
A. ...   B. ...   C. ...   D. ...

Đáp án ghi theo một trong các cách:
• Bảng "ĐÁP ÁN" cuối chương: 1 C  2 B  3 A ...
• Dòng "Đáp án: B" ngay dưới câu hỏi
• Dấu * trước lựa chọn đúng: *B. ...
• File Word: tô đậm / gạch chân / tô màu lựa chọn đúng''';

const _maxBytes = 20 * 1024 * 1024;

/// 4. Thêm tài liệu (PDF).
class AddDocumentPage extends StatefulWidget {
  const AddDocumentPage({super.key, required this.store});

  final Store store;

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  bool _busy = false;
  String? _error;

  Future<void> _pick() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );
    if (files.isEmpty || !mounted) return;
    final file = files.first;
    setState(() {
      _busy = true;
      _error = null;
    });

    ParseResult? result;
    try {
      final bytes = await file.xFile.readAsBytes();
      if (bytes.length > _maxBytes) throw const FormatException('File lớn hơn 20MB');
      // Let the spinner paint before the synchronous parsing work.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final text = extractDocumentText(file.name, bytes);
      result = parseQuizText(text, idPrefix: 'd${DateTime.now().millisecondsSinceEpoch}');
      if (result.questionCount == 0) {
        throw const FormatException(
            'Không tìm thấy câu hỏi nào. Nếu PDF là ảnh scan thì không đọc được chữ — '
            'xem phần hướng dẫn bên dưới nhé.');
      }
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e is FormatException ? e.message : '$e';
      });
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);

    final name = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
    final deck = await showDialog<Deck>(
      context: context,
      builder: (_) => _ImportPreview(result: result!, defaultName: name),
    );
    if (deck == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.store.addDeck(deck);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = 'Không lưu được lên máy chủ, kiểm tra mạng rồi thử lại nhé';
      });
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.pink,
      content: Text('Đã thêm "${deck.name}" · ${deck.allQuestions.length} câu 💕'),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm tài liệu')),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomPaint(
              painter: _DashedBorder(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_outlined, color: AppColors.pink, size: 28),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('PDF',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Chọn file PDF từ thiết bị',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('Hỗ trợ PDF, Word, TXT (tối đa 20MB)',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    const SizedBox(height: 20),
                    if (_busy)
                      const Column(children: [
                        CircularProgressIndicator(color: AppColors.pink),
                        SizedBox(height: 10),
                        Text('Đang đọc tài liệu...', style: TextStyle(color: AppColors.muted)),
                      ])
                    else
                      SizedBox(
                        width: 200,
                        child: GradientButton(label: 'Chọn file', onPressed: _pick),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.red)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Hướng dẫn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            for (final (i, step) in const [
              'Chuẩn bị file PDF có câu hỏi và đáp án.',
              'Đảm bảo định dạng rõ ràng, dễ đọc (Câu 1: ... A. B. C. D.).',
              'Sau khi tải lên, hệ thống sẽ tự động trích xuất câu hỏi và đáp án.',
              'Đáp án có thể là bảng "ĐÁP ÁN" cuối chương, dòng "Đáp án: B", '
                  'hoặc dấu * trước lựa chọn đúng.',
            ].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ',
                        style: const TextStyle(
                            color: AppColors.pink, fontWeight: FontWeight.w900)),
                    Expanded(
                        child: Text(step,
                            style: const TextStyle(color: AppColors.muted, height: 1.4))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20));
    canvas.drawRRect(rrect, Paint()..color = Colors.white.withValues(alpha: 0.7));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = AppColors.pinkLight;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => false;
}

/// Shows what was found and lets the user name the deck and pick chapters.
class _ImportPreview extends StatefulWidget {
  const _ImportPreview({required this.result, required this.defaultName});

  final ParseResult result;
  final String defaultName;

  @override
  State<_ImportPreview> createState() => _ImportPreviewState();
}

class _ImportPreviewState extends State<_ImportPreview> {
  late final _name = TextEditingController(text: widget.defaultName);
  late final _selected = List.filled(widget.result.sections.length, true);

  @override
  Widget build(BuildContext context) {
    final sections = widget.result.sections;
    final missing = widget.result.missingAnswers;
    return AlertDialog(
      title: Text('Tìm thấy ${widget.result.questionCount} câu hỏi 🎉'),
      content: SizedBox(
        width: 460,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên bộ đề'),
            ),
            if (missing > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('⚠ $missing câu không tìm thấy đáp án — khi làm sẽ không chấm được.',
                    style: const TextStyle(color: AppColors.red)),
              ),
            const SizedBox(height: 12),
            const Text('Chọn phần muốn ôn:', style: TextStyle(fontWeight: FontWeight.w700)),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        GradientButton(
          label: 'Lưu',
          expand: false,
          onPressed: !_selected.contains(true)
              ? null
              : () => Navigator.pop(
                    context,
                    Deck(
                      id: 'd${DateTime.now().millisecondsSinceEpoch}',
                      name: _name.text.trim().isEmpty ? widget.defaultName : _name.text.trim(),
                      sections: [
                        for (final (i, s) in sections.indexed)
                          if (_selected[i]) s,
                      ],
                    ),
                  ),
        ),
      ],
    );
  }
}
