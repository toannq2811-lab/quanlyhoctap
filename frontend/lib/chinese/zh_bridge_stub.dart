import 'package:flutter/material.dart';

/// Non-web fallback: no speech, and the pad just shows the character.
bool speakChinese(String text, {double rate = 0.8, String lang = 'zh-CN'}) => false;

bool get canListenChinese => false;

Future<List<String>> listenChinese({String lang = 'zh-CN'}) async => throw 'unsupported';

void stopListeningChinese() {}

class VoiceRecording {
  VoiceRecording(this.url, this.pitch, this.milliseconds);

  final String url;
  final List<double> pitch;
  final int milliseconds;
}

Future<VoiceRecording> recordVoice({void Function(double level)? onLevel}) async =>
    throw 'unsupported';

void stopRecording() {}

void cancelRecording() {}

void playRecording(String url) {}

class HanziPadController {
  void animate() {}
  void quiz({required bool outline, required void Function(int mistakes) onDone}) {}
}

class HanziPad extends StatelessWidget {
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
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Center(child: Text(char, style: TextStyle(fontSize: size * 0.7))),
      );
}
