import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:isar_plus/isar_plus.dart';

import 'auth.dart';
import 'avatar.dart';
import 'chinese/chinese_store.dart';
import 'db.dart';
import 'package:study_shared/doc_reader.dart';
import 'package:study_shared/models.dart';
import 'package:study_shared/parser.dart';
import 'package:study_shared/api.dart';

/// The signed-in user's decks and results.
///
/// The API server is the source of truth; Isar keeps a copy so the app opens and
/// records answers offline, pushing unsynced answers on the next start.
class Store extends ChangeNotifier {
  Store._(this.db, this.auth, this.profile);

  final Isar db;
  final Auth auth;
  Profile profile;
  final List<Deck> decks = [];

  /// Latest result of each question id: true = right, false = wrong.
  final Map<String, bool> results = {};

  /// Number of finished quiz sessions per deck id.
  final Map<String, int> attempts = {};

  ImageProvider? avatar;

  /// Answers per day ("2026-10-25" → 34), for streaks and the daily goal.
  final Map<String, int> activity = {};

  /// Vocabulary lists and flashcard progress.
  late final ChineseStore chinese;

  /// True when the last sync with the server failed.
  bool offline = false;

  final Map<String, Deck> _deckOf = {};
  final Map<String, String> _sectionOf = {};

  ApiClient get _api => auth.api;
  String get user => profile.username;
  String get userId => profile.id;
  String? get name => profile.name;
  DateTime? get birthday => profile.birthday;

  bool get isBirthday {
    final b = birthday, now = DateTime.now();
    return b != null && b.day == now.day && b.month == now.month;
  }

  static Future<Store> load(Isar db, Auth auth, Profile profile) async {
    final store = Store._(db, auth, profile);
    store.avatar = cachedAvatar(db, profile.username);
    store._loadActivity();
    store.chinese = ChineseStore(store);
    await store.chinese.load();
    await store.sync();
    return store;
  }

  /// Pushes pending answers and pulls decks/results from the server.
  Future<void> sync() async {
    try {
      await _pushPending();
      await _pullDecks();
      await _pullResults();
      await _pullAttempts();
      avatar = await loadAvatar(db, _api, profile);
      await _syncActivity();
      await chinese.sync();
      unawaited(_api.post('/me/seen').then((_) {}, onError: (_) {}));
      offline = false;
    } catch (e) {
      debugPrint('sync failed: $e');
      offline = true;
    }
    _loadFromCache();
    notifyListeners();
  }

  // ------------------------------------------------------------ server → cache

  Future<void> _pullDecks() async {
    var deckRows = await _api.get('/decks') as List;
    if (!deckRows.any((d) => d['id'] == 'pldc')) {
      await _seedBundledDeck();
      deckRows = await _api.get('/decks') as List;
    }
    final questionRows = await _api.get('/questions') as List;
    db.write((db) {
      db.dbDecks.clear();
      db.dbQuestions.clear();
      db.dbDecks.putAll([
        for (final d in deckRows)
          DbDeck(id: d['id'] as String, name: d['name'] as String, position: d['position'] as int),
      ]);
      db.dbQuestions.putAll([
        for (final q in questionRows)
          DbQuestion(
            id: q['id'] as String,
            deckId: q['deck_id'] as String,
            sectionIndex: q['section_index'] as int,
            sectionTitle: q['section_title'] as String,
            position: q['position'] as int,
            number: q['number'] as int,
            text: q['text'] as String,
            options: (q['options'] as List).cast<String>(),
            answer: q['answer'] as int?,
            explanation: q['explanation'] as String?,
          ),
      ]);
    });
  }

  /// Uploads the bundled Pháp luật đại cương document (chapters 1–6 only).
  Future<void> _seedBundledDeck() async {
    final data = await rootBundle.load('assets/phap_luat_dai_cuong.pdf');
    final text = extractDocumentText('a.pdf', data.buffer.asUint8List());
    final parsed = parseQuizText(text, idPrefix: 'pldc');
    final chapters = parsed.sections
        .where((s) => s.title.toLowerCase().startsWith('chương'))
        .toList();
    try {
      await _uploadDeck(Deck(id: 'pldc', name: 'Pháp luật đại cương', sections: chapters), 0);
    } on ApiException catch (e) {
      if (e.status != 409) rethrow; // someone else seeded it first
    }
  }

