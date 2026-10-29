import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:study_shared/api.dart';
import 'package:study_shared/models.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'deck_page.dart';
import 'session_result_page.dart';

const _praise = ['Chính xác rồi! 🎉', 'Giỏi quá! 🥰', 'Đúng rồi nè 💯', 'Xuất sắc! ✨', 'Quá đỉnh! 💕'];
const _cheer = ['Cố lên nha 💪', 'Nhớ câu này nhé 😘', 'Lần sau sẽ đúng thôi 🌸'];

void startQuiz(BuildContext context, Store store, String title, List<Question> qs,
    {int startAt = 0}) {
  if (qs.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Không có câu nào trong mục này')));
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => QuizPage(store: store, title: title, questions: qs, startAt: startAt),
  ));
}

/// Asks how many questions, then starts a shuffled quiz from [all].
Future<void> pickRandomQuiz(
    BuildContext context, Store store, String title, List<Question> all) async {
  final counts = {10, 20, 30, 50, all.length}.where((c) => c <= all.length).toList()..sort();
  final n = await showDialog<int>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Bao nhiêu câu?'),
      children: [
        for (final c in counts)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, c),
            child: Text(c == all.length ? 'Tất cả ($c câu)' : '$c câu',
                style: const TextStyle(fontSize: 16)),
          ),
      ],
    ),
  );
  if (n == null || !context.mounted) return;
  startQuiz(context, store, '$title · thi thử', ([...all]..shuffle()).take(n).toList());
}

