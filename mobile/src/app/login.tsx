import { Ionicons } from '@expo/vector-icons';
import { Image } from 'expo-image';
import { Link, router } from 'expo-router';
import { useEffect, useState } from 'react';
import { KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GradientButton, inputStyle, Row, Text } from '@/components/ui';
import { errorText } from '@/lib/api';
import { colors } from '@/lib/theme';
import { cachedProfile, login, useStore } from '@/state/store';

/** 2. Đăng nhập — greets the last user by name, "Nhớ mật khẩu" keeps the password. */
export default function LoginScreen() {
  const lastUser = useStore((s) => s.lastUser);
  const savedPassword = useStore((s) => s.savedPassword);
  const expired = useStore((s) => s.expiredNotice);
  const [user, setUser] = useState(lastUser ?? '');
  const [password, setPassword] = useState(savedPassword ?? '');
  const [remember, setRemember] = useState(savedPassword != null || !lastUser);
  const [show, setShow] = useState(false);
  const [name, setName] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (lastUser) cachedProfile(lastUser).then((p) => setName(p?.name ?? null));
  }, [lastUser]);

  async function submit() {
    setBusy(true);
    setError(null);
    try {
      const profile = await login(user, password, remember);
      if (!profile.name) router.push({ pathname: '/profile-setup', params: { username: profile.username } });
    } catch (e) {
      setError(errorText(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView contentContainerStyle={styles.body} keyboardShouldPersistTaps="handled">
          <Image source={require('../../assets/splash-icon.png')} style={styles.logo} contentFit="contain" />
          <Text weight="black" size={24} style={{ textAlign: 'center' }}>
            {name ? `Chào ${name}! 💕` : 'Chào mừng bạn 💕'}
          </Text>
          <Text muted style={{ textAlign: 'center', marginBottom: 20 }}>
            Đăng nhập để học tiếp nhé
          </Text>

          {expired ? (
            <View style={styles.notice}>
              <Text color={colors.pinkDeep} weight="bold" size={14}>
                Phiên đăng nhập đã hết hạn, đăng nhập lại nhé 💕
              </Text>
            </View>
          ) : null}

          <TextInput
            style={styles.input}
            placeholder="Tên đăng nhập"
            placeholderTextColor={colors.muted}
            autoCapitalize="none"
            autoCorrect={false}
            value={user}
            onChangeText={setUser}
            textContentType="username"
          />
          <View>
            <TextInput
              style={styles.input}
              placeholder="Mật khẩu"
              placeholderTextColor={colors.muted}
              secureTextEntry={!show}
              value={password}
              onChangeText={setPassword}
              onSubmitEditing={submit}
              textContentType="password"
            />
            <Pressable style={styles.eye} onPress={() => setShow(!show)} hitSlop={10}>
              <Ionicons name={show ? 'eye-off-outline' : 'eye-outline'} size={22} color={colors.muted} />
            </Pressable>
          </View>

          <Pressable onPress={() => setRemember(!remember)}>
            <Row gap={8} style={{ marginBottom: 16 }}>
              <Ionicons name={remember ? 'checkbox' : 'square-outline'} size={22} color={colors.pink} />
              <Text>Nhớ mật khẩu</Text>
            </Row>
          </Pressable>

          {error ? (
            <Text color={colors.red} style={{ marginBottom: 12, textAlign: 'center' }}>
              {error}
            </Text>
          ) : null}
          <GradientButton label="Đăng nhập" onPress={submit} loading={busy} />

          <Row style={{ justifyContent: 'center', marginTop: 18 }} gap={4}>
            <Text muted>Chưa có tài khoản?</Text>
            <Link href="/register">
              <Text weight="heavy" color={colors.pink}>
                Tạo tài khoản
              </Text>
            </Link>
          </Row>
          {busy ? (
            <Text muted size={12} style={{ textAlign: 'center', marginTop: 12 }}>
              Lần đầu máy chủ có thể mất ~1 phút để thức dậy…
            </Text>
          ) : null}
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}


const styles = StyleSheet.create({
  body: { padding: 24, paddingTop: 12, flexGrow: 1, justifyContent: 'center' },
  logo: { width: 200, height: 200, alignSelf: 'center', marginBottom: 8 },
  input: inputStyle,
  eye: { position: 'absolute', right: 14, top: 14 },
  notice: { backgroundColor: colors.blush, borderRadius: 12, padding: 12, marginBottom: 14 },
});
