import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';

part 'db.g.dart';

/// Small key/value settings (remembered login, seeding flags...).
@collection
class DbSetting {
  DbSetting({required this.id, required this.value});

  final String id;
  final String value;
}

@collection
class DbDeck {
  DbDeck({required this.id, required this.name, required this.position});

  final String id;
  final String name;
  final int position;
}

@collection
class DbQuestion {
  DbQuestion({
    required this.id,
    required this.deckId,
    required this.sectionIndex,
    required this.sectionTitle,
    required this.position,
    required this.number,
    required this.text,
    required this.options,
    this.answer,
    this.explanation,
  });

  final String id;
  @Index()
  final String deckId;
  final int sectionIndex;
  final String sectionTitle;
  final int position;
  final int number;
  final String text;
  final List<String> options;
  final int? answer;
  final String? explanation;
}

/// Latest answer of a user to a question.
@collection
class DbResult {
  DbResult({
    required this.id,
    required this.user,
    required this.questionId,
    required this.correct,
    required this.updatedAt,
    this.synced = false,
  });

  /// "$userId|$questionId"
  final String id;
  @Index()
  final String user;
  final String questionId;
  final bool correct;
  final DateTime updatedAt;

  /// False until the answer has been saved to the server.
  final bool synced;
}

/// One finished quiz session.
@collection
class DbAttempt {
  DbAttempt({
    required this.id,
    required this.user,
    required this.deckId,
    required this.at,
    required this.totalCount,
    required this.rightCount,
    required this.wrongCount,
    required this.seconds,
    this.synced = false,
  });

  final int id;
  @Index()
  final String user;
  final String deckId;
  final DateTime at;
  final int totalCount;
  final int rightCount;
  final int wrongCount;
  final int seconds;

  /// False until the session has been saved to the server.
  final bool synced;
}

/// Flashcard / vocabulary-quiz progress of a user on one word.
@collection
class DbVocabProgress {
  DbVocabProgress({
    required this.id,
    required this.user,
    required this.wordId,
    required this.known,
    required this.correct,
    required this.wrong,
    required this.updatedAt,
    this.synced = false,
  });

  /// "$userId|$wordId"
  final String id;
  @Index()
  final String user;
  final String wordId;
  final bool known;
  final int correct;
  final int wrong;
  final DateTime updatedAt;
  final bool synced;
}

Future<Isar>? _database;

/// The app's single database instance, opened on first use.
Future<Isar> database() => _database ??= _openDatabase();

/// Opens the on-device Isar database (IndexedDB in the browser).
Future<Isar> _openDatabase() async {
  final schemas = [
    DbSettingSchema,
    DbDeckSchema,
    DbQuestionSchema,
    DbResultSchema,
    DbAttemptSchema,
    DbVocabProgressSchema,
  ];
  if (kIsWeb) {
    // The wasm build ships next to index.html (web/isar.wasm + web/isar.js).
    await Isar.initialize(Uri.base.resolve('isar.wasm').toString());
    return Isar.open(
      schemas: schemas,
      directory: 'isar',
      name: 'study_for_you',
      engine: IsarEngine.sqlite,
      inspector: false,
    );
  }
  throw UnsupportedError('Ứng dụng hiện chỉ chạy trên web');
}

extension DbSettings on Isar {
  String? setting(String key) => dbSettings.get(key)?.value;

  void setSetting(String key, String? value) => write((db) {
        if (value == null) {
          db.dbSettings.delete(key);
        } else {
          db.dbSettings.put(DbSetting(id: key, value: value));
        }
      });
}
