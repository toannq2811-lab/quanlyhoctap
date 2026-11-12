import { Ionicons } from '@expo/vector-icons';
import { Tabs } from 'expo-router';
import { Text, type ColorValue } from 'react-native';

import { colors, fonts } from '@/lib/theme';

const letter = (s: string, size: number) =>
  function TabLetter({ color }: { color: ColorValue }) {
    return <Text style={{ fontFamily: fonts.black, fontSize: size, color }}>{s}</Text>;
  };

const icon = (name: keyof typeof Ionicons.glyphMap) =>
  function TabIcon({ color, size }: { color: ColorValue; size: number }) {
    return <Ionicons name={name} size={size} color={color as string} />;
  };

/** Trang chủ · Luyện tập · Trung · Anh · Kết quả · Cài đặt */
export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.pink,
        tabBarInactiveTintColor: colors.muted,
        tabBarLabelStyle: { fontFamily: fonts.bold, fontSize: 11 },
        tabBarStyle: { backgroundColor: colors.white, borderTopColor: colors.border },
        sceneStyle: { backgroundColor: colors.background },
      }}
    >
      <Tabs.Screen name="index" options={{ title: 'Trang chủ', tabBarIcon: icon('home') }} />
      <Tabs.Screen name="practice" options={{ title: 'Luyện tập', tabBarIcon: icon('book') }} />
      <Tabs.Screen name="chinese" options={{ title: 'Trung', tabBarIcon: letter('中', 20) }} />
      <Tabs.Screen name="english" options={{ title: 'Anh', tabBarIcon: letter('En', 17) }} />
      <Tabs.Screen name="results" options={{ title: 'Kết quả', tabBarIcon: icon('bar-chart') }} />
      <Tabs.Screen name="settings" options={{ title: 'Cài đặt', tabBarIcon: icon('settings') }} />
    </Tabs>
  );
}
