import { router } from 'expo-router';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, TextInput } from 'react-native';

import { GradientButton, Mascot, Text, inputStyle } from '@/components/ui';
import { errorText } from '@/lib/api';
import { colors } from '@/lib/theme';
import { register } from '@/state/store';

export default function RegisterScreen() {
  const [user, setUser] = useState('');
  const [password, setPassword] = useState('');
  const [again, setAgain] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit() {
    if (password !== again) {
      setError('Hai mật khẩu chưa khớp nhau');
      return;
    }
    setBusy(true);
    setError(null);
    try {
      const profile = await register(user, password);
      router.replace({ pathname: '/profile-setup', params: { username: profile.username } });
    } catch (e) {
      setError(errorText(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <KeyboardAvoidingView
      style={{ flex: 1, backgroundColor: colors.background }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView contentContainerStyle={{ padding: 24, alignItems: 'stretch' }} keyboardShouldPersistTaps="handled">
        <Mascot size={110} />
        <Text muted style={{ marginVertical: 16 }}>
          Tên đăng nhập gồm chữ không dấu, số, dấu . _ - (3–30 ký tự). Mật khẩu ít nhất 6 ký tự.
        </Text>
        <TextInput
          style={inputStyle}
          placeholder="Tên đăng nhập"
          placeholderTextColor={colors.muted}
          autoCapitalize="none"
          autoCorrect={false}
          value={user}
          onChangeText={setUser}
        />
        <TextInput
          style={inputStyle}
          placeholder="Mật khẩu"
          placeholderTextColor={colors.muted}
          secureTextEntry
          value={password}
          onChangeText={setPassword}
          textContentType="newPassword"
        />
        <TextInput
          style={inputStyle}
          placeholder="Nhập lại mật khẩu"
          placeholderTextColor={colors.muted}
          secureTextEntry
          value={again}
          onChangeText={setAgain}
          onSubmitEditing={submit}
        />
        {error ? (
          <Text color={colors.red} style={{ marginBottom: 12, textAlign: 'center' }}>
            {error}
          </Text>
        ) : null}
        <GradientButton label="Tạo tài khoản" onPress={submit} loading={busy} />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
