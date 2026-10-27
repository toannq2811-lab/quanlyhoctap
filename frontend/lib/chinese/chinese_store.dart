import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:study_shared/api.dart';

import '../db.dart';
import '../storage.dart';
import 'package:study_shared/vocab.dart';

class WordProgress {
  const WordProgress({this.known = false, this.correct = 0, this.wrong = 0});

  final bool known;
  final int correct;
  final int wrong;
}

/// Vocabulary lists (built-in HSK + lists imported from files) and the
/// user's progress, cached in Isar and synced with the API server.
class ChineseStore extends ChangeNotifier {
  ChineseStore(this.store);

  final Store store;
  final List<VocabList> lists = [];
  final Map<String, WordProgress> progress = {};

  /// hanzi → pinyin from the built-in lists, used to fill imported words.
  final Map<String, String> dictionary = {};

  /// False when the server rejected the last Chinese sync (not just offline).
  bool serverReady = true;

  Isar get _db => store.db;
  String get _uid => store.userId;
  ApiClient get _api => store.auth.api;
  static const _listsKey = 'vocab_lists_cache';

  Future<void> load() async {
    final builtIn = await loadBuiltInLists();
    for (final l in builtIn) {
      for (final w in l.words) {
        dictionary.putIfAbsent(w.hanzi, () => w.pinyin);
      }
    }
    lists
      ..clear()
      ..addAll(builtIn)
      ..addAll(_cachedLists());
    _loadProgress();
  }

  List<VocabList> _cachedLists() {
    final raw = _db.setting(_listsKey);
    if (raw == null) return [];
    return [
      for (final l in jsonDecode(raw) as List) VocabList.fromJson(l as Map<String, dynamic>),
    ];
  }

  void _loadProgress() {
    progress.clear();
    for (final p in _db.dbVocabProgress.where().userEqualTo(_uid).findAll()) {
      progress[p.wordId] = WordProgress(known: p.known, correct: p.correct, wrong: p.wrong);
    }
  }

  Future<void> sync() async {
    try {
      await _pushPending();
      await _pullLists();
      await _pullProgress();
      serverReady = true;
    } on ApiException catch (e) {
      debugPrint('chinese sync failed: $e');
      serverReady = e.offline;
    } catch (e) {
      debugPrint('chinese sync failed: $e');
    }
    lists.removeWhere((l) => !l.builtIn);
    lists.addAll(_cachedLists());
    _loadProgress();
    notifyListeners();
  }

  Future<void> _pullLists() async {
    final listRows = await _api.get('/vocab/lists') as List;
    final wordRows = await _api.get('/vocab/words') as List;
    final byList = <String, List<Map<String, dynamic>>>{};
    for (final w in wordRows) {
      byList.putIfAbsent(w['list_id'] as String, () => []).add(w);
    }
    final custom = [
      for (final l in listRows)
        VocabList(
          id: l['id'] as String,
          name: l['name'] as String,
          createdBy: l['created_by'] as String?,
          words: [
            for (final w in (byList[l['id']] ?? [])
              ..sort((a, b) => (a['position'] as int).compareTo(b['position'] as int)))
              VocabWord(
                id: w['id'] as String,
                hanzi: w['hanzi'] as String,
                pinyin: w['pinyin'] as String,
                meaning: w['meaning'] as String,
              ),
          ],
        ),
    ];
    _db.setSetting(_listsKey, jsonEncode([for (final l in custom) l.toJson()]));
  }

  Future<void> _pullProgress() async {
    final rows = await _api.get('/me/vocab-progress') as List;
    _db.write((db) {
      db.dbVocabProgress.where().userEqualTo(_uid).deleteAll();
      db.dbVocabProgress.putAll([
        for (final r in rows)
          DbVocabProgress(
            id: '$_uid|${r['word_id']}',
            user: _uid,
            wordId: r['word_id'] as String,
            known: r['known'] as bool,
            correct: r['correct'] as int,
            wrong: r['wrong'] as int,
            updatedAt: DateTime.parse(r['updated_at'] as String),
            synced: true,
          ),
      ]);
    });
  }

  Future<void> _pushPending() async {
    final pending =
        _db.dbVocabProgress.where().userEqualTo(_uid).findAll().where((p) => !p.synced).toList();
    if (pending.isEmpty) return;
    await _api.put('/me/vocab-progress', [for (final p in pending) _row(p)]);
  }

  Map<String, dynamic> _row(DbVocabProgress p) => {
        'word_id': p.wordId,
        'known': p.known,
        'correct': p.correct,
        'wrong': p.wrong,
        'updated_at': p.updatedAt.toUtc().toIso8601String(),
      };

  Future<void> _save(String wordId, WordProgress next) async {
    progress[wordId] = next;
    final row = DbVocabProgress(
      id: '$_uid|$wordId',
      user: _uid,
      wordId: wordId,
      known: next.known,
      correct: next.correct,
      wrong: next.wrong,
      updatedAt: DateTime.now(),
    );
    _db.write((db) => db.dbVocabProgress.put(row));
    notifyListeners();
    try {
      await _api.put('/me/vocab-progress', [_row(row)]);
      _db.write((db) => db.dbVocabProgress.put(DbVocabProgress(
            id: row.id,
            user: row.user,
            wordId: row.wordId,
            known: row.known,
            correct: row.correct,
            wrong: row.wrong,
            updatedAt: row.updatedAt,
            synced: true,
          )));
    } catch (_) {
      // Pushed on the next sync.
    }
  }

  WordProgress of(VocabWord w) => progress[w.id] ?? const WordProgress();

  /// Flashcard: "Đã thuộc" / "Chưa thuộc".
  Future<void> setKnown(VocabWord w, bool known) {
    final p = of(w);
    store.bumpActivity();
    return _save(w.id, WordProgress(known: known, correct: p.correct, wrong: p.wrong));
  }

  /// Vocabulary quiz answer; two right answers in a row mark the word known.
  Future<void> recordAnswer(VocabWord w, bool correct) {
    final p = of(w);
    store.bumpActivity();
    return _save(
      w.id,
      WordProgress(
        known: correct ? (p.known || p.correct + 1 >= 2) : false,
        correct: p.correct + (correct ? 1 : 0),
        wrong: p.wrong + (correct ? 0 : 1),
      ),
    );
  }

  int knownIn(VocabList l) => l.words.where((w) => of(w).known).length;

  int get totalKnown => progress.values.where((p) => p.known).length;

  List<VocabWord> get allWords => [for (final l in lists) ...l.words];

  /// Uploads a list imported from a file (shared with everyone).
  Future<void> addList(String name, List<ParsedWord> words) async {
    final id = 'v${DateTime.now().millisecondsSinceEpoch}';
    final rows = [
      for (final (i, w) in words.indexed)
        {
          'id': '$id-$i',
          'position': i,
          'hanzi': w.hanzi,
          'pinyin': w.pinyin,
          'meaning': w.meaning,
        },
    ];
    await _api.post('/vocab/lists', {
      'id': id,
      'name': name,
      'position': lists.where((l) => !l.builtIn).length,
      'words': rows,
    });
    await sync();
  }

  Future<void> removeList(VocabList list) async {
    await _api.delete('/vocab/lists/${list.id}');
    await sync();
  }
}
