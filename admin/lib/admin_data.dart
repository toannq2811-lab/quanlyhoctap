import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:study_shared/profile.dart';
import 'package:study_shared/vocab.dart';
import 'package:study_shared/api.dart';
import 'package:study_shared/models.dart';

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Answer {
  Answer(this.questionId, this.correct, this.at);

  final String questionId;
  final bool correct;
  final DateTime at;
}

class Attempt {
  Attempt(
    this.deckId,
    this.at,
    this.total,
    this.right,
    this.wrong,
    this.seconds,
  );

  final String? deckId;
  final DateTime at;
  final int total, right, wrong, seconds;
}

class WordStat {
  WordStat(this.known, this.correct, this.wrong);

  final bool known;
  final int correct, wrong;
}

/// One account with everything the admin pages show about it.
class Learner {
  Learner(this.profile, this.lastSeen, this.createdAt);

  Profile profile;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final Map<String, Answer> answers = {};
  final List<Attempt> attempts = [];
  final Map<String, int> activity = {};
  final Map<String, WordStat> words = {};
  ImageProvider? avatar;

  String get displayName => profile.name ?? profile.username;
  int get today => activity[dayKey(DateTime.now())] ?? 0;
  int get done => answers.length;
  int get right => answers.values.where((a) => a.correct).length;
  int get knownWords => words.values.where((w) => w.known).length;

  int get streak {
    var day = DateTime.now();
    if ((activity[dayKey(day)] ?? 0) == 0) {
      day = day.subtract(const Duration(days: 1));
    }
    var n = 0;
    while ((activity[dayKey(day)] ?? 0) > 0) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }
}

/// Everything the admin website reads and edits, through the API server.
class AdminData extends ChangeNotifier {
  AdminData(this.api);

  final ApiClient api;

  final List<Deck> decks = [];
  final Map<String, String> deckOwner = {};
  final Map<String, String> sectionOf = {};
  final List<Learner> learners = [];
  final List<VocabList> vocabLists = [];

  /// Kept for the pages' notices; the API server always has every table.
  bool chineseReady = true;
  bool loading = false;
  Object? error;

  Iterable<Question> get allQuestions => decks.expand((d) => d.allQuestions);
  List<Learner> get students => learners.where((l) => !l.profile.isAdmin).toList();

