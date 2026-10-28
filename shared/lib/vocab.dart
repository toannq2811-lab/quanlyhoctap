import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import 'doc_reader.dart';

class VocabWord {
  const VocabWord({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
  });

  final String id;
  final String hanzi;
  final String pinyin;
  final String meaning;

  Map<String, dynamic> toJson() => {
    'id': id,
    'h': hanzi,
    'p': pinyin,
    'm': meaning,
  };

  factory VocabWord.fromJson(Map<String, dynamic> j) => VocabWord(
    id: j['id'] as String,
    hanzi: j['h'] as String,
    pinyin: j['p'] as String,
    meaning: j['m'] as String,
  );
}

class VocabList {
  VocabList({
    required this.id,
    required this.name,
    required this.words,
    this.builtIn = false,
    this.createdBy,
  });

  final String id;
  String name;
  final List<VocabWord> words;
  final bool builtIn;
  final String? createdBy;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'by': createdBy,
    'w': [for (final w in words) w.toJson()],
  };

  factory VocabList.fromJson(Map<String, dynamic> j) => VocabList(
    id: j['id'] as String,
    name: j['name'] as String,
    createdBy: j['by'] as String?,
    words: [
      for (final w in j['w'] as List)
        VocabWord.fromJson(w as Map<String, dynamic>),
    ],
  );
}

/// HSK lists bundled with the app (shared/assets/chinese/*.tsv).
Future<List<VocabList>> loadBuiltInLists() async {
  Future<VocabList> load(String id, String name) async {
    final tsv = await rootBundle.loadString('packages/study_shared/assets/chinese/$id.tsv');
    final words = <VocabWord>[];
    for (final line in const LineSplitter().convert(tsv)) {
      final f = line.split('\t');
      if (f.length < 3) continue;
      words.add(
        VocabWord(id: '$id-${f[0]}', hanzi: f[0], pinyin: f[1], meaning: f[2]),
      );
    }
    return VocabList(id: id, name: name, words: words, builtIn: true);
  }

  // HSK 5 first: it is the level being studied now; 1–2 stay for review.
  return [
    await load('hsk5', 'HSK 5'),
    await load('hsk1', 'HSK 1'),
    await load('hsk2', 'HSK 2'),
  ];
}

final _cjk = RegExp(r'[㐀-鿿豈-﫿]');
final _cjkRun = RegExp(r'[㐀-鿿豈-﫿]+');
// Tone marks that never appear in Vietnamese (macron / caron / ü), or tone numbers.
final _pinyinOnly = RegExp(
  r'[āēīōūǖǎěǐǒǔǚǘǜü]|[a-z][1-5]\b',
  caseSensitive: false,
);
final _latinPinyin = RegExp(r"^[a-zA-ZāáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜüÜ\s'’·\-0-9]+$");

const _headerWords = {
  'pinyin',
  'phiên âm',
  'nghĩa',
  'nghia',
  'meaning',
  'tiếng việt',
  'từ vựng',
};

/// One word found in an imported file (pinyin may still be empty).
class ParsedWord {
  ParsedWord(this.hanzi, this.pinyin, this.meaning);

  final String hanzi;
  String pinyin;
  final String meaning;
}

/// Reads an Excel/CSV/TXT/Word/PDF file into rows of fields.
List<List<String>> readVocabRows(String fileName, Uint8List bytes) {
  final ext = fileName.toLowerCase().split('.').last;
  if (ext == 'xlsx') return _xlsxRows(bytes);
  final text = ext == 'csv' || ext == 'tsv'
      ? utf8.decode(bytes, allowMalformed: true)
      : extractDocumentText(fileName, bytes);
  final rows = <List<String>>[];
  for (final line in const LineSplitter().convert(text)) {
    if (line.trim().isEmpty) continue;
    if (ext == 'csv') {
      rows.add(_csvFields(line));
    } else if (line.contains('\t') ||
        line.contains('|') ||
        line.contains(';')) {
      rows.add(line.split(RegExp(r'\t|\||;')));
    } else {
      rows.add(_freeLine(line));
    }
  }
  return rows;
}

