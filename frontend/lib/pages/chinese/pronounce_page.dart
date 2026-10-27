import 'dart:math';

import 'package:flutter/material.dart';

import '../../chinese/chinese_store.dart';
import '../../chinese/pronunciation.dart';
import '../../pwa.dart';
import '../../chinese/tones.dart';
import 'package:study_shared/vocab.dart';
import '../../chinese/zh_bridge.dart';
import 'package:study_shared/theme.dart';

void openPronounce(BuildContext context, ChineseStore zh, List<VocabWord> words) {
  if (words.isEmpty) return;
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PronouncePage(zh: zh, words: words)));
}

/// Luyện phát âm: read the word aloud, the browser's speech recognizer checks it.
class PronouncePage extends StatefulWidget {
  const PronouncePage({super.key, required this.zh, required this.words});

  final ChineseStore zh;
  final List<VocabWord> words;

  @override
  State<PronouncePage> createState() => _PronouncePageState();
}

class _PronouncePageState extends State<PronouncePage> with SingleTickerProviderStateMixin {
  late final _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final Map<String, String> _charPinyin = {
    for (final e in widget.zh.dictionary.entries)
      if (e.key.length == 1) e.key: e.value,
  };
  int _index = 0;
  int _right = 0;
  bool _listening = false;
  PronunciationResult? _result;
  String? _heard;
  String? _error;

  // "Ghi âm & nghe lại"
  bool _recording = false;
  double _level = 0;
  VoiceRecording? _take;

  VocabWord get _w => widget.words[_index];

  @override
  void dispose() {
    stopListeningChinese();
    cancelRecording();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (_listening) {
      stopListeningChinese();
      return;
    }
    setState(() {
      _listening = true;
      _result = null;
      _heard = null;
      _error = null;
    });
    _pulse.repeat(reverse: true);
    try {
      // The page script settles within 8 s; this guards against a browser that
      // never calls back at all.
      final guesses = await listenChinese().timeout(const Duration(seconds: 12), onTimeout: () {
        stopListeningChinese();
        throw 'no-speech';
      });
      final result = judgePronunciation(_w.hanzi, guesses, _charPinyin);
      widget.zh.store.bumpActivity();
      if (!mounted) return;
      setState(() {
        _result = result;
        _heard = guesses.first;
        if (result != PronunciationResult.wrong) _right++;
      });
    } catch (code) {
      if (!mounted) return;
      setState(() => _error = switch (code) {
            'not-allowed' || 'service-not-allowed' =>
              'Chưa cho phép dùng micro. Bấm biểu tượng 🔒 trên thanh địa chỉ → cho phép Micro.',
            'no-speech' => Pwa.platform == 'ios' && Pwa.isStandalone
                ? 'Chưa nghe thấy gì. Trên iPhone, app mở từ màn hình chính đôi khi không dùng '
                    'được nhận giọng nói — thử mở dienham.netlify.app bằng Safari nhé.'
                : 'Chưa nghe thấy gì, bấm mic rồi đọc to hơn chút nhé.',
            'network' => 'Nhận giọng nói cần có mạng, kiểm tra kết nối nhé.',
            'unsupported' => 'Trình duyệt này chưa hỗ trợ nhận giọng nói.',
            'aborted' => null,
            _ => 'Không nghe được ($code), thử lại nhé.',
          });
    } finally {
      _pulse.stop();
      _pulse.value = 0;
      if (mounted) setState(() => _listening = false);
    }
  }

