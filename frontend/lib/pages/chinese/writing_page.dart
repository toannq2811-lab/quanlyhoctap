import 'dart:math';

import 'package:flutter/material.dart';

import '../../chinese/chinese_store.dart';
import 'package:study_shared/vocab.dart';
import '../../chinese/zh_bridge.dart';
import 'package:study_shared/theme.dart';

void openWriting(BuildContext context, ChineseStore zh, List<VocabWord> words) {
  if (words.isEmpty) return;
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => WritingPage(zh: zh, words: words)));
}

/// Tập viết: watch the stroke order, then write each character by hand.
class WritingPage extends StatefulWidget {
  const WritingPage({super.key, required this.zh, required this.words});

  final ChineseStore zh;
  final List<VocabWord> words;

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final _pad = HanziPadController();
  int _word = 0;
  int _char = 0;
  bool _outline = true;
  String? _feedback;
  bool _writing = false;

  VocabWord get _w => widget.words[_word];
  List<String> get _chars => _w.hanzi.characters.toList();

  void _quiz() {
    setState(() {
      _writing = true;
      _feedback = 'Viết từng nét lên ô nhé ✍️';
    });
    _pad.quiz(
      outline: _outline,
      onDone: (mistakes) {
        widget.zh.store.bumpActivity();
        if (!mounted) return;
        setState(() {
          _writing = false;
          _feedback = mistakes == 0
              ? 'Tuyệt vời! Không sai nét nào 🎉'
              : 'Xong rồi! Sai $mistakes nét, viết lại cho nhớ nhé 💪';
        });
      },
    );
  }

  void _go(int word, int char) {
    setState(() {
      _word = word;
      _char = char;
      _feedback = null;
      _writing = false;
    });
  }

  void _next() {
    if (_char < _chars.length - 1) {
      _go(_word, _char + 1);
    } else if (_word < widget.words.length - 1) {
      _go(_word + 1, 0);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _word == widget.words.length - 1 && _char == _chars.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text('Tập viết · ${_word + 1}/${widget.words.length}')),
      body: PageBody(
        child: LayoutBuilder(
          builder: (context, c) {
            final size = min(c.maxWidth - 40, 340.0);
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_w.hanzi, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: AppColors.pink),
                      onPressed: () => speakChinese(_w.hanzi),
                    ),
                  ],
                ),
                Text('${_w.pinyin} · ${_w.meaning}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (_chars.length > 1)
                  Center(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final (i, ch) in _chars.indexed)
                          ChoiceChip(
                            label: Text(ch, style: const TextStyle(fontSize: 18)),
                            selected: i == _char,
                            showCheckmark: false,
                            selectedColor: AppColors.blush,
                            onSelected: (_) => _go(_word, i),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.pink.withValues(alpha: 0.12), blurRadius: 18),
                      ],
                    ),
                    child: HanziPad(
                      char: _chars[_char],
                      size: size,
                      controller: _pad,
                      outline: _outline,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 24,
                  child: Text(_feedback ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w800)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: _outline,
                      activeTrackColor: AppColors.pink,
                      onChanged: _writing ? null : (v) => setState(() => _outline = v),
                    ),
                    const Text('Hiện nét mờ để tô theo', style: TextStyle(color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: () {
                          setState(() {
                            _writing = false;
                            _feedback = null;
                          });
                          _pad.animate();
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Xem cách viết'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(label: 'Tập viết', icon: Icons.draw_rounded, onPressed: _quiz),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _next,
                  icon: Icon(last ? Icons.check : Icons.arrow_forward, color: AppColors.pink),
                  label: Text(last ? 'Xong' : (_char < _chars.length - 1 ? 'Chữ tiếp theo' : 'Từ tiếp theo'),
                      style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
