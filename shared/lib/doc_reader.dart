import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

/// Extracts plain text from a .pdf, .docx or .txt file.
String extractDocumentText(String fileName, Uint8List bytes) {
  final ext = fileName.toLowerCase().split('.').last;
  switch (ext) {
    case 'pdf':
      final doc = PdfDocument(inputBytes: bytes);
      try {
        return PdfTextExtractor(doc).extractText(layoutText: true);
      } finally {
        doc.dispose();
      }
    case 'docx':
      return _docxText(bytes);
    case 'txt':
    case 'md':
      return utf8.decode(bytes, allowMalformed: true);
    default:
      throw FormatException('Chưa hỗ trợ định dạng .$ext (chỉ PDF, DOCX, TXT)');
  }
}

/// Reads paragraphs from a .docx. Options whose text is highlighted, red,
/// bold or underlined are prefixed with `*` so the parser can treat them as
/// the marked answer.
String _docxText(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final entry = archive.findFile('word/document.xml');
  if (entry == null) throw const FormatException('File DOCX không hợp lệ');
  final xml = XmlDocument.parse(utf8.decode(entry.content as List<int>));
  final optionStart = RegExp(r'(?:^|\s{2,}|(?<=[.;)])\s+)([A-F])\s*[.)]\s');

  final out = StringBuffer();
  for (final p in xml.findAllElements('w:p')) {
    final text = StringBuffer();
    final marked = <bool>[];
    for (final r in p.findAllElements('w:r')) {
      final rPr = r.getElement('w:rPr');
      final isMarked = rPr != null && _isMarkedRun(rPr);
      for (final node in r.children.whereType<XmlElement>()) {
        final s = switch (node.name.qualified) {
          'w:t' => node.innerText,
          'w:tab' => '    ',
          'w:br' => '\n',
          _ => '',
        };
        text.write(s);
        marked.addAll(List.filled(s.length, isMarked));
      }
    }
    var line = text.toString();
    // Insert '*' before options that are mostly marked, from the end backwards.
    final starts = optionStart.allMatches(line).toList();
    for (var i = starts.length - 1; i >= 0; i--) {
      final from = starts[i].start;
      final to = i + 1 < starts.length ? starts[i + 1].start : line.length;
      final letters = [
        for (var k = from; k < to; k++)
          if (line[k].trim().isNotEmpty) marked[k]
      ];
      if (letters.isNotEmpty &&
          letters.where((m) => m).length / letters.length > 0.6) {
        final at = starts[i].end - starts[i].group(0)!.trimLeft().length;
        line = '${line.substring(0, at)}*${line.substring(at)}';
      }
    }
    out.writeln(line);
  }
  return out.toString();
}

bool _isMarkedRun(XmlElement rPr) {
  if (rPr.getElement('w:highlight') != null) return true;
  final shd = rPr.getElement('w:shd')?.getAttribute('w:fill');
  if (shd != null && shd != 'auto' && shd.toUpperCase() != 'FFFFFF') return true;
  final u = rPr.getElement('w:u')?.getAttribute('w:val');
  if (u != null && u != 'none') return true;
  final b = rPr.getElement('w:b');
  if (b != null && b.getAttribute('w:val') != '0' && b.getAttribute('w:val') != 'false') {
    return true;
  }
  final color = rPr.getElement('w:color')?.getAttribute('w:val')?.toUpperCase();
  if (color != null && color.length == 6) {
    final r = int.tryParse(color.substring(0, 2), radix: 16) ?? 0;
    final g = int.tryParse(color.substring(2, 4), radix: 16) ?? 0;
    final bl = int.tryParse(color.substring(4, 6), radix: 16) ?? 0;
    if (r > 150 && g < 100 && bl < 100) return true; // red
  }
  return false;
}