  Learner? byId(String id) => learners.where((l) => l.profile.id == id).firstOrNull;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _loadDecks();
      await _loadLearners();
      await _loadVocab();
    } catch (e) {
      error = e;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> _loadDecks() async {
    final deckRows = await api.get('/decks') as List;
    final qRows = await api.get('/questions') as List;
    final byDeck = <String, List<Map<String, dynamic>>>{};
    for (final q in qRows.cast<Map<String, dynamic>>()) {
      byDeck.putIfAbsent(q['deck_id'] as String, () => []).add(q);
    }
    decks.clear();
    deckOwner.clear();
    sectionOf.clear();
    for (final d in deckRows.cast<Map<String, dynamic>>()) {
      final id = d['id'] as String;
      if (d['created_by'] != null) deckOwner[id] = d['created_by'] as String;
      final qs = (byDeck[id] ?? [])
        ..sort((a, b) {
          final s = (a['section_index'] as int).compareTo(b['section_index'] as int);
          return s != 0 ? s : (a['position'] as int).compareTo(b['position'] as int);
        });
      final sections = <Section>[];
      var lastIndex = -1;
      for (final q in qs) {
        if (q['section_index'] != lastIndex) {
          lastIndex = q['section_index'] as int;
          sections.add(Section(title: q['section_title'] as String, questions: []));
        }
        final question = Question(
          id: q['id'] as String,
          number: q['number'] as int,
          text: q['text'] as String,
          options: (q['options'] as List).cast<String>(),
          answer: q['answer'] as int?,
          explanation: q['explanation'] as String?,
        );
        sections.last.questions.add(question);
        sectionOf[question.id] = sections.last.title;
      }
      decks.add(Deck(id: id, name: d['name'] as String, sections: sections));
    }
  }

  Future<void> _loadLearners() async {
    final data = await api.get('/admin/data') as Map<String, dynamic>;
    DateTime local(Object? s) => DateTime.parse(s as String).toLocal();
    learners
      ..clear()
      ..addAll([
        for (final p in (data['users'] as List).cast<Map<String, dynamic>>())
          Learner(
            Profile.fromJson(p),
            p['last_seen'] == null ? null : local(p['last_seen']),
            local(p['created_at']),
          ),
      ]);
    final byId = {for (final l in learners) l.profile.id: l};
    for (final r in (data['results'] as List).cast<Map<String, dynamic>>()) {
      byId[r['user_id']]?.answers[r['question_id'] as String] =
          Answer(r['question_id'] as String, r['correct'] as bool, local(r['updated_at']));
    }
    for (final a in (data['attempts'] as List).cast<Map<String, dynamic>>()) {
      byId[a['user_id']]?.attempts.add(Attempt(
            a['deck_id'] as String?,
            local(a['at']),
            a['total'] as int,
            a['right_count'] as int,
            a['wrong_count'] as int,
            a['seconds'] as int,
          ));
    }
    for (final d in (data['activity'] as List).cast<Map<String, dynamic>>()) {
      byId[d['user_id']]?.activity[d['day'] as String] = d['count'] as int;
    }
    for (final w in (data['vocab_progress'] as List).cast<Map<String, dynamic>>()) {
      byId[w['user_id']]?.words[w['word_id'] as String] =
          WordStat(w['known'] as bool, w['correct'] as int, w['wrong'] as int);
    }
    for (final l in learners) {
      if (l.profile.avatarPath == null) continue;
      try {
        l.avatar = MemoryImage(await api.getBytes('/users/${l.profile.id}/avatar'));
      } catch (_) {}
    }
  }

  Future<void> _loadVocab() async {
    vocabLists
      ..clear()
      ..addAll(await loadBuiltInLists());
    final lists = await api.get('/vocab/lists') as List;
    final words = await api.get('/vocab/words') as List;
    final byList = <String, List<Map<String, dynamic>>>{};
    for (final w in words.cast<Map<String, dynamic>>()) {
      byList.putIfAbsent(w['list_id'] as String, () => []).add(w);
    }
    for (final l in lists.cast<Map<String, dynamic>>()) {
      final ws = (byList[l['id']] ?? [])
        ..sort((a, b) => (a['position'] as int).compareTo(b['position'] as int));
      vocabLists.add(VocabList(
        id: l['id'] as String,
        name: l['name'] as String,
        createdBy: l['created_by'] as String?,
        words: [
          for (final w in ws)
            VocabWord(
              id: w['id'] as String,
              hanzi: w['hanzi'] as String,
              pinyin: w['pinyin'] as String,
              meaning: w['meaning'] as String,
            ),
        ],
      ));
    }
  }

  // ---------------------------------------------------------------- decks

  Future<void> addDeck(Deck deck) async {
    await api.post('/decks', {
      'id': deck.id,
      'name': deck.name,
      'position': decks.length,
      'questions': [
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
      ],
    });
    await _loadDecks();
    notifyListeners();
  }

  Future<void> renameDeck(Deck deck, String name) async {
    await api.patch('/decks/${deck.id}', {'name': name});
    deck.name = name;
    notifyListeners();
  }

  Future<void> deleteDeck(Deck deck) async {
    await api.delete('/decks/${deck.id}');
    await load();
  }

  Future<void> updateQuestion(Question old, Question edited) async {
    await api.patch('/questions/${old.id}', {
      'text': edited.text,
      'options': edited.options,
      'answer': edited.answer,
      'explanation': edited.explanation,
    });
    await _loadDecks();
    notifyListeners();
  }

  Future<void> deleteQuestion(Question q) async {
    await api.delete('/questions/${q.id}');
    await _loadDecks();
    notifyListeners();
  }

  // ---------------------------------------------------------------- vocabulary

  Future<void> addVocabList(String name, List<ParsedWord> words) async {
    final id = 'v${DateTime.now().millisecondsSinceEpoch}';
    await api.post('/vocab/lists', {
      'id': id,
      'name': name,
      'position': vocabLists.where((l) => !l.builtIn).length,
      'words': [
        for (final (i, w) in words.indexed)
          {'id': '$id-$i', 'position': i, 'hanzi': w.hanzi, 'pinyin': w.pinyin, 'meaning': w.meaning},
      ],
    });
    await _loadVocab();
    notifyListeners();
  }

  Future<void> deleteVocabList(VocabList list) async {
    await api.delete('/vocab/lists/${list.id}');
    await _loadVocab();
    notifyListeners();
  }

  Future<void> updateWord(VocabWord w, {required String pinyin, required String meaning}) async {
    await api.patch('/vocab/words/${w.id}', {'pinyin': pinyin, 'meaning': meaning});
    await _loadVocab();
    notifyListeners();
  }

  // ---------------------------------------------------------------- accounts

  Future<void> setRole(Learner l, String role) async {
    await api.patch('/admin/users/${l.profile.id}', {'role': role});
    await _loadLearners();
    notifyListeners();
  }

  Future<void> updateProfile(Learner l, String name, DateTime? birthday) async {
    await api.patch('/admin/users/${l.profile.id}', {
      'name': name,
      'birthday': birthday?.toIso8601String().substring(0, 10),
    });
    await _loadLearners();
    notifyListeners();
  }

  Future<void> createAccount(String username, String password, String name) async {
    await api.post('/admin/users', {'username': username, 'password': password, 'name': name});
    await _loadLearners();
    notifyListeners();
  }
}
