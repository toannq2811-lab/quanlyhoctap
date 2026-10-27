import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

@JS('zh.speak')
external bool _speak(String text, num rate);

@JS('zh.mount')
external void _mount(String id, web.HTMLElement el, String char, num size, bool outline);

@JS('zh.setChar')
external void _setChar(String id, String char);

@JS('zh.animate')
external void _animate(String id);

@JS('zh.quiz')
external void _quiz(String id, bool outline, JSFunction onDone);

@JS('zh.dispose')
external void _dispose(String id);

@JS('zh.canListen')
external bool _canListen();

@JS('zh.listen')
external void _listen(JSFunction onResult, JSFunction onError);

@JS('zh.stopListening')
external void _stopListening();

bool get canListenChinese {
  try {
    return _canListen();
  } catch (_) {
    return false;
  }
}

/// Listens once for Mandarin speech. Returns the recognizer's guesses, or
/// throws the browser's error code ("not-allowed", "no-speech", ...).
Future<List<String>> listenChinese() {
  final done = Completer<List<String>>();
  _listen(
    ((JSString text) {
      if (!done.isCompleted) done.complete(text.toDart.split('\n'));
    }).toJS,
    ((JSString code) {
      if (!done.isCompleted) done.completeError(code.toDart);
    }).toJS,
  );
  return done.future;
}

void stopListeningChinese() {
  try {
    _stopListening();
  } catch (_) {}
}

@JS('zhRecorder.start')
external void _recStart(JSFunction onLevel, JSFunction onDone, JSFunction onError);

@JS('zhRecorder.stop')
external void _recStop();

@JS('zhRecorder.cancel')
external void _recCancel();

@JS('zhRecorder.play')
external void _recPlay(String url);

/// One recorded attempt: playable WAV URL and pitch (Hz every 10 ms, 0 = silent).
class VoiceRecording {
  VoiceRecording(this.url, this.pitch, this.milliseconds);

  final String url;
  final List<double> pitch;
  final int milliseconds;
}

/// Records until the speaker goes quiet (or [stopRecording] is called).
Future<VoiceRecording> recordVoice({void Function(double level)? onLevel}) {
  final done = Completer<VoiceRecording>();
  _recStart(
    ((JSNumber level) => onLevel?.call(level.toDartDouble)).toJS,
    ((JSString url, JSString pitch, JSNumber ms) {
      if (done.isCompleted) return;
      final hz = pitch.toDart.isEmpty
          ? <double>[]
          : [for (final v in pitch.toDart.split(',')) double.tryParse(v) ?? 0];
      done.complete(VoiceRecording(url.toDart, hz, ms.toDartInt));
    }).toJS,
    ((JSString code) {
      if (!done.isCompleted) done.completeError(code.toDart);
    }).toJS,
  );
  return done.future;
}

void stopRecording() => _recStop();

void cancelRecording() {
  try {
    _recCancel();
  } catch (_) {}
}

void playRecording(String url) => _recPlay(url);

/// Reads Chinese text aloud with the device's zh-CN voice.
bool speakChinese(String text, {double rate = 0.8}) {
  try {
    return _speak(text, rate);
  } catch (_) {
    return false;
  }
}

/// Drives a [HanziPad]: show the stroke order, or let the user write.
class HanziPadController {
  String? _id;

  void animate() {
    if (_id != null) _animate(_id!);
  }

  void quiz({required bool outline, required void Function(int mistakes) onDone}) {
    if (_id != null) _quiz(_id!, outline, ((JSNumber m) => onDone(m.toDartInt)).toJS);
  }
}

int _nextPad = 0;

/// A square writing pad (米字格) powered by hanzi-writer.
class HanziPad extends StatefulWidget {
  const HanziPad({
    super.key,
    required this.char,
    required this.size,
    required this.controller,
    this.outline = true,
  });

  final String char;
  final double size;
  final HanziPadController controller;
  final bool outline;

  @override
  State<HanziPad> createState() => _HanziPadState();
}

class _HanziPadState extends State<HanziPad> {
  final String _id = 'hanzi-pad-${_nextPad++}';
  late final web.HTMLDivElement _div = web.HTMLDivElement()
    ..id = _id
    ..style.width = '100%'
    ..style.height = '100%';

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_id, (int _) => _div);
    widget.controller._id = _id;
  }

  void _mountWriter() =>
      _mount(_id, _div, widget.char, widget.size, widget.outline);

  @override
  void didUpdateWidget(HanziPad old) {
    super.didUpdateWidget(old);
    widget.controller._id = _id;
    if (old.size != widget.size || old.outline != widget.outline) {
      _mountWriter();
    } else if (old.char != widget.char) {
      _setChar(_id, widget.char);
    }
  }

  @override
  void dispose() {
    _dispose(_id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: HtmlElementView(viewType: _id, onPlatformViewCreated: (_) => _mountWriter()),
      );
}
