import { Baloo2_800ExtraBold } from '@expo-google-fonts/baloo-2';
import {
  Nunito_400Regular,
  Nunito_600SemiBold,
  Nunito_700Bold,
  Nunito_800ExtraBold,
  Nunito_900Black,
  useFonts,
} from '@expo-google-fonts/nunito';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { AppState } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { colors, fonts } from '@/lib/theme';
import { boot, sync, useStore } from '@/state/store';

SplashScreen.preventAutoHideAsync().catch(() => {});

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    Nunito_400Regular,
    Nunito_600SemiBold,
    Nunito_700Bold,
    Nunito_800ExtraBold,
    Nunito_900Black,
    Baloo2_800ExtraBold,
  });
  const booted = useStore((s) => s.booted);
  const signedIn = useStore((s) => !!s.profile);

  useEffect(() => {
    boot();
    // Pull fresh data (and push offline answers) whenever the app comes back.
    const sub = AppState.addEventListener('change', (state) => {
      if (state === 'active') sync();
    });
    return () => sub.remove();
  }, []);

  const ready = fontsLoaded && booted;
  useEffect(() => {
    if (ready) SplashScreen.hideAsync().catch(() => {});
  }, [ready]);
  if (!ready) return null;

  return (
    <SafeAreaProvider>
      <StatusBar style="dark" />
      <Stack
        screenOptions={{
          headerTintColor: colors.text,
          headerTitleStyle: { fontFamily: fonts.heavy, fontSize: 17 },
          headerStyle: { backgroundColor: colors.background },
          headerShadowVisible: false,
          headerBackButtonDisplayMode: 'minimal',
          contentStyle: { backgroundColor: colors.background },
        }}
      >
        <Stack.Protected guard={signedIn}>
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="deck/[id]" options={{ title: '' }} />
          <Stack.Screen name="quiz" options={{ title: '' }} />
          <Stack.Screen name="session-result" options={{ title: 'Kết quả', headerBackVisible: false }} />
          <Stack.Screen name="vocab/[id]" options={{ title: '' }} />
          <Stack.Screen name="flashcards" options={{ title: '' }} />
          <Stack.Screen name="vocab-quiz" options={{ title: '' }} />
          <Stack.Screen name="pronounce" options={{ title: 'Phát âm' }} />
          <Stack.Screen name="writing" options={{ title: 'Tập viết' }} />
          <Stack.Screen name="tense/[id]" options={{ title: '' }} />
          <Stack.Screen name="tense-quiz" options={{ title: '' }} />
        </Stack.Protected>
        <Stack.Protected guard={!signedIn}>
          <Stack.Screen name="login" options={{ headerShown: false }} />
          <Stack.Screen name="register" options={{ title: 'Tạo tài khoản' }} />
          <Stack.Screen name="profile-setup" options={{ headerShown: false, gestureEnabled: false }} />
        </Stack.Protected>
      </Stack>
    </SafeAreaProvider>
  );
}