  Future<void> _uploadDeck(Deck deck, int position) async {
    final rows = [
      for (final (si, s) in deck.sections.indexed)
        for (final (qi, q) in s.questions.indexed)
          {
            'id': q.id,
            'section_index': si,
            'section_title': s.title,
            'position': qi,
            'number': q.number,
            'text': q.text,
            'options': q.options,
            'answer': q.answer,
            'explanation': q.explanation,
          },
    ];
    await _api.post('/decks', {'id': deck.id, 'name': deck.name, 'position': position, 'questions': rows});
  }

  Future<void> _pullResults() async {
    final rows = await _api.get('/me/results') as List;
    db.write((db) {
      db.dbResults.where().userEqualTo(userId).deleteAll();
      db.dbResults.putAll([
        for (final r in rows)
          DbResult(
            id: _resultId(r['question_id'] as String),
            user: userId,
            questionId: r['question_id'] as String,
            correct: r['correct'] as bool,
            updatedAt: DateTime.parse(r['updated_at'] as String),
            synced: true,
          ),
      ]);
    });
  }

  Future<void> _pullAttempts() async {
    final rows = await _api.get('/me/attempts') as List;
    db.write((db) {
      db.dbAttempts.where().userEqualTo(userId).deleteAll();
      for (final a in rows) {
        db.dbAttempts.put(DbAttempt(
          id: db.dbAttempts.autoIncrement(),
          user: userId,
          deckId: (a['deck_id'] as String?) ?? '',
          at: DateTime.parse(a['at'] as String),
          totalCount: a['total'] as int,
          rightCount: a['right_count'] as int,
          wrongCount: a['wrong_count'] as int,
          seconds: a['seconds'] as int,
          synced: true,
        ));
      }
    });
  }

  // ------------------------------------------------------------ cache → server

  /// Sends answers and sessions recorded while offline. The pulls that follow
  /// replace the local rows with synced copies.
  Future<void> _pushPending() async {
    final results = db.dbResults.where().userEqualTo(userId).findAll().where((r) => !r.synced);
    if (results.isNotEmpty) {
      await _api.put('/me/results', [
        for (final r in results)
          {
            'question_id': r.questionId,
            'correct': r.correct,
            'updated_at': r.updatedAt.toUtc().toIso8601String(),
          },
      ]);
    }
    final attempts = db.dbAttempts.where().userEqualTo(userId).findAll().where((a) => !a.synced);
    if (attempts.isNotEmpty) {
      await _api.post('/me/attempts', [for (final a in attempts) _attemptRow(a)]);
    }
  }

  Map<String, dynamic> _attemptRow(DbAttempt a) => {
        'deck_id': a.deckId.isEmpty ? null : a.deckId,
        'at': a.at.toUtc().toIso8601String(),
        'total': a.totalCount,
        'right_count': a.rightCount,
        'wrong_count': a.wrongCount,
        'seconds': a.seconds,
      };

  // ------------------------------------------------------------ cache → memory

  void _loadFromCache() {
    final byDeck = <String, List<DbQuestion>>{};
    for (final q in db.dbQuestions.where().findAll()) {
      byDeck.putIfAbsent(q.deckId, () => []).add(q);
    }
    final rows = db.dbDecks.where().findAll()..sort((a, b) => a.position.compareTo(b.position));
    decks.clear();
    for (final d in rows) {
      final qs = (byDeck[d.id] ?? [])
        ..sort((a, b) => a.sectionIndex != b.sectionIndex
            ? a.sectionIndex.compareTo(b.sectionIndex)
            : a.position.compareTo(b.position));
      final sections = <Section>[];
      for (final q in qs) {
        if (sections.isEmpty || sections.last.title != q.sectionTitle) {
          sections.add(Section(title: q.sectionTitle, questions: []));
        }
        sections.last.questions.add(Question(
          id: q.id,
          number: q.number,
          text: q.text,
          options: q.options,
          answer: q.answer,
          explanation: q.explanation,
        ));
      }
      decks.add(Deck(id: d.id, name: d.name, sections: sections));
    }
    _reindex();

    results.clear();
    for (final r in db.dbResults.where().userEqualTo(userId).findAll()) {
      results[r.questionId] = r.correct;
    }
    attempts.clear();
    for (final a in db.dbAttempts.where().userEqualTo(userId).findAll()) {
      attempts[a.deckId] = (attempts[a.deckId] ?? 0) + 1;
    }
  }

