import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { router, Stack } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GradientButton, Mascot, OutlineButton, PercentRing, ProgressBar, Text } from '@/components/ui';
import { speak } from '@/lib/speech';
import { colors } from '@/lib/theme';
import { isEnglish, shuffle, speechLang, type VocabWord } from '@/lib/types';
import { chineseLists, recordAnswer, useStore, type VocabSession } from '@/state/store';

type Q = { word: VocabWord; options: VocabWord[]; answer: number };

function makeQuestions(s: VocabSession, allWords: VocabWord[]): Q[] {
  return s.words.map((w) => {
    const pool = s.pool.length >= 4 ? s.pool : allWords;
    const others = shuffle(pool.filter((o) => o.hanzi !== w.hanzi && o.meaning !== w.meaning)).slice(0, 3);
    const options = shuffle([w, ...others]);
    return { word: w, options, answer: options.indexOf(w) };
  });
}

/** Vocabulary quiz: chữ → nghĩa, nghĩa → chữ, or nghe → chữ. */
export default function VocabQuizScreen() {
  const session = useStore((s) => s.vocab);
  const custom = useStore((s) => s.customLists);
  const [round, setRound] = useState(session);
  const qs = useMemo(
    () => (round ? makeQuestions(round, chineseLists(custom).flatMap((l) => l.words)) : []),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [round],
  );
  const [index, setIndex] = useState(0);
  const [chosen, setChosen] = useState<Record<number, number>>({});

  const q = qs[index];
  const listen = round?.mode === 'listen';
  useEffect(() => {
    if (q && listen) speak(q.word.hanzi, speechLang(q.word));
  }, [q, listen]);

  if (!round || !qs.length) return null;
  const right = Object.entries(chosen).filter(([i, c]) => qs[+i].answer === c).length;

  if (index >= qs.length) {
    const wrong = qs.filter((x, i) => chosen[i] !== x.answer).map((x) => x.word);
    return (
      <SafeAreaView style={styles.done} edges={['bottom']}>
        <Stack.Screen options={{ title: round.title }} />
        <Mascot size={110} />
        <PercentRing value={right / qs.length} size={120} label="đúng" />
        <Text weight="black" size={20}>
          Đúng {right}/{qs.length}
        </Text>
        <View style={{ alignSelf: 'stretch', gap: 10, marginTop: 20 }}>
          {wrong.length ? (
            <GradientButton
              label={`Làm lại ${wrong.length} từ sai`}
              onPress={() => {
                setRound({ ...round, words: shuffle(wrong) });
                setIndex(0);
                setChosen({});
              }}
            />
          ) : null}
          <OutlineButton label="Xong" onPress={() => router.back()} />
        </View>
      </SafeAreaView>
    );
  }

  const answered = chosen[index] !== undefined;
  const english = isEnglish(q.word);
  const prompt = round.mode === 'hanziToMeaning' ? q.word.hanzi : round.mode === 'meaningToHanzi' ? q.word.meaning : null;
  const label = (w: VocabWord) => (round.mode === 'hanziToMeaning' ? w.meaning : w.hanzi);

  function choose(i: number) {
    if (answered) return;
    setChosen((c) => ({ ...c, [index]: i }));
    const ok = i === q.answer;
    recordAnswer(q.word, ok);
    Haptics.notificationAsync(ok ? Haptics.NotificationFeedbackType.Success : Haptics.NotificationFeedbackType.Error).catch(() => {});
    if (!listen) speak(q.word.hanzi, speechLang(q.word));
  }

  return (
    <SafeAreaView style={{ flex: 1 }} edges={['bottom']}>
      <Stack.Screen options={{ title: `${index + 1}/${qs.length}`, headerRight: () => <Text weight="heavy" color={colors.green}>✓ {right}</Text> }} />
      <View style={{ paddingHorizontal: 20 }}>
        <ProgressBar value={(index + 1) / qs.length} />
      </View>
      <ScrollView contentContainerStyle={{ padding: 20 }}>
        <View style={styles.prompt}>
          {prompt ? (
            <Text weight="black" size={round.mode === 'hanziToMeaning' && !english ? 60 : 26} style={{ textAlign: 'center' }}>
              {prompt}
            </Text>
          ) : (
            <Pressable onPress={() => speak(q.word.hanzi, speechLang(q.word))} style={{ alignItems: 'center', gap: 8 }}>
              <Ionicons name="volume-high" size={56} color={colors.pink} />
              <Text muted>Chạm để nghe lại</Text>
            </Pressable>
          )}
          {answered ? (
            <Text weight="bold" color={colors.pink} size={18} style={{ marginTop: 8 }}>
              {q.word.hanzi} · {q.word.pinyin}
            </Text>
          ) : null}
        </View>
        {q.options.map((o, i) => {
          const state = !answered ? 'idle' : i === q.answer ? 'correct' : i === chosen[index] ? 'wrong' : 'dimmed';
          const border = state === 'correct' ? colors.green : state === 'wrong' ? colors.red : colors.border;
          const fill = state === 'correct' ? colors.greenSoft : state === 'wrong' ? colors.redSoft : colors.white;
          return (
            <Pressable
              key={o.id}
              onPress={() => choose(i)}
              style={[styles.option, { borderColor: border, backgroundColor: fill, opacity: state === 'dimmed' ? 0.55 : 1 }]}
            >
              <Text weight="bold" size={round.mode === 'hanziToMeaning' || english ? 16 : 24} style={{ textAlign: 'center' }}>
                {label(o)}
              </Text>
            </Pressable>
          );
        })}
      </ScrollView>
      {answered ? (
        <View style={{ paddingHorizontal: 20, paddingBottom: 8 }}>
          <GradientButton label={index === qs.length - 1 ? 'Xem kết quả 🏁' : 'Câu tiếp theo ›'} onPress={() => setIndex(index + 1)} />
        </View>
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  prompt: {
    backgroundColor: colors.white,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: colors.border,
    minHeight: 170,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    marginBottom: 18,
  },
  option: { borderWidth: 1.5, borderRadius: 16, padding: 16, marginBottom: 10, alignItems: 'center' },
  done: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 10 },
});
