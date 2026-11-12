import { Ionicons } from '@expo/vector-icons';
import { Stack, useLocalSearchParams } from 'expo-router';
import { Pressable, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { BrandTitle, GradientButton, Row, Screen, SoftCard, Text } from '@/components/ui';
import { tenses } from '@/lib/content';
import { openTenseQuiz, tenseDone } from '@/lib/english';
import { speak } from '@/lib/speech';
import { colors } from '@/lib/theme';
import { useStore } from '@/state/store';

/** Bài học một thì: công thức, cách dùng, dấu hiệu, lưu ý, rồi làm bài tập. */
export default function TenseScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const progress = useStore((s) => s.vocabProgress);
  const t = tenses.find((x) => x.id === id);
  if (!t) return null;

  return (
    <View style={{ flex: 1 }}>
      <Stack.Screen options={{ title: t.vi }} />
      <Screen edges={[]}>
        <SoftCard>
          <BrandTitle>{t.en}</BrandTitle>
          <Text style={{ lineHeight: 22 }}>{t.summary}</Text>
        </SoftCard>

        <Heading>📐 Công thức</Heading>
        {t.forms.map((f) => (
          <SoftCard key={f.label} style={{ marginBottom: 10 }}>
            <Text weight="black">{f.label}</Text>
            <View style={{ backgroundColor: colors.blush, borderRadius: 10, padding: 10, marginVertical: 8 }}>
              <Text weight="heavy" color={colors.pinkDeep} size={16}>
                {f.formula}
              </Text>
            </View>
            <Example en={f.example} vi={f.exampleVi} />
          </SoftCard>
        ))}

        <Heading>🎯 Cách dùng</Heading>
        {t.usage.map((u, i) => (
          <SoftCard key={i} style={{ marginBottom: 10 }}>
            <Text weight="heavy" style={{ marginBottom: 6 }}>
              {i + 1}. {u.text}
            </Text>
            <Example en={u.example} vi={u.exampleVi} />
          </SoftCard>
        ))}

        <Heading>🔍 Dấu hiệu nhận biết</Heading>
        <Row gap={8} style={{ flexWrap: 'wrap' }}>
          {t.signals.map((s) => (
            <View key={s} style={{ backgroundColor: colors.white, borderColor: colors.border, borderWidth: 1, borderRadius: 16, paddingHorizontal: 12, paddingVertical: 6 }}>
              <Text weight="bold" size={14}>
                {s}
              </Text>
            </View>
          ))}
        </Row>

        <Heading>💡 Lưu ý</Heading>
        <SoftCard>
          {t.tips.map((tip) => (
            <Text key={tip} style={{ lineHeight: 22, marginBottom: 4 }}>
              • {tip}
            </Text>
          ))}
        </SoftCard>
      </Screen>
      <SafeAreaView edges={['bottom']} style={{ paddingHorizontal: 20, paddingTop: 8 }}>
        <GradientButton
          label={`Làm bài tập (${tenseDone(progress, t)}/${t.exercises.length} câu đã đúng)`}
          onPress={() => openTenseQuiz(progress, t.vi, t.exercises)}
        />
      </SafeAreaView>
    </View>
  );
}

function Heading({ children }: { children: string }) {
  return (
    <Text weight="black" size={18} style={{ marginTop: 22, marginBottom: 10 }}>
      {children}
    </Text>
  );
}

function Example({ en, vi }: { en: string; vi: string }) {
  return (
    <Pressable onPress={() => speak(en, 'en-US')}>
      <Row gap={8} style={{ alignItems: 'flex-start' }}>
        <Ionicons name="volume-medium-outline" size={18} color={colors.pink} style={{ marginTop: 2 }} />
        <View style={{ flex: 1 }}>
          <Text style={{ fontStyle: 'italic' }}>{en}</Text>
          <Text muted size={13}>
            {vi}
          </Text>
        </View>
      </Row>
    </Pressable>
  );
}
