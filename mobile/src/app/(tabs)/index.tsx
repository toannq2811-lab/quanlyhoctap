import { router } from 'expo-router';
import { useState } from 'react';
import { Pressable, RefreshControl, ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Avatar } from '@/components/Avatar';
import { GradientButton, IconTile, OutlineButton, ProgressBar, Row, SectionTitle, SoftCard, Text } from '@/components/ui';
import { allExercises, englishWords, exerciseWord } from '@/lib/content';
import { startFlashcards, startQuiz } from '@/lib/nav';
import { colors } from '@/lib/theme';
import { allQuestions, shuffle } from '@/lib/types';
import { chineseLists, dayKey, knownIn, statsOf, streakOf, studyOrder, sync, useStore } from '@/state/store';

const weekdays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];

/** 3. Trang chủ — greeting, streak, daily goal, what to study next. */
export default function HomeTab() {
  const s = useStore();
  const [refreshing, setRefreshing] = useState(false);
  const now = new Date();
  const today = s.activity[dayKey(now)] ?? 0;
  const birthday = s.profile?.birthday?.slice(5) === dayKey(now).slice(5);
  const lists = chineseLists(s.customLists);
  const nextList = lists.find((l) => knownIn(s.vocabProgress, l.words) < l.words.length) ?? lists[0];

  const cheer =
    today >= s.dailyGoal
      ? 'Hôm nay xong mục tiêu rồi, giỏi quá! 🎉'
      : today > 0
        ? `Còn ${s.dailyGoal - today} câu nữa là đạt mục tiêu!`
        : 'Hôm nay cố gắng thêm một chút nhé!';

  async function refresh() {
    setRefreshing(true);
    await sync();
    setRefreshing(false);
  }

  return (
    <SafeAreaView style={{ flex: 1 }} edges={['top']}>
      <ScrollView
        contentContainerStyle={{ padding: 20, paddingBottom: 32 }}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={refresh} tintColor={colors.pink} />}
      >
        <Row>
          <View style={{ flex: 1 }}>
            <Text weight="heavy" size={13} color={colors.pink}>
              {weekdays[now.getDay()]}, {now.getDate()}/{now.getMonth() + 1}
            </Text>
            <Text weight="black" size={26}>
              Chào {s.profile?.name ?? 'em'}! 💕
            </Text>
            <Text muted>{cheer}</Text>
          </View>
          <Pressable onPress={() => router.navigate('/settings')}>
            <Avatar profile={s.profile} size={52} />
          </Pressable>
        </Row>

        {s.offline ? (
          <SoftCard style={{ marginTop: 14, backgroundColor: colors.blush }} padding={12}>
            <Text size={13}>📡 Đang offline — bài làm vẫn được lưu và sẽ đồng bộ khi có mạng</Text>
          </SoftCard>
        ) : null}
        {birthday ? (
          <SoftCard style={{ marginTop: 14 }}>
            <Row>
              <Text size={32}>🎂</Text>
              <Text weight="heavy" style={{ flex: 1 }}>
                Chúc mừng sinh nhật {s.profile?.name ?? 'em'}! 🎉{'\n'}Chúc em thi thật tốt và luôn vui vẻ nha 💕
              </Text>
            </Row>
          </SoftCard>
        ) : null}

        <Row style={{ marginTop: 16 }} gap={12}>
          <SoftCard style={{ flex: 1 }}>
            <Text size={26}>🔥</Text>
            <Text weight="black" size={22}>
              {streakOf(s.activity)} ngày
            </Text>
            <Text muted size={12}>
              học liên tục
            </Text>
          </SoftCard>
          <SoftCard style={{ flex: 1 }}>
            <Text weight="heavy" size={13}>
              🎯 Hôm nay
            </Text>
            <Text weight="black" size={22}>
              {today}/{s.dailyGoal}
            </Text>
            <Text muted size={12} style={{ marginBottom: 6 }}>
              câu & từ
            </Text>
            <ProgressBar value={today / s.dailyGoal} color={today >= s.dailyGoal ? colors.green : colors.pink} />
          </SoftCard>
        </Row>

        <WeekCard activity={s.activity} />

        <SectionTitle>Học tiếp</SectionTitle>
        {s.decks.map((deck) => {
          const qs = allQuestions(deck);
          const st = statsOf(s.results, qs);
          const wrong = qs.filter((q) => s.results[q.id] === false);
          const fresh = qs.filter((q) => s.results[q.id] === undefined);
          return (
            <SoftCard key={deck.id} style={{ marginBottom: 12 }}>
              <Text weight="black" size={16}>
                {deck.name}
              </Text>
              <Text muted size={13} style={{ marginBottom: 8 }}>
                {st.done}/{st.total} câu · đúng {Math.round(st.accuracy * 100)}%
              </Text>
              <ProgressBar value={st.total ? st.done / st.total : 0} />
              <Row style={{ marginTop: 12 }}>
                <GradientButton
                  style={{ flex: 1 }}
                  label={fresh.length ? 'Làm tiếp' : 'Làm lại'}
                  onPress={() => startQuiz(deck.name, fresh.length ? fresh : qs)}
                />
                <OutlineButton
                  style={{ flex: 1 }}
                  label={`Ôn sai (${wrong.length})`}
                  onPress={wrong.length ? () => startQuiz('Ôn câu sai', shuffle(wrong)) : undefined}
                />
              </Row>
            </SoftCard>
          );
        })}

        <SoftCard style={{ marginBottom: 12 }} onPress={() => router.navigate('/chinese')}>
          <Row>
            <IconTile>中</IconTile>
            <View style={{ flex: 1 }}>
              <Text weight="black" size={16}>
                Tiếng Trung
              </Text>
              <Text muted size={13}>
                Đã thuộc {lists.reduce((n, l) => n + knownIn(s.vocabProgress, l.words), 0)}/
                {lists.reduce((n, l) => n + l.words.length, 0)} từ{nextList ? ` · đang học ${nextList.name}` : ''}
              </Text>
            </View>
            {nextList ? (
              <OutlineButton
                small
                label="Flashcard"
                onPress={() => startFlashcards(nextList.name, studyOrder(s.vocabProgress, nextList.words).slice(0, 20))}
              />
            ) : null}
          </Row>
        </SoftCard>

        <SoftCard style={{ marginBottom: 12 }} onPress={() => router.navigate('/english')}>
          <Row>
            <IconTile>En</IconTile>
            <View style={{ flex: 1 }}>
              <Text weight="black" size={16}>
                Tiếng Anh
              </Text>
              <Text muted size={13}>
                Thuộc {knownIn(s.vocabProgress, englishWords)}/{englishWords.length} từ · ngữ pháp{' '}
                {knownIn(s.vocabProgress, allExercises.map(exerciseWord))}/{allExercises.length} bài
              </Text>
            </View>
            <Text weight="heavy" color={colors.pink}>
              Mở ›
            </Text>
          </Row>
        </SoftCard>

        <SectionTitle>Bộ đề của bạn</SectionTitle>
        {s.decks.map((deck, i) => (
          <SoftCard key={deck.id} style={{ marginBottom: 12 }} onPress={() => router.push(`/deck/${deck.id}`)}>
            <Row>
              <IconTile>{i + 1}</IconTile>
              <View style={{ flex: 1 }}>
                <Text weight="heavy" size={16}>
                  {deck.name}
                </Text>
                <Text muted size={13}>
                  {allQuestions(deck).length} câu · {s.attempts.filter((a) => a.deckId === deck.id).length} lần làm
                </Text>
              </View>
              <Text color={colors.muted} size={20}>
                ›
              </Text>
            </Row>
          </SoftCard>
        ))}
        {!s.decks.length ? (
          <Text muted style={{ textAlign: 'center' }}>
            {s.syncing ? 'Đang tải bộ đề…' : 'Chưa có bộ đề nào. Kéo xuống để tải lại.'}
          </Text>
        ) : null}
      </ScrollView>
    </SafeAreaView>
  );
}

