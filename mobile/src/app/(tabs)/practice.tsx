import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { View } from 'react-native';

import { Empty, Row, Screen, SoftCard, Text } from '@/components/ui';
import { pickRandomQuiz, startQuiz } from '@/lib/nav';
import { colors } from '@/lib/theme';
import { allQuestions, shuffle } from '@/lib/types';
import { useStore } from '@/state/store';

/** Luyện tập — per deck: thi thử, ôn câu sai, câu chưa làm, theo chương. */
export default function PracticeTab() {
  const decks = useStore((s) => s.decks);
  const results = useStore((s) => s.results);

  return (
    <Screen>
      <Text weight="black" size={24} style={{ marginBottom: 6 }}>
        Luyện tập
      </Text>
      {!decks.length ? <Empty text="Chưa có bộ đề nào." /> : null}
      {decks.map((deck) => {
        const all = allQuestions(deck);
        const wrong = all.filter((q) => results[q.id] === false);
        const fresh = all.filter((q) => results[q.id] === undefined);
        return (
          <View key={deck.id} style={{ marginTop: 14 }}>
            <Text weight="black" size={16} style={{ marginBottom: 8 }}>
              {deck.name}
            </Text>
            <Action icon="dice-outline" title="Thi thử" subtitle="Chọn số câu ngẫu nhiên" onPress={() => pickRandomQuiz(deck.name, all)} />
            <Action
              icon="refresh"
              title={`Ôn câu sai (${wrong.length})`}
              subtitle="Làm lại những câu đã trả lời sai"
              onPress={wrong.length ? () => startQuiz('Ôn câu sai', shuffle(wrong)) : undefined}
            />
            <Action
              icon="sparkles-outline"
              title={`Câu chưa làm (${fresh.length})`}
              subtitle="Tiếp tục những câu chưa đụng tới"
              onPress={fresh.length ? () => startQuiz(deck.name, fresh) : undefined}
            />
            <Action
              icon="list-outline"
              title="Làm theo chương"
              subtitle={`${deck.sections.length} chương · ${all.length} câu`}
              onPress={() => router.push(`/deck/${deck.id}`)}
            />
          </View>
        );
      })}
    </Screen>
  );
}

function Action({
  icon,
  title,
  subtitle,
  onPress,
}: {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  subtitle: string;
  onPress?: () => void;
}) {
  return (
    <SoftCard onPress={onPress} style={{ marginBottom: 10, opacity: onPress ? 1 : 0.5 }} padding={14}>
      <Row gap={14}>
        <View style={{ width: 42, height: 42, borderRadius: 12, backgroundColor: colors.blush, alignItems: 'center', justifyContent: 'center' }}>
          <Ionicons name={icon} size={22} color={colors.pink} />
        </View>
        <View style={{ flex: 1 }}>
          <Text weight="heavy">{title}</Text>
          <Text muted size={13}>
            {subtitle}
          </Text>
        </View>
        <Ionicons name="chevron-forward" size={18} color={colors.muted} />
      </Row>
    </SoftCard>
  );
}
