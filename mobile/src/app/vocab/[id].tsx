import { Ionicons } from '@expo/vector-icons';
import { Stack, useLocalSearchParams } from 'expo-router';
import { useMemo, useState } from 'react';
import { ActionSheetIOS, Alert, FlatList, Platform, Pressable, TextInput, View } from 'react-native';

import { Chip, GradientButton, OutlineButton, Row, SoftCard, Text } from '@/components/ui';
import { englishTopics } from '@/lib/content';
import { startFlashcards, startPronounce, startVocabQuiz, startWriting } from '@/lib/nav';
import { speak } from '@/lib/speech';
import { colors, fonts } from '@/lib/theme';
import { isEnglish, speechLang, type VocabWord } from '@/lib/types';
import { chineseLists, knownIn, progressOf, setKnown, studyOrder, useStore, type VocabMode } from '@/state/store';

type Filter = 'all' | 'unknown' | 'known';

/** One vocabulary list (HSK, imported, or an English topic): words + ways to study. */
export default function VocabListScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const progress = useStore((s) => s.vocabProgress);
  const custom = useStore((s) => s.customLists);
  const list = useMemo(
    () => [...chineseLists(custom), ...englishTopics.map((t) => t.list)].find((l) => l.id === id),
    [custom, id],
  );
  const [filter, setFilter] = useState<Filter>('all');
  const [query, setQuery] = useState('');
  const [open, setOpen] = useState<string | null>(null);
  if (!list) return null;

  const english = list.words.length > 0 && isEnglish(list.words[0]);
  const known = knownIn(progress, list.words);
  const q = query.trim().toLowerCase();
  const shown = list.words.filter((w) => {
    const k = progress[w.id]?.known ?? false;
    if (filter === 'known' && !k) return false;
    if (filter === 'unknown' && k) return false;
    return !q || w.hanzi.toLowerCase().includes(q) || w.pinyin.toLowerCase().includes(q) || w.meaning.toLowerCase().includes(q);
  });
  const batch = () => studyOrder(progress, list.words).slice(0, 20);

  function chooseQuiz() {
    const modes: [string, VocabMode][] = english
      ? [
          ['Nhìn từ → chọn nghĩa', 'hanziToMeaning'],
          ['Nhìn nghĩa → chọn từ', 'meaningToHanzi'],
          ['Nghe → chọn từ', 'listen'],
        ]
      : [
          ['Nhìn chữ Hán → chọn nghĩa', 'hanziToMeaning'],
          ['Nhìn nghĩa → chọn chữ Hán', 'meaningToHanzi'],
          ['Nghe → chọn chữ Hán', 'listen'],
        ];
    const run = (m: VocabMode) => startVocabQuiz(list!.name, batch(), list!.words, m);
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        { title: 'Kiểu trắc nghiệm (20 từ)', options: [...modes.map((m) => m[0]), 'Hủy'], cancelButtonIndex: modes.length },
        (i) => modes[i] && run(modes[i][1]),
      );
    } else {
      Alert.alert('Kiểu trắc nghiệm', undefined, [...modes.map(([text, m]) => ({ text, onPress: () => run(m) })), { text: 'Hủy', style: 'cancel' }]);
    }
  }

  return (
    <View style={{ flex: 1 }}>
      <Stack.Screen options={{ title: list.name }} />
      <FlatList
        data={shown}
        keyExtractor={(w) => w.id}
        contentContainerStyle={{ padding: 20, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
        ListHeaderComponent={
          <View style={{ gap: 12, marginBottom: 12 }}>
            <Text muted>
              {list.words.length} từ · đã thuộc {known}
            </Text>
            <Row>
              <GradientButton style={{ flex: 1 }} label="Flashcard" onPress={() => startFlashcards(list.name, batch())} />
              <OutlineButton style={{ flex: 1 }} label="Trắc nghiệm" onPress={chooseQuiz} />
            </Row>
            <Row>
              {!english ? <OutlineButton style={{ flex: 1 }} label="✍️ Tập viết" onPress={() => startWriting(list.name, batch().slice(0, 10))} /> : null}
              <OutlineButton style={{ flex: 1 }} label="🎤 Phát âm" onPress={() => startPronounce(list.name, batch().slice(0, 10))} />
            </Row>
            <TextInput
              placeholder="Tìm từ, phiên âm, nghĩa…"
              placeholderTextColor={colors.muted}
              value={query}
              onChangeText={setQuery}
              style={{
                backgroundColor: colors.white,
                borderWidth: 1,
                borderColor: colors.border,
                borderRadius: 14,
                paddingHorizontal: 14,
                paddingVertical: 11,
                fontFamily: fonts.semibold,
                fontSize: 15,
                color: colors.text,
              }}
            />
            <Row gap={8}>
              <Chip label="Tất cả" selected={filter === 'all'} onPress={() => setFilter('all')} />
              <Chip label="Chưa thuộc" selected={filter === 'unknown'} onPress={() => setFilter('unknown')} />
              <Chip label="Đã thuộc" selected={filter === 'known'} onPress={() => setFilter('known')} />
            </Row>
          </View>
        }
        renderItem={({ item }) => (
          <WordRow word={item} known={progressOf(progress, item).known} open={open === item.id} onToggle={() => setOpen(open === item.id ? null : item.id)} english={english} />
        )}
      />
    </View>
  );
}

function WordRow({ word, known, open, onToggle, english }: { word: VocabWord; known: boolean; open: boolean; onToggle: () => void; english: boolean }) {
  return (
    <SoftCard style={{ marginBottom: 8 }} padding={12} onPress={onToggle}>
      <Row>
        <View style={{ flex: 1 }}>
          <Row gap={8}>
            <Text weight="black" size={english ? 18 : 22}>
              {word.hanzi}
            </Text>
            <Text color={colors.pink} weight="semibold">
              {word.pinyin}
            </Text>
          </Row>
          <Text muted numberOfLines={open ? undefined : 1}>
            {word.meaning}
          </Text>
        </View>
        <Pressable onPress={() => speak(word.hanzi, speechLang(word))} hitSlop={8}>
          <Ionicons name="volume-high" size={22} color={colors.pink} />
        </Pressable>
        <Pressable onPress={() => setKnown(word, !known)} hitSlop={8}>
          <Ionicons name={known ? 'checkmark-circle' : 'ellipse-outline'} size={24} color={known ? colors.green : colors.muted} />
        </Pressable>
      </Row>
      {open && word.example ? (
        <View style={{ marginTop: 8, padding: 10, backgroundColor: colors.blush, borderRadius: 10 }}>
          <Text weight="semibold">{word.example}</Text>
          {word.exampleVi ? <Text muted size={13}>{word.exampleVi}</Text> : null}
        </View>
      ) : null}
    </SoftCard>
  );
}
