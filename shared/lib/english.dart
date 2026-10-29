import 'dart:convert';

import 'package:flutter/services.dart';

import 'vocab.dart';

/// One beginner English vocabulary topic (shared/assets/english/vocab.json).
class EnglishTopic {
  EnglishTopic(this.list, this.icon);

  final VocabList list;
  final String icon;
}

/// A form of a tense: "Khẳng định: S + V(s/es) + O".
class TenseForm {
  TenseForm(this.label, this.formula, this.example, this.exampleVi);

  final String label, formula, example, exampleVi;
}

class TenseUsage {
  TenseUsage(this.text, this.example, this.exampleVi);

  final String text, example, exampleVi;
}

class TenseExercise {
  TenseExercise(this.id, this.question, this.options, this.answer, this.explain);

  final String id;
  final String question;
  final List<String> options;
  final int answer;
  final String explain;

  /// Progress is stored like a vocabulary word, under this id.
  VocabWord get asWord => VocabWord(id: id, hanzi: question, pinyin: '', meaning: options[answer]);
}

class Tense {
  Tense({
    required this.id,
    required this.order,
    required this.vi,
    required this.en,
    required this.summary,
    required this.forms,
    required this.usage,
    required this.signals,
    required this.tips,
    required this.exercises,
  });

  final String id;
  final int order;
  final String vi, en, summary;
  final List<TenseForm> forms;
  final List<TenseUsage> usage;
  final List<String> signals, tips;
  final List<TenseExercise> exercises;
}

class EnglishCourse {
  EnglishCourse(this.tenses, this.topics);

  final List<Tense> tenses;
  final List<EnglishTopic> topics;

  List<TenseExercise> get allExercises => [for (final t in tenses) ...t.exercises];
}

Future<EnglishCourse> loadEnglishCourse() async {
  final tensesJson =
      jsonDecode(await rootBundle.loadString('packages/study_shared/assets/english/tenses.json')) as List;
  final vocabJson =
      jsonDecode(await rootBundle.loadString('packages/study_shared/assets/english/vocab.json')) as List;

  final tenses = [
    for (final t in tensesJson.cast<Map<String, dynamic>>())
      Tense(
        id: t['id'] as String,
        order: t['order'] as int,
        vi: t['vi'] as String,
        en: t['en'] as String,
        summary: t['summary'] as String,
        forms: [
          for (final f in (t['forms'] as List).cast<Map<String, dynamic>>())
            TenseForm(f['label'] as String, f['formula'] as String, f['example'] as String,
                f['exampleVi'] as String),
        ],
        usage: [
          for (final u in (t['usage'] as List).cast<Map<String, dynamic>>())
            TenseUsage(u['text'] as String, u['example'] as String, u['exampleVi'] as String),
        ],
        signals: (t['signals'] as List).cast<String>(),
        tips: (t['tips'] as List).cast<String>(),
        exercises: [
          for (final (i, e) in (t['exercises'] as List).cast<Map<String, dynamic>>().indexed)
            TenseExercise('en-tense-${t['id']}-$i', e['q'] as String,
                (e['options'] as List).cast<String>(), e['answer'] as int, e['explain'] as String),
        ],
      ),
  ]..sort((a, b) => a.order.compareTo(b.order));

  final topics = [
    for (final t in vocabJson.cast<Map<String, dynamic>>())
      EnglishTopic(
        VocabList(
          id: 'en-${t['id']}',
          name: t['name'] as String,
          builtIn: true,
          words: [
            for (final w in (t['words'] as List).cast<Map<String, dynamic>>())
              VocabWord(
                id: 'en-${t['id']}-${w['w']}',
                hanzi: w['w'] as String,
                pinyin: w['ipa'] as String,
                meaning: w['vi'] as String,
                example: w['ex'] as String?,
                exampleVi: w['exVi'] as String?,
              ),
          ],
        ),
        t['icon'] as String? ?? '🔤',
      ),
  ];
  return EnglishCourse(tenses, topics);
}
