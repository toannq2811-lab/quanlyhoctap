import { router, useLocalSearchParams } from 'expo-router';
import { useEffect, useRef } from 'react';
import { View } from 'react-native';

import { GradientButton, Mascot, OutlineButton, PercentRing, Row, Screen, SoftCard, Text } from '@/components/ui';
import { colors } from '@/lib/theme';
import { formatDuration, shuffle, type Question } from '@/lib/types';
import { recordAttempt, useStore } from '@/state/store';

/** 8. Kết quả một lượt làm bài; the session is saved once when this opens. */
export default function SessionResultScreen() {
  const p = useLocalSearchParams<{
    title: string;
    right: string;
    wrong: string;
    skipped: string;
    seconds: string;
    wrongIds: string;
  }>();
  const questions = useStore((s) => s.quiz?.questions ?? []);
  const right = Number(p.right);
  const wrong = Number(p.wrong);
  const skipped = Number(p.skipped);
  const seconds = Number(p.seconds);
  const total = right + wrong;
  const score = total ? right / total : 0;
  const saved = useRef(false);

  useEffect(() => {
    if (saved.current || !questions.length || right + wrong === 0) return;
    saved.current = true;
    recordAttempt(questions, right, wrong, seconds);
  }, [questions, right, wrong, seconds]);

  const wrongIds = new Set((p.wrongIds ?? '').split(',').filter(Boolean));
  const wrongQs = questions.filter((q) => wrongIds.has(q.id));
  const verdict =
    score >= 0.9 ? 'Xuất sắc luôn! 🏆' : score >= 0.7 ? 'Làm tốt lắm! 🎉' : score >= 0.5 ? 'Khá rồi, cố thêm chút nha 💪' : 'Ôn lại thêm nhé, em làm được mà 🌸';

  return (
    <Screen edges={['bottom']}>
      <View style={{ alignItems: 'center', gap: 6 }}>
        <Mascot size={110} />
        <Text weight="black" size={22}>
          {verdict}
        </Text>
        <Text muted>{p.title}</Text>
      </View>
      <SoftCard style={{ marginTop: 18 }}>
        <Row gap={18}>
          <PercentRing value={score} size={110} label="đúng" />
          <View style={{ flex: 1, gap: 4 }}>
            <Text weight="heavy" color={colors.green}>
              ✓ Đúng: {right}
            </Text>
            <Text weight="heavy" color={colors.red}>
              ✗ Sai: {wrong}
            </Text>
            {skipped ? <Text muted>Bỏ qua: {skipped}</Text> : null}
            <Text muted>⏱ {formatDuration(seconds)}</Text>
          </View>
        </Row>
      </SoftCard>
      <View style={{ gap: 10, marginTop: 20 }}>
        {wrongQs.length ? (
          <GradientButton label={`Làm lại ${wrongQs.length} câu sai`} onPress={() => startQuizReplacing('Ôn câu sai', shuffle(wrongQs))} />
        ) : null}
        <OutlineButton label="Làm lại cả lượt" onPress={() => startQuizReplacing(p.title, questions)} />
        <OutlineButton label="Về trang chủ" onPress={() => router.dismissTo('/')} />
      </View>
    </Screen>
  );
}

function startQuizReplacing(title: string, questions: Question[]) {
  useStore.setState({ quiz: { title, questions, startAt: 0 } });
  router.replace('/quiz');
}
