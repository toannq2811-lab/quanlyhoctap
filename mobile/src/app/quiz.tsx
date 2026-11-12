import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { router, Stack } from 'expo-router';
import { useEffect, useRef, useState } from 'react';
import { ActivityIndicator, Modal, Pressable, ScrollView, StyleSheet, View, type ScrollViewInstance } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Badge, GradientButton, Mascot, OutlineButton, ProgressBar, Row, Text } from '@/components/ui';
import { errorText } from '@/lib/api';
import { colors } from '@/lib/theme';
import { formatDuration, letter, shortSectionName, type Question } from '@/lib/types';
import { explainWrong, record, sectionOf, useStore } from '@/state/store';

const praise = ['Chính xác rồi! 🎉', 'Giỏi quá! 🥰', 'Đúng rồi nè 💯', 'Xuất sắc! ✨', 'Quá đỉnh! 💕'];
const cheer = ['Cố lên nha 💪', 'Nhớ câu này nhé 😘', 'Lần sau sẽ đúng thôi 🌸'];
const pick = (a: string[]) => a[Math.floor(Math.random() * a.length)];

/** 6–7. Làm bài trắc nghiệm, with instant right/wrong feedback and AI explanations. */
export default function QuizScreen() {
  const session = useStore((s) => s.quiz);
  const qs = session?.questions ?? [];
  const [index, setIndex] = useState(session?.startAt ?? 0);
  const [chosen, setChosen] = useState<Record<number, number>>({});
  const [messages, setMessages] = useState<Record<number, string>>({});
  const [ai, setAi] = useState<Record<number, Promise<string>>>({});
  const [seconds, setSeconds] = useState(0);
  const [navigator, setNavigator] = useState(false);
  const scroll = useRef<ScrollViewInstance>(null);
  const [started] = useState(() => Date.now());

  useEffect(() => {
    const t = setInterval(() => setSeconds(Math.floor((Date.now() - started) / 1000)), 1000);
    return () => clearInterval(t);
  }, [started]);

  if (!session || !qs.length) return null;
  const q = qs[index];
  const answered = chosen[index] !== undefined;
  const last = index === qs.length - 1;

  function choose(option: number) {
    if (answered) return;
    const answer = q.answer;
    setChosen((c) => ({ ...c, [index]: option }));
    if (answer !== null) {
      const ok = option === answer;
      setMessages((m) => ({ ...m, [index]: pick(ok ? praise : cheer) }));
      record(q, ok);
      Haptics.notificationAsync(ok ? Haptics.NotificationFeedbackType.Success : Haptics.NotificationFeedbackType.Error).catch(() => {});
      if (!ok) setAi((a) => ({ ...a, [index]: explainWrong(q, option) }));
    }
    setTimeout(() => scroll.current?.scrollToEnd({ animated: true }), 150);
  }

  function go(i: number) {
    if (i < 0) return;
    if (i >= qs.length) return finish();
    setIndex(i);
    scroll.current?.scrollTo({ y: 0, animated: false });
  }

  function finish() {
    const entries = Object.entries(chosen);
    const right = entries.filter(([i, c]) => qs[+i].answer === c).length;
    const wrong = entries.filter(([i, c]) => qs[+i].answer !== null && qs[+i].answer !== c).length;
    router.replace({
      pathname: '/session-result',
      params: {
        title: session!.title,
        right: String(right),
        wrong: String(wrong),
        skipped: String(qs.length - entries.length),
        seconds: String(seconds),
        wrongIds: entries
          .filter(([i, c]) => qs[+i].answer !== null && qs[+i].answer !== c)
          .map(([i]) => qs[+i].id)
          .join(','),
      },
    });
  }

  return (
    <SafeAreaView style={{ flex: 1 }} edges={['bottom']}>
      <Stack.Screen
        options={{
          headerTitle: () => (
            <Pressable onPress={() => setNavigator(true)} hitSlop={10}>
              <Text weight="heavy" size={17}>
                {index + 1}/{qs.length} ▾
              </Text>
            </Pressable>
          ),
          headerRight: () => (
            <View style={styles.timer}>
              <Ionicons name="timer-outline" size={15} color={colors.pink} />
              <Text weight="heavy" size={13} color={colors.pink}>
                {formatDuration(seconds)}
              </Text>
            </View>
          ),
        }}
      />
      <View style={{ paddingHorizontal: 20 }}>
        <ProgressBar value={(index + 1) / qs.length} />
      </View>
      <ScrollView ref={scroll} contentContainerStyle={{ padding: 20, paddingBottom: 24 }}>
        <Badge>
          {shortSectionName(sectionOf(q.id))} · Câu {q.number}
        </Badge>
        <Text weight="heavy" size={19} style={{ marginTop: 12, marginBottom: 18, lineHeight: 27 }}>
          {q.text}
        </Text>
        {q.options.map((o, i) => (
          <OptionTile key={i} letter={letter(i)} text={o} state={optionState(q, chosen[index], i)} onPress={() => choose(i)} />
        ))}
        {answered ? <Feedback q={q} chosen={chosen[index]} message={messages[index]} ai={ai[index]} onRetry={() => setAi((a) => ({ ...a, [index]: explainWrong(q, chosen[index]) }))} /> : null}
      </ScrollView>
      <Row style={{ paddingHorizontal: 20, paddingTop: 8, paddingBottom: 8 }} gap={12}>
        <OutlineButton label="‹ Trước" onPress={index ? () => go(index - 1) : undefined} />
        <GradientButton
          style={{ flex: 1 }}
          label={last ? 'Xem kết quả 🏁' : answered ? 'Câu tiếp theo ›' : 'Tiếp theo ›'}
          onPress={() => go(index + 1)}
        />
      </Row>

      <Modal visible={navigator} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setNavigator(false)}>
        <View style={{ flex: 1, backgroundColor: colors.white, padding: 20 }}>
          <Row style={{ justifyContent: 'space-between', marginBottom: 16 }}>
            <Text weight="black" size={18}>
              Chọn câu
            </Text>
            <Pressable onPress={() => setNavigator(false)} hitSlop={10}>
              <Ionicons name="close" size={26} color={colors.muted} />
            </Pressable>
          </Row>
          <ScrollView contentContainerStyle={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
            {qs.map((x, i) => {
              const c = chosen[i];
              const bg = c === undefined ? colors.blush : x.answer === null ? colors.muted : c === x.answer ? colors.green : colors.red;
              return (
                <Pressable
                  key={x.id}
                  onPress={() => {
                    setNavigator(false);
                    go(i);
                  }}
                  style={[styles.navCell, { backgroundColor: bg }, i === index && { borderWidth: 2.5, borderColor: colors.pink }]}
                >
                  <Text weight="heavy" color={c === undefined ? colors.text : '#fff'}>
                    {i + 1}
                  </Text>
                </Pressable>
              );
            })}
          </ScrollView>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

type OptionState = 'idle' | 'correct' | 'wrong' | 'picked' | 'dimmed';

function optionState(q: Question, chosen: number | undefined, i: number): OptionState {
  if (chosen === undefined) return 'idle';
  if (i === q.answer) return 'correct';
  if (i === chosen) return q.answer === null ? 'picked' : 'wrong';
  return 'dimmed';
}

function OptionTile({ letter, text, state, onPress }: { letter: string; text: string; state: OptionState; onPress: () => void }) {
  const [border, fill, tag] =
    state === 'correct'
      ? [colors.green, colors.greenSoft, 'Đáp án đúng']
      : state === 'wrong'
        ? [colors.red, colors.redSoft, 'Bạn chọn']
        : state === 'picked'
          ? [colors.pink, colors.blush, 'Bạn chọn']
          : [colors.border, colors.white, null];
  const highlighted = border !== colors.border;
  return (
    <Pressable
      onPress={state === 'idle' ? onPress : undefined}
      style={({ pressed }) => [
        styles.option,
        { borderColor: border, backgroundColor: fill, borderWidth: highlighted ? 1.8 : 1.2, opacity: state === 'dimmed' ? 0.6 : pressed ? 0.8 : 1 },
      ]}
    >
      <View style={[styles.letter, { backgroundColor: highlighted ? border : colors.blush }]}>
        <Text weight="black" color={highlighted ? '#fff' : colors.pink}>
          {letter}
        </Text>
      </View>
      <Text size={16} weight={highlighted ? 'bold' : 'semibold'} style={{ flex: 1, lineHeight: 22 }}>
        {text}
      </Text>
      {tag ? (
        <Ionicons name={state === 'correct' ? 'checkmark-circle' : 'close-circle'} size={22} color={border} />
      ) : null}
    </Pressable>
  );
}

function Feedback({
  q,
  chosen,
  message,
  ai,
  onRetry,
}: {
  q: Question;
  chosen: number;
  message?: string;
  ai?: Promise<string>;
  onRetry: () => void;
}) {
  const answer = q.answer;
  const ok = answer !== null && chosen === answer;
  const [title, color] =
    answer === null
      ? ['Tài liệu không có đáp án cho câu này', colors.muted]
      : ok
        ? [message ?? praise[0], colors.green]
        : ['Chưa chính xác rồi!', colors.red];
  return (
    <View style={[styles.feedback, { borderColor: color + '66' }]}>
      <Row gap={10} style={{ alignItems: 'flex-start' }}>
        <Mascot size={60} />
        <View style={{ flex: 1, gap: 4 }}>
          <Text weight="black" size={17} color={color}>
            {title}
          </Text>
          {answer !== null ? (
            <Text>
              Đáp án đúng là:{' '}
              <Text weight="heavy" color={colors.green}>
                {letter(answer)}. {q.options[answer]}
              </Text>
            </Text>
          ) : null}
          {answer !== null && !ok && message ? (
            <Text muted size={13}>
              {message}
            </Text>
          ) : null}
        </View>
      </Row>
      {ai ? <AiExplanation promise={ai} onRetry={onRetry} /> : null}
      {q.explanation ? (
        <View style={styles.explain}>
          <Text weight="black" color={colors.pink}>
            Giải thích
          </Text>
          <Text style={{ lineHeight: 21, marginTop: 4 }}>{q.explanation}</Text>
        </View>
      ) : null}
    </View>
  );
}

/** "🤖 AI giải thích": why the picked option is wrong, loaded as soon as it is picked. */
function AiExplanation({ promise, onRetry }: { promise: Promise<string>; onRetry: () => void }) {
  // Keyed by the promise, so a retry shows the spinner again without resetting state.
  const [settled, setSettled] = useState<{ promise: Promise<string>; text?: string; error?: string } | null>(null);
  useEffect(() => {
    promise.then(
      (text) => setSettled({ promise, text }),
      (e) => setSettled({ promise, error: errorText(e) }),
    );
  }, [promise]);
  const state: { text?: string; error?: string } = settled?.promise === promise ? settled : {};

  return (
    <View style={styles.ai}>
      <Text weight="black" color={colors.violet} style={{ marginBottom: 6 }}>
        🤖 AI giải thích
      </Text>
      {state.text ? (
        <Text style={{ lineHeight: 21 }}>{state.text}</Text>
      ) : state.error ? (
        <Row>
          <Text muted style={{ flex: 1 }}>
            {state.error}
          </Text>
          <Pressable onPress={onRetry} hitSlop={8}>
            <Text weight="heavy" color={colors.violet}>
              Thử lại
            </Text>
          </Pressable>
        </Row>
      ) : (
        <Row>
          <ActivityIndicator size="small" color={colors.violet} />
          <Text muted>AI đang giải thích vì sao sai…</Text>
        </Row>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  timer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: colors.blush,
    borderRadius: 20,
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  option: { flexDirection: 'row', alignItems: 'center', gap: 12, borderRadius: 16, padding: 14, marginBottom: 10 },
  letter: { width: 30, height: 30, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  feedback: { backgroundColor: colors.white, borderRadius: 20, borderWidth: 1, padding: 14, marginTop: 10 },
  explain: { backgroundColor: colors.blush + '99', borderRadius: 12, padding: 12, marginTop: 12 },
  ai: {
    backgroundColor: colors.violetSoft,
    borderColor: colors.violetBorder,
    borderWidth: 1,
    borderRadius: 12,
    padding: 12,
    marginTop: 12,
  },
  navCell: { width: 48, height: 48, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
});
