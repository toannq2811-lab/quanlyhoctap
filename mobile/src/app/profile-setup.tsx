import { useLocalSearchParams } from 'expo-router';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { BrandTitle, GradientButton, Mascot, Row, Text, inputStyle } from '@/components/ui';
import { errorText } from '@/lib/api';
import { colors } from '@/lib/theme';
import { openUser, saveProfile } from '@/state/store';

/** After creating an account: "Bạn tên là gì?" + birthday, then into the app. */
export default function ProfileSetupScreen() {
  const { username } = useLocalSearchParams<{ username: string }>();
  const [name, setName] = useState('');
  const [day, setDay] = useState('');
  const [month, setMonth] = useState('');
  const [year, setYear] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit() {
    const d = Number(day);
    const m = Number(month);
    const y = Number(year);
    const date = new Date(y, m - 1, d);
    if (!name.trim()) return setError('Cho mình biết tên bạn nhé');
    if (!y || y < 1900 || date.getMonth() !== m - 1 || date.getDate() !== d || date > new Date()) {
      return setError('Ngày sinh chưa đúng, nhập dạng ngày / tháng / năm nhé');
    }
    setBusy(true);
    setError(null);
    try {
      const birthday = `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      const profile = await saveProfile(name, birthday);
      await openUser(profile);
    } catch (e) {
      setError(errorText(e));
      setBusy(false);
    }
  }

  const small = [inputStyle, { flex: 1, textAlign: 'center' as const }];
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView contentContainerStyle={{ padding: 24, flexGrow: 1, justifyContent: 'center' }}>
          <View style={{ alignItems: 'center', marginBottom: 16 }}>
            <Mascot size={120} />
            <BrandTitle size={28}>Xin chào {username}!</BrandTitle>
            <Text muted>Cho mình làm quen chút nha 💕</Text>
          </View>
          <Text weight="heavy" style={{ marginBottom: 6 }}>
            Bạn tên là gì?
          </Text>
          <TextInput
            style={inputStyle}
            placeholder="Ví dụ: Diễn"
            placeholderTextColor={colors.muted}
            value={name}
            onChangeText={setName}
          />
          <Text weight="heavy" style={{ marginBottom: 6 }}>
            Ngày sinh
          </Text>
          <Row gap={8}>
            <TextInput style={small} placeholder="Ngày" placeholderTextColor={colors.muted} keyboardType="number-pad" maxLength={2} value={day} onChangeText={setDay} />
            <TextInput style={small} placeholder="Tháng" placeholderTextColor={colors.muted} keyboardType="number-pad" maxLength={2} value={month} onChangeText={setMonth} />
            <TextInput style={[...small, { flex: 1.4 }]} placeholder="Năm" placeholderTextColor={colors.muted} keyboardType="number-pad" maxLength={4} value={year} onChangeText={setYear} />
          </Row>
          {error ? (
            <Text color={colors.red} style={{ marginBottom: 12, textAlign: 'center' }}>
              {error}
            </Text>
          ) : null}
          <GradientButton label="Bắt đầu học thôi" onPress={submit} loading={busy} style={{ marginTop: 8 }} />
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