function WeekCard({ activity }: { activity: Record<string, number> }) {
  const days = [...Array(7)].map((_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    return { label: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][d.getDay()], n: activity[dayKey(d)] ?? 0 };
  });
  const max = Math.max(1, ...days.map((d) => d.n));
  return (
    <SoftCard style={{ marginTop: 12 }}>
      <Row style={{ justifyContent: 'space-between', marginBottom: 12 }}>
        <Text weight="black">7 ngày qua</Text>
        <Text muted size={13}>
          {days.reduce((a, d) => a + d.n, 0)} lượt
        </Text>
      </Row>
      <Row style={{ alignItems: 'flex-end', height: 90 }} gap={8}>
        {days.map((d, i) => (
          <View key={i} style={{ flex: 1, alignItems: 'center', gap: 4 }}>
            <Text size={10} muted>
              {d.n || ''}
            </Text>
            <View
              style={{
                width: '70%',
                height: Math.max(4, (d.n / max) * 56),
                borderRadius: 6,
                backgroundColor: i === 6 ? colors.pink : d.n ? colors.pinkLight : colors.blush,
              }}
            />
            <Text size={11} weight={i === 6 ? 'heavy' : 'regular'} color={i === 6 ? colors.pink : colors.muted}>
              {d.label}
            </Text>
          </View>
        ))}
      </Row>
    </SoftCard>
  );
}
