import { Ionicons } from '@expo/vector-icons';
import Constants from 'expo-constants';
import { ImageManipulator, SaveFormat } from 'expo-image-manipulator';
import * as ImagePicker from 'expo-image-picker';
import { useState } from 'react';
import { ActivityIndicator, Alert, Linking, Pressable, View } from 'react-native';

import { Avatar } from '@/components/Avatar';
import { Chip, Row, Screen, SectionTitle, SoftCard, Text } from '@/components/ui';
import { errorText } from '@/lib/api';
import { colors } from '@/lib/theme';
import { allQuestions } from '@/lib/types';
import { logout, resetProgress, setAvatar, setDailyGoal, sync, useStore } from '@/state/store';

const ADMIN_SITE = 'https://admin-dien.netlify.app';

/** Cài đặt — ảnh đại diện, mục tiêu mỗi ngày, đồng bộ, đăng xuất. */
export default function SettingsTab() {
  const profile = useStore((s) => s.profile);
  const goal = useStore((s) => s.dailyGoal);
  const syncing = useStore((s) => s.syncing);
  const offline = useStore((s) => s.offline);
  const decks = useStore((s) => s.decks);
  const [uploading, setUploading] = useState(false);

  async function changeAvatar() {
    const picked = await ImagePicker.launchImageLibraryAsync({ mediaTypes: 'images', allowsEditing: true, aspect: [1, 1], quality: 1 });
    if (picked.canceled || !picked.assets[0]) return;
    setUploading(true);
    try {
      const image = await ImageManipulator.manipulate(picked.assets[0].uri).resize({ width: 512 }).renderAsync();
      const saved = await image.saveAsync({ format: SaveFormat.JPEG, compress: 0.85 });
      await setAvatar(saved.uri);
    } catch (e) {
      Alert.alert('Không đổi được ảnh', errorText(e));
    } finally {
      setUploading(false);
    }
  }

  function avatarMenu() {
    const options: { text: string; style?: 'cancel' | 'destructive'; onPress?: () => void }[] = [
      { text: 'Chọn ảnh từ máy', onPress: changeAvatar },
    ];
    if (profile?.avatar_path) {
      options.push({
        text: 'Xóa ảnh',
        style: 'destructive',
        onPress: () => setAvatar(null).catch((e) => Alert.alert(errorText(e))),
      });
    }
    options.push({ text: 'Hủy', style: 'cancel' });
    Alert.alert('Ảnh đại diện', undefined, options);
  }

  function confirmReset() {
    Alert.alert('Làm lại từ đầu?', 'Xóa toàn bộ kết quả đã làm để ôn lại từ đầu?', [
      { text: 'Hủy', style: 'cancel' },
      {
        text: 'Xóa',
        style: 'destructive',
        onPress: () => resetProgress(decks.flatMap(allQuestions).map((q) => q.id)).catch((e) => Alert.alert(errorText(e))),
      },
    ]);
  }

  function confirmLogout() {
    Alert.alert('Đăng xuất?', undefined, [
      { text: 'Hủy', style: 'cancel' },
      { text: 'Đăng xuất', style: 'destructive', onPress: () => logout() },
    ]);
  }

  return (
    <Screen>
      <Text weight="black" size={24}>
        Cài đặt
      </Text>
      <SoftCard style={{ marginTop: 14, alignItems: 'center' }} padding={20}>
        <Pressable onPress={avatarMenu}>
          <Avatar profile={profile} size={96} />
          <View style={{ position: 'absolute', right: 0, bottom: 0, backgroundColor: colors.pink, borderRadius: 14, padding: 6 }}>
            {uploading ? <ActivityIndicator size="small" color="#fff" /> : <Ionicons name="camera" size={16} color="#fff" />}
          </View>
        </Pressable>
        <Text weight="black" size={20} style={{ marginTop: 10 }}>
          {profile?.name}
        </Text>
        <Text muted>@{profile?.username}</Text>
        {profile?.birthday ? (
          <Text muted size={13}>
            🎂 {profile.birthday.split('-').reverse().join('/')}
          </Text>
        ) : null}
      </SoftCard>

      <SectionTitle hint="Số câu & từ muốn làm mỗi ngày">🎯 Mục tiêu mỗi ngày</SectionTitle>
      <Row gap={8} style={{ flexWrap: 'wrap' }}>
        {[10, 20, 30, 50, 100].map((n) => (
          <Chip key={n} label={`${n}`} selected={goal === n} onPress={() => setDailyGoal(n)} />
        ))}
      </Row>

      <SectionTitle>Dữ liệu</SectionTitle>
      <Item
        icon="sync"
        title="Đồng bộ ngay"
        subtitle={syncing ? 'Đang đồng bộ…' : offline ? 'Đang offline — sẽ đồng bộ khi có mạng' : 'Đã đồng bộ với máy chủ'}
        onPress={() => sync()}
      />
      <Item icon="refresh-circle-outline" title="Làm lại từ đầu" subtitle="Xóa kết quả trắc nghiệm đã làm" onPress={confirmReset} />
      {profile?.role === 'admin' ? (
        <Item icon="desktop-outline" title="Trang quản trị" subtitle="Quản lý bộ đề, từ vựng, tài khoản" onPress={() => Linking.openURL(ADMIN_SITE)} />
      ) : null}
      <Item icon="log-out-outline" title="Đăng xuất" color={colors.red} onPress={confirmLogout} />

      <Text muted size={12} style={{ textAlign: 'center', marginTop: 24 }}>
        Study For You · phiên bản {Constants.expoConfig?.version ?? '1.0.0'} 💕
      </Text>
    </Screen>
  );
}

function Item({
  icon,
  title,
  subtitle,
  onPress,
  color = colors.pink,
}: {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  subtitle?: string;
  onPress: () => void;
  color?: string;
}) {
  return (
    <SoftCard style={{ marginBottom: 10 }} padding={14} onPress={onPress}>
      <Row gap={14}>
        <Ionicons name={icon} size={24} color={color} />
        <View style={{ flex: 1 }}>
          <Text weight="heavy" color={color === colors.red ? colors.red : colors.text}>
            {title}
          </Text>
          {subtitle ? (
            <Text muted size={13}>
              {subtitle}
            </Text>
          ) : null}
        </View>
      </Row>
    </SoftCard>
  );
}
