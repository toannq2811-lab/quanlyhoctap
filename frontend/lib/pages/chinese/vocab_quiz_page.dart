import 'dart:math';

import 'package:flutter/material.dart';

import '../../chinese/chinese_store.dart';
import 'package:study_shared/vocab.dart';
import '../../chinese/zh_bridge.dart';
import 'package:study_shared/theme.dart';
import 'chinese_tab.dart';

enum VocabQuizMode { hanziToMeaning, meaningToHanzi, listen }

/// Asks for the quiz type and length, then starts the quiz.
Future<void> startVocabQuiz(
  BuildContext context,
  ChineseStore zh,
  String title,
  List<VocabWord> words,
) async {
  if (words.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cần ít nhất 2 từ để làm trắc nghiệm')),
    );
    return;
  }
  var mode = VocabQuizMode.hanziToMeaning;
  var count = min(20, words.length);
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Trắc nghiệm từ vựng',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              RadioGroup<VocabQuizMode>(
                groupValue: mode,
                onChanged: (v) => set(() => mode = v!),
                child: Column(
                  children: [
                    for (final (m, icon, label) in [
                      (
                        VocabQuizMode.hanziToMeaning,
                        Icons.translate,
                        words.first.isEnglish ? 'Nhìn từ → chọn nghĩa' : 'Nhìn chữ Hán → chọn nghĩa',
                      ),
                      (
                        VocabQuizMode.meaningToHanzi,
                        Icons.text_fields,
                        words.first.isEnglish ? 'Nhìn nghĩa → chọn từ' : 'Nhìn nghĩa → chọn chữ Hán',
                      ),
                      (
                        VocabQuizMode.listen,
                        Icons.hearing,
                        words.first.isEnglish ? 'Nghe → chọn từ' : 'Nghe → chọn chữ Hán',
                      ),
                    ])
                      RadioListTile<VocabQuizMode>(
                        value: m,
                        activeColor: AppColors.pink,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Icon(icon, size: 20, color: AppColors.pink),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in {
                    10,
                    20,
                    30,
                    words.length,
                  }.where((c) => c <= words.length).toList()..sort())
                    ChoiceChip(
                      label: Text(c == words.length ? 'Tất cả ($c)' : '$c câu'),
                      selected: count == c,
                      showCheckmark: false,
                      selectedColor: AppColors.blush,
                      onSelected: (_) => set(() => count = c),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              GradientButton(
                label: 'Bắt đầu',
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  final picked = studyOrder(zh, words).take(count).toList()..shuffle();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => VocabQuizPage(
        zh: zh,
        title: title,
        words: picked,
        pool: words,
        mode: mode,
      ),
    ),
  );
}

class _Q {
  _Q(this.word, this.options, this.answer);

  final VocabWord word;
  final List<VocabWord> options;
  final int answer;
}

class VocabQuizPage extends StatefulWidget {
  const VocabQuizPage({
    super.key,
    required this.zh,
    required this.title,
    required this.words,
    required this.pool,
    required this.mode,
  });

  final ChineseStore zh;
  final String title;
  final List<VocabWord> words;

  /// Words the wrong options are drawn from.
  final List<VocabWord> pool;
  final VocabQuizMode mode;

  @override
  State<VocabQuizPage> createState() => _VocabQuizPageState();
}

class _VocabQuizPageState extends State<VocabQuizPage> {
  final _random = Random();
  late final List<_Q> _qs = [for (final w in widget.words) _make(w)];
  final _chosen = <int, int>{};
  int _index = 0;

  _Q get _q => _qs[_index];
  int get _right =>
      _chosen.entries.where((e) => _qs[e.key].answer == e.value).length;

  @override
  void initState() {
    super.initState();
    if (widget.mode == VocabQuizMode.listen) _speakCurrent();
  }

  _Q _make(VocabWord w) {
    final pool = widget.pool.length >= 4 ? widget.pool : widget.zh.allWords;
    final others =
        pool.where((o) => o.hanzi != w.hanzi && o.meaning != w.meaning).toList()
          ..shuffle(_random);
    final options = [w, ...others.take(3)]..shuffle(_random);
    return _Q(w, options, options.indexOf(w));
  }

  void _speakCurrent() => WidgetsBinding.instance.addPostFrameCallback(
    (_) => speakChinese(_q.word.hanzi, lang: _q.word.speechLang),
  );

  void _choose(int i) {
    if (_chosen.containsKey(_index)) return;
    setState(() => _chosen[_index] = i);
    final ok = i == _q.answer;
    widget.zh.recordAnswer(_q.word, ok);
    if (widget.mode != VocabQuizMode.listen) {
      speakChinese(_q.word.hanzi, lang: _q.word.speechLang);
    }
  }

  void _next() {
    if (_index == _qs.length - 1) {
      _finish();
      return;
    }
    setState(() => _index++);
    if (widget.mode == VocabQuizMode.listen) _speakCurrent();
  }

  Future<void> _finish() async {
    final wrong = [
      for (final e in _chosen.entries)
        if (_qs[e.key].answer != e.value) _qs[e.key].word,
    ];
    final again = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          wrong.isEmpty ? 'Đúng hết luôn! 🏆' : 'Hoàn thành 💕',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PercentRing(
              value: _chosen.isEmpty ? 0 : _right / _chosen.length,
              size: 110,
              label: '$_right/${_chosen.length} câu',
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Xong'),
          ),
          if (wrong.isNotEmpty)
            GradientButton(
              label: 'Làm lại ${wrong.length} câu sai',
              expand: false,
              onPressed: () => Navigator.pop(ctx, true),
            ),
        ],
      ),
    );
    if (!mounted) return;
    if (again == true) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VocabQuizPage(
            zh: widget.zh,
            title: widget.title,
            words: wrong..shuffle(),
            pool: widget.pool,
            mode: widget.mode,
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  String _optionText(VocabWord w) =>
      widget.mode == VocabQuizMode.hanziToMeaning ? w.meaning : w.hanzi;

  @override
  Widget build(BuildContext context) {
    final answered = _chosen.containsKey(_index);
    final w = _q.word;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1}/${_qs.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '✓ $_right',
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
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
                value: (_index + 1) / _qs.length,
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
          padding: const EdgeInsets.all(20),
          children: [
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                children: [
                  switch (widget.mode) {
                    VocabQuizMode.hanziToMeaning => FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        w.hanzi,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    VocabQuizMode.meaningToHanzi => Text(
                      w.meaning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    VocabQuizMode.listen => IconButton.filled(
                      iconSize: 48,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.pink,
                      ),
                      onPressed: () => speakChinese(w.hanzi, lang: w.speechLang),
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                      ),
                    ),
                  },
                  const SizedBox(height: 8),
                  Text(
                    answered
                        ? '${w.hanzi} · ${w.pinyin}'
                        : widget.mode == VocabQuizMode.listen
                        ? 'Bấm để nghe lại'
                        : ' ',
                    style: const TextStyle(
                      color: AppColors.pink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final (i, o) in _q.options.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _Option(
                  text: _optionText(o),
                  big: widget.mode != VocabQuizMode.hanziToMeaning,
                  state: !answered
                      ? 0
                      : i == _q.answer
                      ? 1
                      : i == _chosen[_index]
                      ? 2
                      : 3,
                  onTap: () => _choose(i),
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
              label: _index == _qs.length - 1 ? 'Xem kết quả' : 'Câu tiếp theo',
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
  const _Option({
    required this.text,
    required this.big,
    required this.state,
    required this.onTap,
  });

  final String text;
  final bool big;
  final int state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (border, fill) = switch (state) {
      1 => (AppColors.green, const Color(0xFFEAF8F0)),
      2 => (AppColors.red, const Color(0xFFFFEEF1)),
      _ => (AppColors.border, Colors.white),
    };
    return Opacity(
      opacity: state == 3 ? 0.55 : 1,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: border,
            width: state == 1 || state == 2 ? 2 : 1.2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: state == 0 ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    textAlign: big ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                      fontSize: big ? 28 : 16,
                      fontWeight: big ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                ),
                if (state == 1)
                  const Icon(Icons.check_circle, color: AppColors.green),
                if (state == 2) const Icon(Icons.cancel, color: AppColors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
