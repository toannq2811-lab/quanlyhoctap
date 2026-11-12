import { Ionicons } from '@expo/vector-icons';
import { AudioModule, RecordingPresets, setAudioModeAsync, useAudioPlayer, useAudioRecorder, useAudioRecorderState } from 'expo-audio';
import * as Haptics from 'expo-haptics';
import { router, Stack } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GradientButton, OutlineButton, Row, SoftCard, Text } from '@/components/ui';
import { charPinyin } from '@/lib/content';
import { judgeChinese, judgeEnglish, listen, ListenError, speak, stopListening, type Verdict } from '@/lib/speech';
import { colors } from '@/lib/theme';
import { isEnglish, speechLang } from '@/lib/types';
import { recordAnswer, useStore } from '@/state/store';

/** Phát âm: the recognizer judges the word; recording lets the learner hear herself. */
export default function PronounceScreen() {
  const session = useStore((s) => s.vocab);
  const words = session?.words ?? [];
  const [index, setIndex] = useState(0);
  const [listening, setListening] = useState(false);
  const [verdict, setVerdict] = useState<Verdict | null>(null);
  const [heard, setHeard] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [right, setRight] = useState(0);
  const recorder = useAudioRecorder(RecordingPresets.HIGH_QUALITY);
  const recState = useAudioRecorderState(recorder);
  const player = useAudioPlayer(null);
  const [recorded, setRecorded] = useState<string | null>(null);

  const w = words[index];
  useEffect(() => () => stopListening(), []);
  if (!w) return null;
  const english = isEnglish(w);

  async function check() {
    setError(null);
    setVerdict(null);
    setHeard('');
    setListening(true);
    try {
      const guesses = await listen(speechLang(w));
      const v = english ? judgeEnglish(w.hanzi, guesses) : judgeChinese(w.hanzi, guesses, charPinyin);
      setVerdict(v);
      setHeard(guesses[0] ?? '');
      if (!guesses.length) setError('Không nghe thấy gì, thử nói to và rõ hơn nhé');
      else {
        recordAnswer(w, v !== 'wrong');
        if (v !== 'wrong') setRight((r) => r + 1);
        Haptics.notificationAsync(v === 'wrong' ? Haptics.NotificationFeedbackType.Error : Haptics.NotificationFeedbackType.Success).catch(() => {});
      }
    } catch (e) {
      setError(e instanceof ListenError ? e.message : 'Không dùng được nhận dạng giọng nói trên máy này');
    } finally {
      setListening(false);
    }
  }

  async function toggleRecording() {
    if (recState.isRecording) {
      await recorder.stop();
      setRecorded(recorder.uri);
      if (recorder.uri) {
        player.replace(recorder.uri);
        player.play();
      }
      return;
    }
    const perm = await AudioModule.requestRecordingPermissionsAsync();
    if (!perm.granted) {
      setError('Chưa cho phép micro. Vào Cài đặt iPhone → Study For You để bật nhé.');
      return;
    }
    await setAudioModeAsync({ allowsRecording: true, playsInSilentMode: true });
    await recorder.prepareToRecordAsync();
    recorder.record();
  }

  async function replay() {
    if (!recorded) return;
    await setAudioModeAsync({ allowsRecording: false, playsInSilentMode: true });
    player.seekTo(0);
    player.play();
  }

  function go(i: number) {
    stopListening();
    setIndex(i);
    setVerdict(null);
    setHeard('');
    setError(null);
    setRecorded(null);
  }

  const result =
    verdict === 'correct'
      ? { title: 'Phát âm chuẩn rồi! 🎉', color: colors.green }
      : verdict === 'homophone'
        ? { title: 'Đúng âm rồi, máy nghe ra chữ đồng âm 👍', color: colors.green }
        : verdict === 'wrong'
          ? { title: 'Chưa đúng lắm, nghe mẫu rồi thử lại nha 💪', color: colors.red }
          : null;

  return (
    <SafeAreaView style={{ flex: 1 }} edges={['bottom']}>
      <Stack.Screen options={{ title: `Phát âm · ${index + 1}/${words.length}`, headerRight: () => <Text weight="heavy" color={colors.green}>✓ {right}</Text> }} />
      <ScrollView contentContainerStyle={{ padding: 20, gap: 14 }}>
        <SoftCard padding={24} style={{ alignItems: 'center' }}>
          <Text weight="black" size={english ? 40 : 64}>
            {w.hanzi}
          </Text>
          <Text weight="bold" size={20} color={colors.pink}>
            {w.pinyin}
          </Text>
          <Text size={16} style={{ textAlign: 'center', marginTop: 4 }}>
            {w.meaning}
          </Text>
          <OutlineButton small icon="🔊" label="Nghe mẫu" style={{ marginTop: 12 }} onPress={() => speak(w.hanzi, speechLang(w))} />
        </SoftCard>

        <View style={{ alignItems: 'center', gap: 10 }}>
          <Pressable onPress={listening ? stopListening : check} style={[styles.mic, listening && { backgroundColor: colors.pinkDeep }]}>
            {listening ? <ActivityIndicator color="#fff" size="large" /> : <Ionicons name="mic" size={44} color="#fff" />}
          </Pressable>
          <Text muted>{listening ? 'Đang nghe... đọc to từ này nhé' : 'Bấm mic để chấm phát âm'}</Text>
        </View>

        {result ? (
          <SoftCard borderColor={result.color + '88'}>
            <Text weight="black" color={result.color} size={16}>
              {result.title}
            </Text>
            {heard ? <Text muted>Máy nghe được: {heard}</Text> : null}
          </SoftCard>
        ) : null}
        {error ? (
          <Text color={colors.red} style={{ textAlign: 'center' }}>
            {error}
          </Text>
        ) : null}

        <SoftCard>
          <Text weight="black" style={{ marginBottom: 10 }}>
            Giọng của em
          </Text>
          <Row>
            <OutlineButton
              style={{ flex: 1 }}
              icon={recState.isRecording ? '⏹' : '⏺'}
              label={recState.isRecording ? 'Dừng ghi âm' : 'Ghi âm & nghe lại'}
              color={recState.isRecording ? colors.red : colors.pink}
              onPress={toggleRecording}
            />
            {recorded ? <OutlineButton small icon="▶" label="Nghe lại" onPress={replay} /> : null}
          </Row>
          {recState.isRecording ? (
            <Text muted size={13} style={{ marginTop: 8 }}>
              Đang ghi... bấm Dừng khi nói xong
            </Text>
          ) : null}
        </SoftCard>
      </ScrollView>
      <Row style={{ paddingHorizontal: 20, paddingBottom: 8 }} gap={12}>
        <OutlineButton label="‹ Trước" onPress={index ? () => go(index - 1) : undefined} />
        <GradientButton
          style={{ flex: 1 }}
          label={index === words.length - 1 ? 'Xong' : 'Từ tiếp theo ›'}
          onPress={index === words.length - 1 ? () => router.back() : () => go(index + 1)}
        />
      </Row>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  mic: {
    width: 96,
    height: 96,
    borderRadius: 48,
    backgroundColor: colors.pink,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: colors.pink,
    shadowOpacity: 0.4,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 6 },
  },
});
