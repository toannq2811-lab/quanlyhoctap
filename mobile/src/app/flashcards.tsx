import { Ionicons } from '@expo/vector-icons';
import { router, Stack } from 'expo-router';
import { useEffect, useState } from 'react';
import { Animated, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GradientButton, Mascot, OutlineButton, ProgressBar, Row, Text } from '@/components/ui';
import { speak } from '@/lib/speech';
import { colors } from '@/lib/theme';
import { isEnglish, speechLang, type VocabWord } from '@/lib/types';
import { setKnown, useStore } from '@/state/store';

/** Flashcards: tap to flip, then "Chưa thuộc" / "Đã thuộc". */
export default function FlashcardsScreen() {
  const session = useStore((s) => s.vocab);
  const [words, setWords] = useState<VocabWord[]>(session?.words ?? []);
  const [index, setIndex] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [knownNow, setKnownNow] = useState<VocabWord[]>([]);
  const [unknownNow, setUnknownNow] = useState<VocabWord[]>([]);
  const [flip] = useState(() => new Animated.Value(0));

  const word = words[index];
  useEffect(() => {
    if (word) speak(word.hanzi, speechLang(word));
  }, [word]);

  if (!session) return null;
  const finished = index >= words.length;

  function turn() {
    Animated.spring(flip, { toValue: flipped ? 0 : 1, useNativeDriver: true, friction: 8 }).start();
    setFlipped(!flipped);
  }

  function answer(known: boolean) {
    setKnown(word, known);
    (known ? setKnownNow : setUnknownNow)((l) => [...l, word]);
    flip.setValue(0);
    setFlipped(false);
    setIndex(index + 1);
  }

  function again() {
    setWords([...unknownNow].sort(() => Math.random() - 0.5));
    setKnownNow([]);
    setUnknownNow([]);
    setIndex(0);
  }

  if (finished) {
    return (
      <SafeAreaView style={styles.done} edges={['bottom']}>
        <Stack.Screen options={{ title: session.title }} />
        <Mascot size={130} />
        <Text weight="black" size={24}>
          {unknownNow.length ? 'Xong một lượt 💕' : 'Thuộc hết rồi! 🎉'}
        </Text>
        <Text muted>
          Đã thuộc {knownNow.length} · Chưa thuộc {unknownNow.length}
        </Text>
        <View style={{ alignSelf: 'stretch', gap: 10, marginTop: 20 }}>
          {unknownNow.length ? <GradientButton label={`Học lại ${unknownNow.length} từ`} onPress={again} /> : null}
          <OutlineButton label="Xong" onPress={() => router.back()} />
        </View>
      </SafeAreaView>
    );
  }

  const english = isEnglish(word);
  const front = flip.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '180deg'] });
  const back = flip.interpolate({ inputRange: [0, 1], outputRange: ['180deg', '360deg'] });

  return (
    <SafeAreaView style={{ flex: 1, padding: 20 }} edges={['bottom']}>
      <Stack.Screen options={{ title: `${index + 1}/${words.length}` }} />
      <ProgressBar value={(index + 1) / words.length} />
      <Pressable style={{ flex: 1, marginVertical: 20 }} onPress={turn}>
        <Animated.View style={[styles.card, { transform: [{ perspective: 1000 }, { rotateY: front }] }]}>
          <Text weight="black" size={english ? 40 : 72} style={{ textAlign: 'center' }}>
            {word.hanzi}
          </Text>
          <Text muted style={styles.hint}>
            Chạm để lật thẻ
          </Text>
        </Animated.View>
        <Animated.View style={[styles.card, styles.back, { transform: [{ perspective: 1000 }, { rotateY: back }] }]}>
          <Text weight="black" size={english ? 32 : 56} style={{ textAlign: 'center' }}>
            {word.hanzi}
          </Text>
          <Text weight="bold" size={22} color={colors.pink} style={{ marginTop: 6 }}>
            {word.pinyin}
          </Text>
          <Text size={18} style={{ textAlign: 'center', marginTop: 10 }}>
            {word.meaning}
          </Text>
          {word.example ? (
            <View style={{ marginTop: 16, alignItems: 'center' }}>
              <Text weight="semibold" style={{ textAlign: 'center' }}>
                {word.example}
              </Text>
              {word.exampleVi ? (
                <Text muted size={13} style={{ textAlign: 'center' }}>
                  {word.exampleVi}
                </Text>
              ) : null}
            </View>
          ) : null}
        </Animated.View>
        <Pressable style={styles.speaker} onPress={() => speak(word.hanzi, speechLang(word))} hitSlop={10}>
          <Ionicons name="volume-high" size={26} color={colors.pink} />
        </Pressable>
      </Pressable>
      <Row gap={12}>
        <OutlineButton style={{ flex: 1 }} label="✗ Chưa thuộc" color={colors.red} onPress={() => answer(false)} />
        <GradientButton style={{ flex: 1 }} label="✓ Đã thuộc" onPress={() => answer(true)} />
      </Row>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  card: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: colors.white,
    borderRadius: 28,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backfaceVisibility: 'hidden',
    shadowColor: colors.pink,
    shadowOpacity: 0.12,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 6 },
  },
  back: { backgroundColor: '#FFFAFC' },
  hint: { position: 'absolute', bottom: 22 },
  speaker: { position: 'absolute', top: 16, right: 16 },
  done: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 6 },
});