/// 6–7. Làm bài trắc nghiệm, with instant right/wrong feedback.
class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.store,
    required this.title,
    required this.questions,
    this.startAt = 0,
  });

  final Store store;
  final String title;
  final List<Question> questions;
  final int startAt;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _chosen = <int, int>{}; // question index -> chosen option
  final _messages = <int, String>{};
  final _ai = <int, Future<String>>{}; // question index -> AI explanation of the wrong pick
  final _random = Random();
  final _scroll = ScrollController();
  final _stopwatch = Stopwatch()..start();
  final _elapsed = ValueNotifier(Duration.zero);
  late final Timer _ticker;
  late int _index = widget.startAt;

  List<Question> get _qs => widget.questions;
  Question get _q => _qs[_index];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
        const Duration(seconds: 1), (_) => _elapsed.value = _stopwatch.elapsed);
  }

  @override
  void dispose() {
    _ticker.cancel();
    _elapsed.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _choose(int option) {
    if (_chosen.containsKey(_index) || option >= _q.options.length) return;
    final answer = _q.answer;
    setState(() {
      _chosen[_index] = option;
      if (answer != null) {
        final pool = option == answer ? _praise : _cheer;
        _messages[_index] = pool[_random.nextInt(pool.length)];
      }
    });
    if (answer != null) widget.store.record(_q, option == answer);
    if (answer != null && option != answer) _ai[_index] = widget.store.explainWrong(_q, option);
    // Bring the feedback card into view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _go(int index) {
    if (index < 0) return;
    if (index >= _qs.length) {
      _finish();
      return;
    }
    setState(() => _index = index);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _finish() {
    _stopwatch.stop();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => SessionResultPage(
        store: widget.store,
        title: widget.title,
        questions: _qs,
        chosen: _chosen,
        elapsed: _stopwatch.elapsed,
      ),
    ));
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    const letters = [LogicalKeyboardKey.keyA, LogicalKeyboardKey.keyB, LogicalKeyboardKey.keyC,
      LogicalKeyboardKey.keyD, LogicalKeyboardKey.keyE, LogicalKeyboardKey.keyF];
    const digits = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4, LogicalKeyboardKey.digit5, LogicalKeyboardKey.digit6];
    if (letters.contains(k)) {
      _choose(letters.indexOf(k));
    } else if (digits.contains(k)) {
      _choose(digits.indexOf(k));
    } else if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.enter) {
      _go(_index + 1);
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _go(_index - 1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final answered = _chosen.containsKey(_index);
    final last = _index == _qs.length - 1;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: _showNavigator,
            child: Text('${_index + 1}/${_qs.length}'),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.pink),
                const SizedBox(width: 4),
                ValueListenableBuilder(
                  valueListenable: _elapsed,
                  builder: (_, d, _) => Text(formatDuration(d),
                      style: const TextStyle(
                          color: AppColors.pink, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ]),
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
          maxWidth: 640,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${shortSectionName(widget.store.sectionOf(_q))} · Câu ${_q.number}',
                    style: const TextStyle(
                        color: AppColors.pink, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(_q.text,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.4)),
              const SizedBox(height: 18),
              for (final (i, option) in _q.options.indexed)
                _OptionTile(
                  letter: String.fromCharCode(65 + i),
                  text: option,
                  state: _optionState(i),
                  onTap: () => _choose(i),
                ),
              if (answered) _feedback(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: PageBody(
            maxWidth: 640,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _index == 0 ? null : () => _go(_index - 1),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Trước'),
                    style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: last ? 'Xem kết quả' : (answered ? 'Câu tiếp theo' : 'Tiếp theo'),
                      trailingIcon: last ? Icons.flag_rounded : Icons.arrow_forward,
                      onPressed: () => _go(_index + 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _OptionState _optionState(int i) {
    final chosen = _chosen[_index];
    if (chosen == null) return _OptionState.idle;
    final answer = _q.answer;
    if (i == answer) return _OptionState.correct;
    if (i == chosen) return answer == null ? _OptionState.picked : _OptionState.wrong;
    return _OptionState.dimmed;
  }

  Widget _feedback() {
    final answer = _q.answer;
    final chosen = _chosen[_index]!;
    final ok = answer != null && chosen == answer;
    final String title;
    final Color color;
    if (answer == null) {
      title = 'Tài liệu không có đáp án cho câu này';
      color = AppColors.muted;
    } else if (ok) {
      title = _messages[_index]!;
      color = AppColors.green;
    } else {
      title = 'Chưa chính xác rồi!';
      color = AppColors.red;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SoftCard(
        borderColor: color.withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Mascot(size: 64),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (answer != null)
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: color,
                            child: Icon(ok ? Icons.check : Icons.close,
                                size: 15, color: Colors.white),
                          ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(title,
                              style: TextStyle(
                                  color: color, fontSize: 17, fontWeight: FontWeight.w900)),
                        ),
                      ]),
                      if (answer != null) ...[
                        const SizedBox(height: 4),
                        Text.rich(TextSpan(children: [
                          const TextSpan(text: 'Đáp án đúng là: '),
                          TextSpan(
                            text: '${String.fromCharCode(65 + answer)}. ${_q.options[answer]}',
                            style: const TextStyle(
                                color: AppColors.green, fontWeight: FontWeight.w800),
                          ),
                        ])),
                      ],
                      if (answer != null && !ok)
                        Text(_messages[_index]!,
                            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (_ai[_index] case final future?) ...[
              const SizedBox(height: 12),
              _AiExplanation(
                future: future,
                onRetry: () => setState(
                    () => _ai[_index] = widget.store.explainWrong(_q, chosen)),
              ),
            ],
            if (_q.explanation != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blush.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giải thích',
                        style: TextStyle(color: AppColors.pink, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(_q.explanation!, style: const TextStyle(height: 1.45)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNavigator() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.55,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 52,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _qs.length,
            itemBuilder: (_, i) {
              final chosen = _chosen[i];
              final answer = _qs[i].answer;
              final Color? bg = chosen == null
                  ? null
                  : answer == null
                      ? AppColors.muted
                      : chosen == answer
                          ? AppColors.green
                          : AppColors.red;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.pop(ctx);
                  _go(i);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bg ?? AppColors.blush.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: i == _index ? Border.all(color: AppColors.pink, width: 2.5) : null,
                  ),
                  child: Text('${i + 1}',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: bg == null ? AppColors.text : Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

String formatDuration(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = two(d.inMinutes % 60), s = two(d.inSeconds % 60);
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// "🤖 AI giải thích": why the picked option is wrong, loaded as soon as it is picked.
class _AiExplanation extends StatelessWidget {
  const _AiExplanation({required this.future, required this.onRetry});

  final Future<String> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9CCFF)),
      ),
      child: FutureBuilder(
        future: future,
        builder: (_, snap) {
          const title = Text('🤖 AI giải thích',
              style: TextStyle(color: Color(0xFF7A5AF8), fontWeight: FontWeight.w900));
          final Widget body;
          if (snap.hasData) {
            body = Text(snap.data!, style: const TextStyle(height: 1.45));
          } else if (snap.hasError) {
            final e = snap.error;
            body = Row(children: [
              Expanded(
                child: Text(
                  e is ApiException && !e.offline ? e.message : 'Chưa kết nối được AI',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Thử lại')),
            ]);
          } else {
            body = const Row(children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7A5AF8))),
              SizedBox(width: 10),
              Text('AI đang giải thích vì sao sai…', style: TextStyle(color: AppColors.muted)),
            ]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 6), body],
          );
        },
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong, picked, dimmed }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color fill, String? tag) = switch (state) {
      _OptionState.correct => (AppColors.green, const Color(0xFFEAF8F0), 'Đáp án đúng'),
      _OptionState.wrong => (AppColors.red, const Color(0xFFFFEEF1), 'Bạn đã chọn'),
      _OptionState.picked => (AppColors.pink, AppColors.blush, 'Bạn đã chọn'),
      _ => (AppColors.border, Colors.white, null),
    };
    final highlighted = border != AppColors.border;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: state == _OptionState.dimmed ? 0.6 : 1,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: border, width: highlighted ? 1.8 : 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: state == _OptionState.idle ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: highlighted ? border : AppColors.blush,
                    ),
                    child: Text(letter,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: highlighted ? Colors.white : AppColors.pink)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text,
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500)),
                  ),
                  if (tag != null) ...[
                    const SizedBox(width: 8),
                    Text(tag,
                        style: TextStyle(color: border, fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Icon(state == _OptionState.correct ? Icons.check_circle : Icons.cancel,
                        color: border, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
