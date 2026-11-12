import * as Haptics from 'expo-haptics';
import { router, Stack, useLocalSearchParams } from 'expo-router';
import { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GradientButton, Mascot, OutlineButton, PercentRing, ProgressBar, Text } from '@/components/ui';
import { allExercises, exerciseWord, type TenseExercise } from '@/lib/content';
import { speak } from '@/lib/speech';
import { colors } from '@/lib/theme';
import { letter, shuffle } from '@/lib/types';
import { recordAnswer } from '@/state/store';

/** Bài tập chia động từ: chọn đáp án, biết đúng/sai ngay kèm giải thích. */
export default function TenseQuizScreen() {
  const p = useLocalSearchParams<{ title: string; ids: string }>();
  const initial = useMemo(() => {
    const byId = new Map(allExercises.map((e) => [e.id, e]));
    return (p.ids ?? '').split(',').map((id) => byId.get(id)).filter((e): e is TenseExercise => !!e);
  }, [p.ids]);
  const [exercises, setExercises] = useState(initial);
  const [index, setIndex] = useState(0);
  const [chosen, setChosen] = useState<Record<number, number>>({});
  if (!exercises.length) return null;

  const right = Object.entries(chosen).filter(([i, c]) => exercises[+i].answer === c).length;

  if (index >= exercises.length) {
    const wrong = exercises.filter((e, i) => chosen[i] !== e.answer);
    return (
      <SafeAreaView style={styles.done} edges={['bottom']}>
        <Stack.Screen options={{ title: p.title }} />
        <Mascot size={110} />
        <Text weight="black" size={22}>
          {wrong.length ? 'Hoàn thành 💕' : 'Đúng hết luôn! 🏆'}
        </Text>
        <PercentRing value={right / exercises.length} size={120} label={`${right}/${exercises.length} câu`} />
        <View style={{ alignSelf: 'stretch', gap: 10, marginTop: 20 }}>
          {wrong.length ? (
            <GradientButton
              label={`Làm lại ${wrong.length} câu sai`}
              onPress={() => {
                setExercises(shuffle(wrong));
                setChosen({});
                setIndex(0);
              }}
            />
          ) : null}
          <OutlineButton label="Xong" onPress={() => router.back()} />
        </View>
      </SafeAreaView>
    );
  }

  const e = exercises[index];
  const answered = chosen[index] !== undefined;

  function choose(i: number) {
    if (answered) return;
    setChosen((c) => ({ ...c, [index]: i }));
    const ok = i === e.answer;
    recordAnswer(exerciseWord(e), ok);
    Haptics.notificationAsync(ok ? Haptics.NotificationFeedbackType.Success : Haptics.NotificationFeedbackType.Error).catch(() => {});
    speak(e.question.replace(/_+|\.\.\./, e.options[e.answer]), 'en-US');
  }

  return (
    <SafeAreaView style={{ flex: 1 }} edges={['bottom']}>
      <Stack.Screen options={{ title: `${index + 1}/${exercises.length}`, headerRight: () => <Text weight="heavy" color={colors.green}>✓ {right}</Text> }} />
      <View style={{ paddingHorizontal: 20 }}>
        <ProgressBar value={(index + 1) / exercises.length} />
      </View>
      <ScrollView contentContainerStyle={{ padding: 20 }}>
        <Text muted>{p.title}</Text>
        <Text weight="heavy" size={20} style={{ marginVertical: 14, lineHeight: 28 }}>
          {e.question}
        </Text>
        {e.options.map((o, i) => {
          const state = !answered ? 'idle' : i === e.answer ? 'correct' : i === chosen[index] ? 'wrong' : 'dimmed';
          const border = state === 'correct' ? colors.green : state === 'wrong' ? colors.red : colors.border;
          const fill = state === 'correct' ? colors.greenSoft : state === 'wrong' ? colors.redSoft : colors.white;
          return (
            <Pressable key={i} onPress={() => choose(i)} style={[styles.option, { borderColor: border, backgroundColor: fill, opacity: state === 'dimmed' ? 0.55 : 1 }]}>
              <View style={[styles.letter, { backgroundColor: state === 'idle' || state === 'dimmed' ? colors.blush : border }]}>
                <Text weight="black" color={state === 'idle' || state === 'dimmed' ? colors.pink : '#fff'}>
                  {letter(i)}
                </Text>
              </View>
              <Text weight="semibold" size={17} style={{ flex: 1 }}>
                {o}
              </Text>
            </Pressable>
          );
        })}
        {answered ? (
          <View style={styles.explain}>
            <Text weight="black" color={chosen[index] === e.answer ? colors.green : colors.red}>
              {chosen[index] === e.answer ? 'Chính xác! 🎉' : `Chưa đúng — đáp án: ${e.options[e.answer]}`}
            </Text>
            <Text style={{ marginTop: 6, lineHeight: 21 }}>{e.explain}</Text>
          </View>
        ) : null}
      </ScrollView>
      {answered ? (
        <View style={{ paddingHorizontal: 20, paddingBottom: 8 }}>
          <GradientButton label={index === exercises.length - 1 ? 'Xem kết quả' : 'Câu tiếp theo ›'} onPress={() => setIndex(index + 1)} />
        </View>
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  option: { flexDirection: 'row', alignItems: 'center', gap: 12, borderWidth: 1.5, borderRadius: 16, padding: 14, marginBottom: 10 },
  letter: { width: 30, height: 30, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  explain: { backgroundColor: colors.white, borderRadius: 16, borderWidth: 1, borderColor: colors.border, padding: 14, marginTop: 6 },
  done: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 10 },
});