/// Turns rows into words: finds the Chinese, pinyin and meaning columns.
/// Missing pinyin is filled from [dictionary] (hanzi → pinyin) when possible.
List<ParsedWord> parseVocabRows(
  List<List<String>> rows,
  Map<String, String> dictionary,
) {
  final words = <ParsedWord>[];
  final seen = <String>{};
  for (final raw in rows) {
    final fields = [for (final f in raw) f.trim()]
      ..removeWhere((f) => f.isEmpty);
    // Header rows such as "汉字 | pinyin | nghĩa".
    if (fields.any((f) => _headerWords.contains(f.toLowerCase()))) continue;
    final hi = fields.indexWhere((f) => _cjk.hasMatch(f));
    if (hi < 0) continue;
    final hanzi = _cjkRun.allMatches(fields[hi]).map((m) => m.group(0)).join();
    final rest = [
      for (final (i, f) in fields.indexed)
        if (i != hi && !RegExp(r'^\d+[.)]?$').hasMatch(f)) f,
    ];
    var pinyin = '';
    var meaning = '';
    if (rest.length >= 2 && _latinPinyin.hasMatch(rest[0])) {
      pinyin = rest[0];
      meaning = rest.sublist(1).join(', ');
    } else if (rest.length == 1 &&
        _pinyinOnly.hasMatch(rest[0]) &&
        _latinPinyin.hasMatch(rest[0])) {
      pinyin = rest[0];
    } else {
      meaning = rest.join(', ');
    }
    if (pinyin.isEmpty) pinyin = dictionary[hanzi] ?? '';
    if (!seen.add(hanzi)) continue;
    words.add(ParsedWord(hanzi, pinyin, meaning));
  }
  return words;
}

/// "1. 爱 (ài): yêu, thích" → [爱, ài, yêu, thích]
List<String> _freeLine(String line) {
  final head = RegExp(r'^\s*(?:\d+[.)]\s*)?([㐀-鿿豈-﫿]+)\s*').firstMatch(line);
  if (head == null) return [line];
  final hanzi = head.group(1)!;
  var rest = line.substring(head.end);
  var pinyin = '';

  // "(nǐ hǎo)" or "[nǐ hǎo]" right after the characters.
  final paren = RegExp(r'^[(\[（]([^)\]）]*)[)\]）]\s*').firstMatch(rest);
  if (paren != null) {
    pinyin = paren.group(1)!.trim();
    rest = rest.substring(paren.end);
  }
  // "pinyin: meaning" / "pinyin - meaning" / ": meaning"
  final sep = RegExp(r'\s*[:：=–—]\s*|\s+-\s+|^-\s*').firstMatch(rest);
  if (sep != null) {
    final before = rest.substring(0, sep.start).trim();
    if (pinyin.isEmpty && before.isNotEmpty && _latinPinyin.hasMatch(before)) {
      pinyin = before;
    }
    rest = rest.substring(sep.end);
  } else if (pinyin.isEmpty &&
      _pinyinOnly.hasMatch(rest) &&
      _latinPinyin.hasMatch(rest.trim())) {
    // Only pinyin after the characters, no meaning.
    return [hanzi, rest.trim(), ''];
  }
  return [hanzi, pinyin, rest.trim()];
}

List<String> _csvFields(String line) {
  final out = <String>[];
  final buf = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        buf.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (c == ',' && !quoted) {
      out.add(buf.toString());
      buf.clear();
    } else {
      buf.write(c);
    }
  }
  out.add(buf.toString());
  return out;
}

/// Minimal .xlsx reader: rows of the first worksheet as strings.
List<List<String>> _xlsxRows(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  String? read(String path) {
    final f = archive.findFile(path);
    return f == null ? null : utf8.decode(f.content as List<int>);
  }

  final shared = <String>[];
  final sst = read('xl/sharedStrings.xml');
  if (sst != null) {
    for (final si in XmlDocument.parse(sst).findAllElements('si')) {
      shared.add(si.findAllElements('t').map((t) => t.innerText).join());
    }
  }
  final sheetPath = archive.files
      .map((f) => f.name)
      .where((n) => n.startsWith('xl/worksheets/sheet') && n.endsWith('.xml'))
      .fold<String?>(null, (a, b) => a == null || b.compareTo(a) < 0 ? b : a);
  if (sheetPath == null) {
    throw const FormatException('File Excel không có trang tính');
  }

  int col(String ref) {
    var n = 0;
    for (final ch in ref.codeUnits) {
      if (ch < 65 || ch > 90) break;
      n = n * 26 + (ch - 64);
    }
    return n - 1;
  }

  final rows = <List<String>>[];
  for (final row in XmlDocument.parse(
    read(sheetPath)!,
  ).findAllElements('row')) {
    final cells = <int, String>{};
    for (final c in row.findElements('c')) {
      final type = c.getAttribute('t');
      String value;
      if (type == 's') {
        value = shared[int.parse(c.getElement('v')?.innerText ?? '0')];
      } else if (type == 'inlineStr') {
        value = c.findAllElements('t').map((t) => t.innerText).join();
      } else {
        value = c.getElement('v')?.innerText ?? '';
      }
      cells[col(c.getAttribute('r') ?? 'A')] = value;
    }
    if (cells.isEmpty) continue;
    final width = cells.keys.reduce((a, b) => a > b ? a : b) + 1;
    rows.add([for (var i = 0; i < width; i++) cells[i] ?? '']);
  }
  return rows;
}