  void _reindex() {
    _deckOf.clear();
    _sectionOf.clear();
    for (final d in decks) {
      for (final s in d.sections) {
        for (final q in s.questions) {
          _deckOf[q.id] = d;
          _sectionOf[q.id] = s.title;
        }
      }
    }
  }

  Deck? deckOf(Question q) => _deckOf[q.id];
  String sectionOf(Question q) => _sectionOf[q.id] ?? '';

  List<Question> get allQuestions => [for (final d in decks) ...d.allQuestions];

  String _resultId(String questionId) => '$userId|$questionId';

  // ------------------------------------------------------------ actions

  /// Uploads a new shared deck. Throws if the server is unreachable.
  Future<void> addDeck(Deck deck) async {
    await _uploadDeck(deck, decks.length);
    await _pullDecks();
    _loadFromCache();
    notifyListeners();
  }

  /// Deletes the deck for everyone. Throws if not allowed or offline.
  Future<void> removeDeck(Deck deck) async {
    await _api.delete('/decks/${deck.id}');
    await _pullDecks();
    _loadFromCache();
    notifyListeners();
  }

  Future<void> renameDeck(Deck deck, String name) async {
    await _api.patch('/decks/${deck.id}', {'name': name});
    db.write((db) {
      final row = db.dbDecks.get(deck.id);
      if (row != null) db.dbDecks.put(DbDeck(id: row.id, name: name, position: row.position));
    });
    deck.name = name;
    notifyListeners();
  }

  /// Saves an answer locally right away, then on the server.
  Future<void> record(Question q, bool correct) async {
    final row = DbResult(
      id: _resultId(q.id),
      user: userId,
      questionId: q.id,
      correct: correct,
      updatedAt: DateTime.now(),
    );
    db.write((db) => db.dbResults.put(row));
    results[q.id] = correct;
    bumpActivity();
    try {
      await _api.put('/me/results', [
        {
          'question_id': q.id,
          'correct': correct,
          'updated_at': row.updatedAt.toUtc().toIso8601String(),
        },
      ]);
      db.write((db) => db.dbResults.put(DbResult(
            id: row.id,
            user: row.user,
            questionId: row.questionId,
            correct: row.correct,
            updatedAt: row.updatedAt,
            synced: true,
          )));
    } catch (_) {
      offline = true; // pushed on next sync
    }
  }

  /// Saves a finished session for every deck it touched.
  Future<void> recordAttempt(
      Iterable<Question> questions, int right, int wrong, Duration elapsed) async {
    final deckIds = {for (final q in questions) deckOf(q)?.id}.nonNulls.toList();
    final rows = <DbAttempt>[];
    db.write((db) {
      for (final id in deckIds) {
        final a = DbAttempt(
          id: db.dbAttempts.autoIncrement(),
          user: userId,
          deckId: id,
          at: DateTime.now(),
          totalCount: questions.length,
          rightCount: right,
          wrongCount: wrong,
          seconds: elapsed.inSeconds,
        );
        db.dbAttempts.put(a);
        rows.add(a);
      }
    });
    for (final id in deckIds) {
      attempts[id] = (attempts[id] ?? 0) + 1;
    }
    notifyListeners();
    try {
      await _api.post('/me/attempts', [for (final a in rows) _attemptRow(a)]);
      db.write((db) => db.dbAttempts.putAll([
            for (final a in rows)
              DbAttempt(
                id: a.id,
                user: a.user,
                deckId: a.deckId,
                at: a.at,
                totalCount: a.totalCount,
                rightCount: a.rightCount,
                wrongCount: a.wrongCount,
                seconds: a.seconds,
                synced: true,
              ),
          ]));
    } catch (_) {
      offline = true;
    }
  }

