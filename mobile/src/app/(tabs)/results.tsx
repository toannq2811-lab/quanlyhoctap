import { View } from 'react-native';

import { Empty, PercentRing, ProgressBar, Row, Screen, SectionTitle, SoftCard, Text } from '@/components/ui';
import { colors } from '@/lib/theme';
import { allQuestions, formatDuration } from '@/lib/types';
import { statsOf, useStore } from '@/state/store';

/** Kết quả — overall accuracy, per deck and per chapter, recent sessions. */
export default function ResultsTab() {
  const decks = useStore((s) => s.decks);
  const results = useStore((s) => s.results);
  const attempts = useStore((s) => s.attempts);
  const all = decks.flatMap(allQuestions);
  const st = statsOf(results, all);

  return (
    <Screen>
      <Text weight="black" size={24}>
        Kết quả
      </Text>
      <SoftCard style={{ marginTop: 14 }}>
        <Row gap={18}>
          <PercentRing value={st.accuracy} size={110} label="chính xác" />
          <View style={{ flex: 1, gap: 4 }}>
            <Text muted>
              Đã làm {st.done}/{st.total} câu
            </Text>
            <Text weight="heavy" color={colors.green}>
              ✓ Đúng {st.right}
            </Text>
            <Text weight="heavy" color={colors.red}>
              ✗ Sai {st.wrong}
            </Text>
            <Text muted>{attempts.length} lượt làm bài</Text>
          </View>
        </Row>
      </SoftCard>

      {decks.map((d) => (
        <View key={d.id}>
          <SectionTitle>{d.name}</SectionTitle>
          {d.sections.map((s) => {
            const ss = statsOf(results, s.questions);
            return (
              <SoftCard key={s.title} style={{ marginBottom: 8 }} padding={12}>
                <Row style={{ justifyContent: 'space-between' }}>
                  <Text weight="heavy" style={{ flex: 1 }} numberOfLines={1}>
                    {s.title}
                  </Text>
                  <Text weight="heavy" color={ss.done ? (ss.accuracy >= 0.7 ? colors.green : colors.red) : colors.muted}>
                    {ss.done ? `${Math.round(ss.accuracy * 100)}%` : '—'}
                  </Text>
                </Row>
                <Text muted size={12} style={{ marginVertical: 4 }}>
                  {ss.done}/{ss.total} câu · đúng {ss.right} · sai {ss.wrong}
                </Text>
                <ProgressBar value={ss.total ? ss.done / ss.total : 0} height={5} />
              </SoftCard>
            );
          })}
        </View>
      ))}

      <SectionTitle>Lịch sử làm bài</SectionTitle>
      {!attempts.length ? <Empty text="Chưa có lượt làm bài nào. Làm thử một đề nhé!" /> : null}
      {attempts.slice(0, 30).map((a, i) => {
        const deck = decks.find((d) => d.id === a.deckId);
        const pct = a.total ? Math.round((a.right / Math.max(1, a.right + a.wrong)) * 100) : 0;
        const at = new Date(a.at);
        return (
          <SoftCard key={i} style={{ marginBottom: 8 }} padding={12}>
            <Row>
              <View style={{ flex: 1 }}>
                <Text weight="heavy">{deck?.name ?? 'Bài làm'}</Text>
                <Text muted size={12}>
                  {at.getDate()}/{at.getMonth() + 1} {String(at.getHours()).padStart(2, '0')}:{String(at.getMinutes()).padStart(2, '0')} · {a.total} câu · ⏱{' '}
                  {formatDuration(a.seconds)}
                </Text>
              </View>
              <View style={{ alignItems: 'flex-end' }}>
                <Text weight="black" color={pct >= 70 ? colors.green : colors.red}>
                  {pct}%
                </Text>
                <Text muted size={12}>
                  {a.right}✓ {a.wrong}✗
                </Text>
              </View>
            </Row>
          </SoftCard>
        );
      })}
    </Screen>
  );
}