  Future<void> _record() async {
    if (_recording) {
      stopRecording();
      return;
    }
    stopListeningChinese();
    setState(() {
      _recording = true;
      _take = null;
      _error = null;
      _level = 0;
    });
    try {
      final take = await recordVoice(onLevel: (v) {
        // Redraw only on visible changes to keep slower phones smooth.
        if (mounted && (v - _level).abs() > 0.06) setState(() => _level = v);
      });
      widget.zh.store.bumpActivity();
      if (!mounted) return;
      setState(() => _take = take);
      playRecording(take.url);
    } catch (code) {
      if (!mounted) return;
      setState(() => _error = switch (code) {
            'not-allowed' => 'Chưa cho phép dùng micro. Bấm 🔒 trên thanh địa chỉ → cho phép Micro.',
            'no-speech' => 'Không nghe thấy giọng, thử đọc to hơn nhé.',
            'unsupported' => 'Trình duyệt này chưa hỗ trợ ghi âm.',
            _ => 'Không ghi âm được ($code).',
          });
    } finally {
      if (mounted) setState(() => _recording = false);
    }
  }

  void _next() {
    if (_index == widget.words.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    cancelRecording();
    setState(() {
      _index++;
      _result = null;
      _heard = null;
      _error = null;
      _take = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final supported = canListenChinese;
    return Scaffold(
      appBar: AppBar(
        title: Text('Phát âm · ${_index + 1}/${widget.words.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('✓ $_right',
                  style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
              child: Column(
                children: [
                  Text(_w.hanzi, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w500)),
                  Text(_w.pinyin,
                      style: const TextStyle(
                          color: AppColors.pink, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(_w.meaning, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => speakChinese(_w.hanzi, rate: 0.7),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Nghe mẫu'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (!supported)
              const Text(
                'Trình duyệt này chưa hỗ trợ nhận giọng nói.\n'
                'Hãy mở bằng Chrome (Android/máy tính) hoặc Safari (iPhone).',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.red),
              )
            else ...[
              Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) => Container(
                    padding: EdgeInsets.all(10 + 14 * _pulse.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pink.withValues(alpha: 0.12 + 0.1 * _pulse.value),
                    ),
                    child: child,
                  ),
                  child: Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: Ink(
                      decoration: const BoxDecoration(gradient: AppColors.gradient),
                      child: InkWell(
                        onTap: _listen,
                        child: SizedBox(
                          width: 92,
                          height: 92,
                          child: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded,
                              color: Colors.white, size: 44),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(_listening ? 'Đang nghe... đọc to từ này nhé' : 'Bấm mic để chấm phát âm',
                  textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            ],
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _recording ? AppColors.blush : Colors.white,
                ),
                onPressed: _listening ? null : _record,
                icon: Icon(_recording ? Icons.stop_circle_outlined : Icons.fiber_manual_record,
                    color: AppColors.red),
                label: Text(_recording ? 'Dừng ghi âm' : 'Ghi âm & nghe lại giọng em'),
              ),
            ),
            if (_recording) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _level,
                    minHeight: 8,
                    color: AppColors.red,
                    backgroundColor: AppColors.blush,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Đang ghi... tự dừng khi em nói xong',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.red)),
            if (_result != null) _resultCard(),
            if (_take != null) ...[
              const SizedBox(height: 12),
              _ToneCard(take: _take!, word: _w),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: PageBody(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: GradientButton(
              label: _index == widget.words.length - 1 ? 'Xong' : 'Từ tiếp theo',
              trailingIcon: Icons.arrow_forward,
              onPressed: _next,
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultCard() {
    final (color, icon, title) = switch (_result!) {
      PronunciationResult.correct => (AppColors.green, Icons.check_circle, 'Chuẩn rồi! 🎉'),
      PronunciationResult.homophone =>
        (AppColors.green, Icons.check_circle_outline, 'Đúng âm rồi! (máy nghe ra chữ đồng âm)'),
      PronunciationResult.wrong => (AppColors.red, Icons.cancel, 'Chưa đúng, thử lại nhé 💪'),
    };
    return SoftCard(
      borderColor: color.withValues(alpha: 0.5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
                if (_heard != null)
                  Text('Máy nghe được: $_heard', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Recorded attempt: replay buttons and the pitch curve against the expected tone.
class _ToneCard extends StatelessWidget {
  const _ToneCard({required this.take, required this.word});

  final VoiceRecording take;
  final VocabWord word;

  @override
  Widget build(BuildContext context) {
    final tones = pinyinTones(word.pinyin);
    final single = word.hanzi.characters.length == 1 && tones.length == 1 && tones.first != 5;
    final expected = single ? tones.first : null;
    final heard = single ? classifyTone(take.pitch) : null;
    final contour = pitchContour(take.pitch);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Giọng của em', style: TextStyle(fontWeight: FontWeight.w900)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => playRecording(take.url),
                icon: const Icon(Icons.play_arrow_rounded, color: AppColors.pink),
                label: const Text('Nghe lại', style: TextStyle(color: AppColors.pink)),
              ),
              TextButton.icon(
                onPressed: () => speakChinese(word.hanzi, rate: 0.7),
                icon: const Icon(Icons.volume_up_rounded, color: AppColors.muted),
                label: const Text('Mẫu', style: TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: contour.isEmpty
                ? const Center(
                    child: Text('Không đo được cao độ, thử nói rõ và to hơn nhé',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  )
                : CustomPaint(painter: _ContourPainter(contour, expected)),
          ),
          const SizedBox(height: 6),
          if (single) ...[
            Row(
              children: [
                Icon(
                  heard == expected ? Icons.check_circle : Icons.info_outline,
                  color: heard == expected ? AppColors.green : AppColors.pink,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    heard == null
                        ? 'Chuẩn: ${toneNames[expected]}'
                        : heard == expected
                            ? 'Đúng ${toneNames[expected]}! 🎉'
                            : 'Nghe giống ${toneNames[heard]}, chuẩn là ${toneNames[expected]}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: heard == expected ? AppColors.green : AppColors.text),
                  ),
                ),
              ],
            ),
            if (heard != expected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(toneTips[expected]!,
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ),
          ] else
            Text(
                'Thanh điệu chuẩn: ${tones.map((t) => t == 5 ? 'nhẹ' : '$t').join(' – ')}  (${word.pinyin})',
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 2),
          const Text('Đường hồng là cao độ giọng em, đường xám là dáng thanh chuẩn (ước lượng).',
              style: TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ContourPainter extends CustomPainter {
  _ContourPainter(this.contour, this.tone);

  /// Semitones around the speaker's median.
  final List<double> contour;
  final int? tone;

  static const _range = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    double y(double st) =>
        size.height / 2 - (st.clamp(-_range, _range) / _range) * (size.height / 2 - 6);
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (final st in [-5.0, 0.0, 5.0]) {
      canvas.drawLine(Offset(0, y(st)), Offset(size.width, y(st)), grid);
    }

    // Expected tone shape (tone letters 55 / 35 / 214 / 51 centred on 0).
    final shape = switch (tone) {
      1 => [3.0, 3.0],
      2 => [-1.0, 4.0],
      3 => [-1.5, -5.0, -2.0],
      4 => [5.0, -4.0],
      _ => <double>[],
    };
    if (shape.isNotEmpty) {
      final ref = Path();
      for (var i = 0; i <= 40; i++) {
        final t = i / 40 * (shape.length - 1);
        final k = min(t.floor(), shape.length - 2);
        final v = shape[k] + (shape[k + 1] - shape[k]) * (t - k);
        final p = Offset(size.width * i / 40, y(v));
        i == 0 ? ref.moveTo(p.dx, p.dy) : ref.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
          ref,
          Paint()
            ..color = AppColors.muted.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round);
    }

    final line = Path();
    for (var i = 0; i < contour.length; i++) {
      final p = Offset(size.width * i / max(1, contour.length - 1), y(contour[i]));
      i == 0 ? line.moveTo(p.dx, p.dy) : line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        line,
        Paint()
          ..color = AppColors.pink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_ContourPainter old) => old.contour != contour || old.tone != tone;
}
