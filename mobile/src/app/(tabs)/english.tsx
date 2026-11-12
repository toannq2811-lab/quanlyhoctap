import { router } from 'expo-router';
import { View } from 'react-native';

import { BrandTitle, GradientButton, IconTile, OutlineButton, PercentRing, ProgressBar, Row, Screen, SectionTitle, SoftCard, Text } from '@/components/ui';
import { allExercises, englishTopics, englishWords, tenses } from '@/lib/content';
import { openTenseQuiz, tenseDone } from '@/lib/english';
import { startFlashcards } from '@/lib/nav';
import { colors } from '@/lib/theme';
import { knownIn, studyOrder, useStore } from '@/state/store';

/** Tiếng Anh cho người mất gốc: 12 thì + từ vựng theo chủ đề. */
export default function EnglishTab() {
  const progress = useStore((s) => s.vocabProgress);
  const known = knownIn(progress, englishWords);
  const exercisesDone = tenses.reduce((n, t) => n + tenseDone(progress, t), 0);
  const next = englishTopics.find((t) => knownIn(progress, t.list.words) < t.list.words.length) ?? englishTopics[0];

  return (
    <Screen>
      <Row gap={8} style={{ alignItems: 'flex-end' }}>
        <Text weight="black" size={26}>
          Tiếng Anh
        </Text>
        <BrandTitle size={24}>ABC</BrandTitle>
      </Row>
      <Text muted>Học lại từ đầu, chậm mà chắc 🌱</Text>

      <SoftCard style={{ marginTop: 16 }} padding={18}>
        <Row>
          <View style={{ flex: 1 }}>
            <Text muted>Từ đã thuộc</Text>
            <Text weight="black" size={34}>
              {known}
              <Text muted size={16}>
                {' '}
                / {englishWords.length}
              </Text>
            </Text>
            <Text weight="bold" color={colors.pink}>
              Ngữ pháp: đúng {exercisesDone}/{allExercises.length} bài tập
            </Text>
          </View>
          <PercentRing value={englishWords.length ? known / englishWords.length : 0} label="từ vựng" />
        </Row>
        <Row style={{ marginTop: 14 }}>
          <GradientButton
            style={{ flex: 1 }}
            label="Flashcard"
            onPress={next ? () => startFlashcards(next.list.name, studyOrder(progress, next.list.words).slice(0, 20)) : undefined}
          />
          <OutlineButton style={{ flex: 1 }} label="🔀 Ôn các thì" onPress={() => openTenseQuiz(progress, 'Ôn tổng hợp các thì', allExercises, 20)} />
        </Row>
      </SoftCard>

      <SectionTitle hint="Học lần lượt từ trên xuống nhé — mỗi thì có bài học + 12 bài tập">Ngữ pháp: 12 thì</SectionTitle>
      {tenses.map((t) => {
        const done = tenseDone(progress, t);
        const total = t.exercises.length;
        return (
          <SoftCard key={t.id} style={{ marginBottom: 10 }} padding={14} onPress={() => router.push(`/tense/${t.id}`)}>
            <Row gap={14}>
              <IconTile done={done === total}>{done === total ? '✓' : t.order}</IconTile>
              <View style={{ flex: 1, gap: 3 }}>
                <Text weight="heavy" size={16}>
                  {t.vi}
                </Text>
                <Text muted size={13}>
                  {t.en} · đúng {done}/{total}
                </Text>
                <ProgressBar value={total ? done / total : 0} height={5} />
              </View>
              <Text color={colors.muted} size={20}>
                ›
              </Text>
            </Row>
          </SoftCard>
        );
      })}

      <SectionTitle>Từ vựng theo chủ đề</SectionTitle>
      {englishTopics.map((t) => {
        const k = knownIn(progress, t.list.words);
        return (
          <SoftCard key={t.list.id} style={{ marginBottom: 10 }} padding={14} onPress={() => router.push(`/vocab/${t.list.id}`)}>
            <Row gap={14}>
              <IconTile>
                <Text size={22}>{t.icon}</Text>
              </IconTile>
              <View style={{ flex: 1, gap: 3 }}>
                <Text weight="heavy" size={16}>
                  {t.list.name}
                </Text>
                <Text muted size={13}>
                  {t.list.words.length} từ · đã thuộc {k}
                </Text>
                <ProgressBar value={t.list.words.length ? k / t.list.words.length : 0} height={5} />
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
