import { Stack, useLocalSearchParams } from 'expo-router';
import { useState } from 'react';
import { ActionSheetIOS, Alert, Platform, Pressable, View } from 'react-native';

import { GradientButton, PercentRing, ProgressBar, Row, Screen, SoftCard, Text } from '@/components/ui';
import { errorText } from '@/lib/api';
import { pickRandomQuiz, startQuiz } from '@/lib/nav';
import { colors } from '@/lib/theme';
import { allQuestions, shuffle, type Question } from '@/lib/types';
import { resetProgress, statsOf, useStore } from '@/state/store';

/** A deck: its chapters with progress; pick a chapter (or all) and a mode. */
export default function DeckScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const deck = useStore((s) => s.decks.find((d) => d.id === id));
  const results = useStore((s) => s.results);
  const attempts = useStore((s) => s.attempts.filter((a) => a.deckId === id).length);
  const [open, setOpen] = useState<number | null>(null);
  if (!deck) return null;

  const all = allQuestions(deck);
  const st = statsOf(results, all);

  function chooseMode(title: string, qs: Question[]) {
    const fresh = qs.filter((q) => results[q.id] === undefined);
    const wrong = qs.filter((q) => results[q.id] === false);
    const modes: [string, () => void][] = [
      [`Làm theo thứ tự (${qs.length} câu)`, () => startQuiz(title, qs)],
      ['Trộn thứ tự câu hỏi', () => startQuiz(title, shuffle(qs))],
      ['Thi thử: chọn số câu ngẫu nhiên', () => pickRandomQuiz(title, qs)],
    ];
    if (fresh.length) modes.push([`Câu chưa làm (${fresh.length})`, () => startQuiz(title, fresh)]);
    if (wrong.length) modes.push([`Ôn lại câu làm sai (${wrong.length})`, () => startQuiz(title, wrong)]);
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        { title, options: [...modes.map((m) => m[0]), 'Hủy'], cancelButtonIndex: modes.length },
        (i) => modes[i]?.[1](),
      );
    } else {
      Alert.alert(title, undefined, [...modes.map(([text, onPress]) => ({ text, onPress })), { text: 'Hủy', style: 'cancel' }]);
    }
  }

  function confirmReset() {
    Alert.alert('Làm lại từ đầu?', `Xóa kết quả đã làm của "${deck!.name}" để ôn lại từ đầu.`, [
      { text: 'Hủy', style: 'cancel' },
      {
        text: 'Xóa',
        style: 'destructive',
        onPress: () => resetProgress(all.map((q) => q.id)).catch((e) => Alert.alert(errorText(e))),
      },
    ]);
  }

  return (
    <Screen edges={[]}>
      <Stack.Screen
        options={{
          title: deck.name,
          headerRight: () => (
            <Pressable onPress={confirmReset} hitSlop={10}>
              <Text weight="bold" color={colors.pink}>
                Làm lại
              </Text>
            </Pressable>
          ),
        }}
      />
      <SoftCard>
        <Row gap={16}>
          <PercentRing value={st.total ? st.done / st.total : 0} label="đã làm" />
          <View style={{ flex: 1, gap: 2 }}>
            <Text muted>{all.length} câu · {attempts} lần làm</Text>
            <Text weight="heavy" color={colors.green}>
              Đúng {st.right}
            </Text>
            <Text weight="heavy" color={colors.red}>
              Sai {st.wrong}
            </Text>
            <Text muted>Chưa làm {st.total - st.done}</Text>
          </View>
        </Row>
        <GradientButton label="Bắt đầu làm bài" style={{ marginTop: 14 }} onPress={() => chooseMode(deck.name, all)} />
      </SoftCard>

      <Text weight="black" size={17} style={{ marginTop: 22, marginBottom: 10 }}>
        Các chương
      </Text>
      {deck.sections.map((s, si) => {
        const ss = statsOf(results, s.questions);
        const expanded = open === si;
        return (
          <SoftCard key={si} style={{ marginBottom: 10 }} padding={14} onPress={() => setOpen(expanded ? null : si)}>
            <Text weight="heavy">{s.title}</Text>
            <Text muted size={13} style={{ marginVertical: 6 }}>
              {ss.total} câu · đã làm {ss.done} · đúng {ss.right} · sai {ss.wrong}
            </Text>
            <ProgressBar value={ss.total ? ss.done / ss.total : 0} />
            {expanded ? (
              <View style={{ marginTop: 12 }}>
                <GradientButton label="Làm chương này" onPress={() => chooseMode(s.title, s.questions)} />
                <View style={{ marginTop: 10 }}>
                  {s.questions.map((q, qi) => {
                    const r = results[q.id];
                    const bg = r === undefined ? colors.blush : r ? colors.green : colors.red;
                    return (
                      <Pressable key={q.id} onPress={() => startQuiz(s.title, s.questions, qi)}>
                        <Row style={{ paddingVertical: 8 }}>
                          <View style={{ width: 30, height: 30, borderRadius: 8, backgroundColor: bg, alignItems: 'center', justifyContent: 'center' }}>
                            <Text weight="heavy" size={12} color={r === undefined ? colors.text : '#fff'}>
                              {q.number}
                            </Text>
                          </View>
                          <Text numberOfLines={1} style={{ flex: 1 }}>
                            {q.text}
                          </Text>
                        </Row>
                      </Pressable>
                    );
                  })}
                </View>
              </View>
            ) : null}
          </SoftCard>
        );
      })}
    </Screen>
  );
}