  Future<void> resetProgress(Iterable<Question> questions) async {
    final ids = [for (final q in questions) q.id];
    await _api.post('/me/results/delete', {'question_ids': ids});
    db.write((db) => db.dbResults.deleteAll([for (final id in ids) _resultId(id)]));
    ids.forEach(results.remove);
    notifyListeners();
  }

  /// Uploads a new profile photo; null removes it.
  Future<void> setAvatar(Uint8List? png) async {
    if (png == null) {
      await removeAvatar(db, _api, profile);
    } else {
      await uploadAvatar(db, _api, profile, png);
    }
    profile = (await auth.loadProfile()) ?? profile;
    avatar = cachedAvatar(db, profile.username);
    notifyListeners();
  }

  bool get hasCustomAvatar => profile.avatarPath != null;

  // ------------------------------------------------------------ daily activity

  String get _activityKey => 'activity:$userId';
  String get _pendingKey => 'activity_pending:$userId';

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get todayCount => activity[dayKey(DateTime.now())] ?? 0;

  int get dailyGoal => int.tryParse(db.setting('daily_goal') ?? '') ?? 20;

  set dailyGoal(int value) {
    db.setSetting('daily_goal', '$value');
    notifyListeners();
  }

  /// Consecutive days with at least one answer, ending today (or yesterday).
  int get streak {
    var day = DateTime.now();
    if ((activity[dayKey(day)] ?? 0) == 0) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while ((activity[dayKey(day)] ?? 0) > 0) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  Map<String, int> _readMap(String key) =>
      ((jsonDecode(db.setting(key) ?? '{}') as Map).cast<String, int>());

  void _loadActivity() {
    activity
      ..clear()
      ..addAll(_readMap(_activityKey));
  }

  /// Counts [n] answers for today (also used by the Chinese pages).
  void bumpActivity([int n = 1]) {
    final today = dayKey(DateTime.now());
    activity[today] = (activity[today] ?? 0) + n;
    final pending = _readMap(_pendingKey);
    pending[today] = (pending[today] ?? 0) + n;
    db.setSetting(_activityKey, jsonEncode(activity));
    db.setSetting(_pendingKey, jsonEncode(pending));
    notifyListeners();
    unawaited(_pushActivity().catchError((_) {}));
  }

  Future<void> _pushActivity() async {
    final pending = _readMap(_pendingKey);
    for (final e in pending.entries.toList()) {
      await _api.post('/me/activity', [
        {'day': e.key, 'n': e.value},
      ]);
      final now = _readMap(_pendingKey);
      final left = (now[e.key] ?? 0) - e.value;
      left > 0 ? now[e.key] = left : now.remove(e.key);
      db.setSetting(_pendingKey, jsonEncode(now));
    }
  }

  /// Sends pending counts, then takes the server's last 60 days as the truth.
  Future<void> _syncActivity() async {
    try {
      await _pushActivity();
      final since = dayKey(DateTime.now().subtract(const Duration(days: 60)));
      final rows = await _api.get('/me/activity', query: {'since': since}) as List;
      final pending = _readMap(_pendingKey);
      activity
        ..clear()
        ..addAll({for (final r in rows) r['day'] as String: r['count'] as int});
      pending.forEach((day, n) => activity[day] = (activity[day] ?? 0) + n);
      db.setSetting(_activityKey, jsonEncode(activity));
    } catch (e) {
      debugPrint('activity sync failed: $e');
    }
  }
}

/// Done / right / wrong counts over a set of questions.
class Stats {
  Stats(Store store, Iterable<Question> qs) {
    for (final q in qs) {
      total++;
      final r = store.results[q.id];
      if (r == null) continue;
      done++;
      if (r) right++;
    }
  }

  int total = 0, done = 0, right = 0;
  int get wrong => done - right;
  double get accuracy => done == 0 ? 0 : right / done;
}
