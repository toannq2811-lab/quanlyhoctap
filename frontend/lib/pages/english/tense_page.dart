import 'dart:math';

import 'package:flutter/material.dart';
import 'package:study_shared/english.dart';
import 'package:study_shared/theme.dart';

import '../../chinese/chinese_store.dart';
import '../../chinese/zh_bridge.dart';

void speakEnglish(String text) => speakChinese(text, lang: 'en-US', rate: 0.85);

/// Exercises of [t] answered right at least once.
int tenseDone(ChineseStore zh, Tense t) =>
    t.exercises.where((e) => zh.of(e.asWord).correct > 0).length;

/// Bài học một thì: công thức, cách dùng, dấu hiệu, lưu ý, rồi làm bài tập.
class TensePage extends StatelessWidget {
  const TensePage({super.key, required this.zh, required this.tense});

  final ChineseStore zh;
  final Tense tense;

  @override
  Widget build(BuildContext context) {
    final t = tense;
    return Scaffold(
      appBar: AppBar(title: Text(t.vi)),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            SoftCard(
              color: AppColors.blush,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.en, style: brandTitle(26)),
                  const SizedBox(height: 4),
                  Text(t.summary, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
            const _Heading('📐 Công thức'),
            for (final f in t.forms) ...[
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.label, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.blush.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(f.formula,
                          style: const TextStyle(
                              color: AppColors.pinkDeep, fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    _Example(en: f.example, vi: f.exampleVi),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const _Heading('🎯 Cách dùng'),
            for (final (i, u) in t.usage.indexed) ...[
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ${u.text}',
                        style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
                    const SizedBox(height: 6),
                    _Example(en: u.example, vi: u.exampleVi),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const _Heading('🔍 Dấu hiệu nhận biết'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in t.signals)
                  Chip(
                    label: Text(s, style: const TextStyle(fontWeight: FontWeight.w700)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                  ),
              ],
            ),
            const _Heading('💡 Lưu ý'),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final tip in t.tips)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• $tip', style: const TextStyle(height: 1.4)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: PageBody(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: ListenableBuilder(
              listenable: zh,
              builder: (context, _) => GradientButton(
                label: 'Làm bài tập (${tenseDone(zh, t)}/${t.exercises.length} câu đã đúng)',
                icon: Icons.edit_note_rounded,
                onPressed: () => openTenseQuiz(context, zh, t.vi, t.exercises),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      );
}

class _Example extends StatelessWidget {
  const _Example({required this.en, required this.vi});

  final String en, vi;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(en, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
                Text(vi, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Nghe',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.pink, size: 20),
            onPressed: () => speakEnglish(en),
          ),
        ],
      );
}

void openTenseQuiz(BuildContext context, ChineseStore zh, String title, List<TenseExercise> all,
    {int? count}) {
  // Not-yet-mastered first, then the rest; shuffled within each group.
  final todo = all.where((e) => zh.of(e.asWord).correct == 0).toList()..shuffle();
  final done = all.where((e) => zh.of(e.asWord).correct > 0).toList()..shuffle();
  final picked = [...todo, ...done].take(count ?? all.length).toList();
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => TenseQuizPage(zh: zh, title: title, exercises: picked),
  ));
}

/// Bài tập chia động từ: chọn đáp án, biết đúng/sai ngay kèm giải thích.
class TenseQuizPage extends StatefulWidget {
  const TenseQuizPage({super.key, required this.zh, required this.title, required this.exercises});

  final ChineseStore zh;
  final String title;
  final List<TenseExercise> exercises;

  @override
  State<TenseQuizPage> createState() => _TenseQuizPageState();
}

class _TenseQuizPageState extends State<TenseQuizPage> {
  final _chosen = <int, int>{};
  final _scroll = ScrollController();
  int _index = 0;

  TenseExercise get _e => widget.exercises[_index];
  int get _right => _chosen.entries.where((c) => widget.exercises[c.key].answer == c.value).length;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _choose(int i) {
    if (_chosen.containsKey(_index)) return;
    setState(() => _chosen[_index] = i);
    final ok = i == _e.answer;
    widget.zh.recordAnswer(_e.asWord, ok);
    speakEnglish(_e.question.replaceAll('___', _e.options[_e.answer]).replaceAll(RegExp(r'\s*\([^)]*\)'), ''));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _next() {
    if (_index < widget.exercises.length - 1) {
      setState(() => _index++);
      if (_scroll.hasClients) _scroll.jumpTo(0);
      return;
    }
    _finish();
  }

  Future<void> _finish() async {
    final wrong = [
      for (final c in _chosen.entries)
        if (widget.exercises[c.key].answer != c.value) widget.exercises[c.key],
    ];
    final again = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(wrong.isEmpty ? 'Đúng hết luôn! 🏆' : 'Hoàn thành 💕', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          PercentRing(
              value: _chosen.isEmpty ? 0 : _right / _chosen.length,
              size: 110,
              label: '$_right/${_chosen.length} câu'),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Xong')),
          if (wrong.isNotEmpty)
            GradientButton(
                label: 'Làm lại ${wrong.length} câu sai',
                expand: false,
                onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (!mounted) return;
    if (again == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => TenseQuizPage(zh: widget.zh, title: widget.title, exercises: wrong..shuffle()),
      ));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _e;
    final answered = _chosen.containsKey(_index);
    final chosen = _chosen[_index];
    final parts = e.question.split('___');
    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1}/${widget.exercises.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('✓ $_right',
                  style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_index + 1) / widget.exercises.length,
                minHeight: 6,
                color: AppColors.pink,
                backgroundColor: AppColors.blush,
              ),
            ),
          ),
        ),
      ),
      body: PageBody(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.title,
                style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            SoftCard(
              padding: const EdgeInsets.all(20),
              child: Text.rich(
                TextSpan(children: [
                  for (final (i, p) in parts.indexed) ...[
                    TextSpan(text: p),
                    if (i < parts.length - 1)
                      TextSpan(
                        text: answered ? ' ${e.options[e.answer]} ' : ' ______ ',
                        style: TextStyle(
                          color: answered ? AppColors.green : AppColors.pink,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                  ],
                ]),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            for (final (i, o) in e.options.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _Option(
                  letter: String.fromCharCode(65 + i),
                  text: o,
                  state: !answered
                      ? 0
                      : i == e.answer
                          ? 1
                          : i == chosen
                              ? 2
                              : 3,
                  onTap: () => _choose(i),
                ),
              ),
            if (answered)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (chosen == e.answer ? AppColors.green : AppColors.red).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: (chosen == e.answer ? AppColors.green : AppColors.red).withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chosen == e.answer
                          ? ['Chính xác! 🎉', 'Giỏi quá! 🥰', 'Đúng rồi nè 💯'][Random().nextInt(3)]
                          : 'Chưa đúng — đáp án là "${e.options[e.answer]}"',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: chosen == e.answer ? AppColors.green : AppColors.red,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(e.explain, style: const TextStyle(height: 1.45)),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: PageBody(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: GradientButton(
              label: _index == widget.exercises.length - 1 ? 'Xem kết quả' : 'Câu tiếp theo',
              trailingIcon: Icons.arrow_forward,
              onPressed: answered ? _next : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// state: 0 idle, 1 correct, 2 chosen wrong, 3 dimmed.
class _Option extends StatelessWidget {
  const _Option({required this.letter, required this.text, required this.state, required this.onTap});

  final String letter, text;
  final int state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (border, fill) = switch (state) {
      1 => (AppColors.green, const Color(0xFFEAF8F0)),
      2 => (AppColors.red, const Color(0xFFFFEEF1)),
      _ => (AppColors.border, Colors.white),
    };
    final highlighted = state == 1 || state == 2;
    return Opacity(
      opacity: state == 3 ? 0.55 : 1,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border, width: highlighted ? 2 : 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: state == 0 ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: highlighted ? border : AppColors.blush,
                  child: Text(letter,
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: highlighted ? Colors.white : AppColors.pink)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                if (state == 1) const Icon(Icons.check_circle, color: AppColors.green),
                if (state == 2) const Icon(Icons.cancel, color: AppColors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
