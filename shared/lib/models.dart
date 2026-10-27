class Question {
  Question({
    required this.id,
    required this.number,
    required this.text,
    required this.options,
    this.answer,
    this.explanation,
  });

  final String id;
  final int number;
  final String text;
  final List<String> options;

  /// Index of the correct option, or null if the document had no answer.
  final int? answer;
  final String? explanation;

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': number,
        't': text,
        'o': options,
        if (answer != null) 'a': answer,
        if (explanation != null) 'e': explanation,
      };

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'] as String,
        number: j['n'] as int,
        text: j['t'] as String,
        options: (j['o'] as List).cast<String>(),
        answer: j['a'] as int?,
        explanation: j['e'] as String?,
      );
}

class Section {
  Section({required this.title, required this.questions});

  final String title;
  final List<Question> questions;

  Map<String, dynamic> toJson() => {
        'title': title,
        'q': questions.map((q) => q.toJson()).toList(),
      };

  factory Section.fromJson(Map<String, dynamic> j) => Section(
        title: j['title'] as String,
        questions: (j['q'] as List)
            .map((e) => Question.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Deck {
  Deck({required this.id, required this.name, required this.sections});

  final String id;
  String name;
  final List<Section> sections;

  List<Question> get allQuestions =>
      [for (final s in sections) ...s.questions];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sections': sections.map((s) => s.toJson()).toList(),
      };

  factory Deck.fromJson(Map<String, dynamic> j) => Deck(
        id: j['id'] as String,
        name: j['name'] as String,
        sections: (j['sections'] as List)
            .map((e) => Section.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
