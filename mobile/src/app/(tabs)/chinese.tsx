import { router } from 'expo-router';
import { View } from 'react-native';

import { BrandTitle, GradientButton, OutlineButton, PercentRing, ProgressBar, Row, Screen, SectionTitle, SoftCard, Text } from '@/components/ui';
import { startFlashcards, startVocabQuiz } from '@/lib/nav';
import { colors } from '@/lib/theme';
import { chineseLists, knownIn, studyOrder, useStore } from '@/state/store';

/** Tiếng Trung: vocabulary lists and the ways to study them. */
export default function ChineseTab() {
  const progress = useStore((s) => s.vocabProgress);
  const custom = useStore((s) => s.customLists);
  const lists = chineseLists(custom);
  const total = lists.reduce((n, l) => n + l.words.length, 0);
  const known = lists.reduce((n, l) => n + knownIn(progress, l.words), 0);
  const current = lists.find((l) => knownIn(progress, l.words) < l.words.length) ?? lists[0];

  return (
    <Screen>
      <Row gap={8} style={{ alignItems: 'flex-end' }}>
        <Text weight="black" size={26}>
          Tiếng Trung
        </Text>
        <BrandTitle size={24}>中文</BrandTitle>
      </Row>
      <Text muted>Mỗi ngày vài từ, tích tiểu thành đại nha 🌸</Text>

      <SoftCard style={{ marginTop: 16 }} padding={18}>
        <Row>
          <View style={{ flex: 1 }}>
            <Text muted>Từ đã thuộc</Text>
            <Text weight="black" size={34}>
              {known}
              <Text muted size={16}>
                {' '}
                / {total}
              </Text>
            </Text>
            {current ? (
              <Text weight="bold" color={colors.pink}>
                Đang học: {current.name}
              </Text>
            ) : null}
          </View>
          <PercentRing value={total ? known / total : 0} label="đã thuộc" />
        </Row>
        {current ? (
          <Row style={{ marginTop: 14 }}>
            <GradientButton
              style={{ flex: 1 }}
              label="Flashcard"
              onPress={() => startFlashcards(current.name, studyOrder(progress, current.words).slice(0, 20))}
            />
            <OutlineButton
              style={{ flex: 1 }}
              label="Trắc nghiệm"
              onPress={() =>
                startVocabQuiz(current.name, studyOrder(progress, current.words).slice(0, 20), current.words, 'hanziToMeaning')
              }
            />
          </Row>
        ) : null}
      </SoftCard>

      <SectionTitle>Danh sách từ vựng</SectionTitle>
      {lists.map((l) => {
        const k = knownIn(progress, l.words);
        const hsk = /^HSK\s*(\d)/.exec(l.name);
        return (
          <SoftCard key={l.id} style={{ marginBottom: 10 }} padding={14} onPress={() => router.push(`/vocab/${l.id}`)}>
            <Row gap={14}>
              <View style={{ width: 52, height: 52, borderRadius: 14, backgroundColor: colors.blush, alignItems: 'center', justifyContent: 'center' }}>
                {hsk ? (
                  <>
                    <Text weight="black" size={10} color={colors.pink}>
                      HSK
                    </Text>
                    <Text weight="black" size={20} color={colors.pink}>
                      {hsk[1]}
                    </Text>
                  </>
                ) : (
                  <Text weight="black" size={22} color={colors.pink}>
                    词
                  </Text>
                )}
              </View>
              <View style={{ flex: 1, gap: 4 }}>
                <Text weight="heavy" size={16}>
                  {l.name}
                </Text>
                <Text muted size={13}>
                  {l.words.length} từ · đã thuộc {k}
                </Text>
                <ProgressBar value={l.words.length ? k / l.words.length : 0} height={5} />
              </View>
              <Text color={colors.muted} size={20}>
                ›
              </Text>
            </Row>
          </SoftCard>
        );
      })}
    </Screen>
  );
}
