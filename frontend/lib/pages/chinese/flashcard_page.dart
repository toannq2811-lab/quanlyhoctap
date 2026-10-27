import 'dart:math';

import 'package:flutter/material.dart';

import '../../chinese/chinese_store.dart';
import 'package:study_shared/vocab.dart';
import '../../chinese/zh_bridge.dart';
import 'package:study_shared/theme.dart';
import 'pronounce_page.dart';

void openFlashcards(BuildContext context, ChineseStore zh, String title, List<VocabWord> words) {
  if (words.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Không có từ nào để học')));
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => FlashcardPage(zh: zh, title: title, words: words),
  ));
}

/// Flip cards: hanzi on the front, pinyin + meaning on the back.
class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key, required this.zh, required this.title, required this.words});

  final ChineseStore zh;
  final String title;
  final List<VocabWord> words;

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> with SingleTickerProviderStateMixin {
  late final _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  int _index = 0;
  final _knownNow = <VocabWord>[];
  final _unknownNow = <VocabWord>[];

  VocabWord get _word => widget.words[_index];

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_flip.isAnimating) return;
    if (_flip.value < 0.5) {
      _flip.forward();
      speakChinese(_word.hanzi);
    } else {
      _flip.reverse();
    }
  }

  Future<void> _answer(bool known) async {
    (known ? _knownNow : _unknownNow).add(_word);
    widget.zh.setKnown(_word, known);
    if (_index == widget.words.length - 1) {
      _finish();
      return;
    }
    _flip.value = 0;
    setState(() => _index++);
  }

  Future<void> _finish() async {
    final again = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_unknownNow.isEmpty ? 'Thuộc hết rồi! 🎉' : 'Xong một lượt 💕',
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(size: 100),
            const SizedBox(height: 8),
            Text('Đã thuộc ${_knownNow.length} · Chưa thuộc ${_unknownNow.length}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Xong')),
          if (_unknownNow.isNotEmpty)
            GradientButton(
              label: 'Học lại ${_unknownNow.length} từ',
              expand: false,
              onPressed: () => Navigator.pop(ctx, true),
            ),
        ],
      ),
    );
    if (!mounted) return;
    if (again == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => FlashcardPage(
            zh: widget.zh, title: widget.title, words: [..._unknownNow]..shuffle()),
      ));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1}/${widget.words.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_index + 1) / widget.words.length,
                minHeight: 6,
                color: AppColors.pink,
                backgroundColor: AppColors.blush,
              ),
            ),
          ),
        ),
      ),
      body: PageBody(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggle,
                  child: AnimatedBuilder(
                    animation: _flip,
                    builder: (context, _) {
                      final angle = _flip.value * pi;
                      final back = angle > pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(angle),
                        child: back
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _back(),
                              )
                            : _front(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.red,
                        side: BorderSide(color: AppColors.red.withValues(alpha: 0.5)),
                      ),
                      onPressed: () => _answer(false),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Chưa thuộc'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Đã thuộc',
                      icon: Icons.check_rounded,
                      onPressed: () => _answer(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardShell({required Widget child, Color color = Colors.white}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10)),
          ],
        ),
        child: child,
      );

  Widget _front() => _cardShell(
        child: Stack(
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_word.hanzi,
                      style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            if (widget.zh.of(_word).known)
              const Positioned(
                top: 16,
                left: 16,
                child: Icon(Icons.check_circle, color: AppColors.green),
              ),
            const Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Text('Chạm để lật thẻ',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      );

  Widget _back() => _cardShell(
        color: const Color(0xFFFFF7FA),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_word.hanzi, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(_word.pinyin,
                  style: const TextStyle(
                      fontSize: 24, color: AppColors.pink, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(_word.meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Nghe lại',
                    onPressed: () => speakChinese(_word.hanzi),
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.pink),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: 'Luyện phát âm',
                    onPressed: () => openPronounce(context, widget.zh, [_word]),
                    icon: const Icon(Icons.mic_rounded, color: AppColors.pink),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
