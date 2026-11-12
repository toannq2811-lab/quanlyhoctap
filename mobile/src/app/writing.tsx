import { router, Stack } from 'expo-router';
import { useEffect, useRef, useState } from 'react';
import { ActivityIndicator, PanResponder, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import Svg, { G, Line, Path, Polyline } from 'react-native-svg';

import { GradientButton, OutlineButton, Row, Text } from '@/components/ui';
import { speak } from '@/lib/speech';
import { colors } from '@/lib/theme';
import { recordAnswer, useStore } from '@/state/store';

// Stroke data of hanzi-writer (strokes as SVG paths + medians), 1024×1024 with y up.
type CharData = { strokes: string[]; medians: [number, number][][] };
const cache = new Map<string, Promise<CharData>>();
function loadChar(ch: string) {
  let p = cache.get(ch);
  if (!p) {
    p = fetch(`https://cdn.jsdelivr.net/npm/hanzi-writer-data@2.0/${encodeURIComponent(ch)}.json`).then((r) => {
      if (!r.ok) throw new Error('missing');
      return r.json();
    });
    p.catch(() => cache.delete(ch));
    cache.set(ch, p);
  }
  return p;
}

const SIZE = 300;
const toData = (x: number, y: number): [number, number] => [(x / SIZE) * 1024, 900 - (y / SIZE) * 1024];
const dist = (a: [number, number], b: [number, number]) => Math.hypot(a[0] - b[0], a[1] - b[1]);

/** Spreads `n` points evenly along a polyline. */
function resample(points: [number, number][], n: number): [number, number][] {
  const lengths = [0];
  for (let i = 1; i < points.length; i++) lengths.push(lengths[i - 1] + dist(points[i - 1], points[i]));
  const total = lengths[lengths.length - 1] || 1;
  const out: [number, number][] = [];
  for (let k = 0; k < n; k++) {
    const t = (k / (n - 1)) * total;
    let i = lengths.findIndex((l) => l >= t);
    if (i <= 0) i = 1;
    const seg = lengths[i] - lengths[i - 1] || 1;
    const f = (t - lengths[i - 1]) / seg;
    const a = points[i - 1] ?? points[0];
    const b = points[i] ?? a;
    out.push([a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f]);
  }
  return out;
}

/** A drawn stroke matches when it follows the stroke's median in the right direction. */
function matches(drawn: [number, number][], median: [number, number][]) {
  if (drawn.length < 2) return false;
  const a = resample(drawn, 12);
  const b = resample(median, 12);
  const avg = a.reduce((s, p, i) => s + dist(p, b[i]), 0) / a.length;
  return dist(a[0], b[0]) < 260 && dist(a[11], b[11]) < 260 && avg < 190;
}

/** Tập viết: watch the stroke order, then trace each stroke with a finger. */
export default function WritingScreen() {
  const session = useStore((s) => s.vocab);
  const words = (session?.words ?? []).filter((w) => /[㐀-鿿]/.test(w.hanzi));
  const [wordIndex, setWordIndex] = useState(0);
  const [charIndex, setCharIndex] = useState(0);
  const [loaded, setLoaded] = useState<{ ch: string; data?: CharData; error?: boolean } | null>(null);
  const [done, setDone] = useState(0); // strokes finished
  const [shown, setShown] = useState<number | null>(null); // animation: strokes revealed
  const [drawing, setDrawing] = useState<[number, number][]>([]);
  const [misses, setMisses] = useState(0);
  const [mistakes, setMistakes] = useState(0);

  const word = words[wordIndex];
  const chars = word ? [...word.hanzi].filter((c) => /[㐀-鿿]/.test(c)) : [];
  const ch = chars[charIndex];
  const data = loaded?.ch === ch ? (loaded.data ?? null) : null;
  const error = loaded?.ch === ch && !!loaded.error;

  useEffect(() => {
    if (!ch) return;
    loadChar(ch).then(
      (d) => setLoaded({ ch, data: d }),
      () => setLoaded({ ch, error: true }),
    );
  }, [ch]);

  // Read by the touch handlers, which are created once.
  const state = useRef({ data, done, misses });
  useEffect(() => {
    state.current = { data, done, misses };
  }, [data, done, misses]);

  useEffect(() => {
    if (shown === null || !data) return;
    if (shown >= data.strokes.length) {
      const t = setTimeout(() => setShown(null), 800);
      return () => clearTimeout(t);
    }
    const t = setTimeout(() => setShown(shown + 1), 550);
    return () => clearTimeout(t);
  }, [shown, data]);

  const [pan] = useState(() =>
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onPanResponderGrant: (e) => setDrawing([[e.nativeEvent.locationX, e.nativeEvent.locationY]]),
      onPanResponderMove: (e) => setDrawing((d) => [...d, [e.nativeEvent.locationX, e.nativeEvent.locationY]]),
      onPanResponderRelease: () =>
        setDrawing((d) => {
          const { data: cd, done: k, misses: m } = state.current;
          if (cd && k < cd.medians.length) {
            if (matches(d.map(([x, y]) => toData(x, y)), cd.medians[k])) {
              setDone(k + 1);
              setMisses(0);
            } else {
              setMisses(m + 1);
              setMistakes((n) => n + 1);
            }
          }
          return [];
        }),
    }),
  );

  if (!word) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <Text muted>Không có chữ Hán để tập viết</Text>
      </View>
    );
  }

  const charDone = !!data && done >= data.strokes.length;
  const last = charIndex === chars.length - 1;

  function resetStrokes() {
    setDone(0);
    setMisses(0);
  }

  function next() {
    resetStrokes();
    if (!last) {
      setCharIndex(charIndex + 1);
      return;
    }
    recordAnswer(word, mistakes <= 2);
    setMistakes(0);
    if (wordIndex === words.length - 1) router.back();
    else {
      setWordIndex(wordIndex + 1);
      setCharIndex(0);
    }
  }

  const hint = data && !charDone && misses >= 2 ? done : -1;
  return (
    <SafeAreaView style={{ flex: 1, padding: 20, alignItems: 'center' }} edges={['bottom']}>
      <Stack.Screen options={{ title: `Tập viết · ${wordIndex + 1}/${words.length}` }} />
      <Text weight="black" size={30}>
        {word.hanzi}
      </Text>
      <Text weight="bold" color={colors.pink} size={18}>
        {word.pinyin}
      </Text>
      <Text muted style={{ textAlign: 'center', marginBottom: 14 }}>
        {word.meaning}
      </Text>

      <View style={styles.board} {...(shown === null && !charDone ? pan.panHandlers : {})}>
        <Svg width={SIZE} height={SIZE}>
          <Line x1={0} y1={0} x2={SIZE} y2={SIZE} stroke={colors.border} strokeDasharray="6 6" />
          <Line x1={SIZE} y1={0} x2={0} y2={SIZE} stroke={colors.border} strokeDasharray="6 6" />
          <Line x1={SIZE / 2} y1={0} x2={SIZE / 2} y2={SIZE} stroke={colors.border} strokeDasharray="6 6" />
          <Line x1={0} y1={SIZE / 2} x2={SIZE} y2={SIZE / 2} stroke={colors.border} strokeDasharray="6 6" />
          {data ? (
            <G transform={`scale(${SIZE / 1024}) translate(0, 900) scale(1, -1)`}>
              {data.strokes.map((d, i) => {
                const fill =
                  shown !== null
                    ? i < shown
                      ? colors.pink
                      : '#F4E9EE'
                    : i < done
                      ? colors.text
                      : i === hint
                        ? colors.pinkLight
                        : '#F4E9EE';
                return <Path key={i} d={d} fill={fill} />;
              })}
            </G>
          ) : null}
          {drawing.length > 1 ? (
            <Polyline points={drawing.map((p) => p.join(',')).join(' ')} stroke={colors.pink} strokeWidth={10} strokeLinecap="round" strokeLinejoin="round" fill="none" />
          ) : null}
        </Svg>
        {!data && !error ? <ActivityIndicator style={StyleSheet.absoluteFill} color={colors.pink} /> : null}
      </View>

      <Text muted size={13} style={{ marginTop: 10, textAlign: 'center' }}>
        {error
          ? 'Chưa tải được nét chữ, kiểm tra mạng nhé'
          : charDone
            ? 'Viết đúng rồi! 🎉'
            : shown !== null
              ? 'Xem thứ tự nét…'
              : `Chữ ${charIndex + 1}/${chars.length} · viết nét ${Math.min(done + 1, data?.strokes.length ?? 1)}/${data?.strokes.length ?? '?'}${misses >= 2 ? ' · nét gợi ý màu hồng' : ''}`}
      </Text>

      <View style={{ flex: 1 }} />
      <Row gap={10} style={{ alignSelf: 'stretch' }}>
        <OutlineButton small icon="🔊" label="Nghe" onPress={() => speak(word.hanzi)} />
        <OutlineButton
          small
          label="Xem cách viết"
          onPress={data ? () => {
            setDone(0);
            setShown(0);
          } : undefined}
        />
        <OutlineButton small label="Viết lại" onPress={resetStrokes} />
      </Row>
      <GradientButton
        style={{ alignSelf: 'stretch', marginTop: 12 }}
        label={!last ? 'Chữ tiếp theo ›' : wordIndex === words.length - 1 ? 'Xong' : 'Từ tiếp theo ›'}
        onPress={charDone || error ? next : undefined}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  board: {
    width: SIZE,
    height: SIZE,
    backgroundColor: colors.white,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.border,
    overflow: 'hidden',
  },
});
