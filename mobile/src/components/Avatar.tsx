import { Image } from 'expo-image';
import { View } from 'react-native';

import { Text } from '@/components/ui';
import { api } from '@/lib/api';
import { colors } from '@/lib/theme';
import type { Profile } from '@/lib/types';

/** Profile photo from the API, or the first letter of the name. */
export function Avatar({ profile, size = 48 }: { profile: Profile | null; size?: number }) {
  const path = profile?.avatar_path; // "<user id>/<version>"
  const ring = { width: size, height: size, borderRadius: size / 2, borderWidth: 2, borderColor: colors.pinkLight };
  if (path) {
    const [id, version] = path.split('/');
    return (
      <Image
        source={{ ...api.imageSource(`/users/${id}/avatar`), cacheKey: `avatar-${id}-${version}` }}
        style={ring}
        contentFit="cover"
      />
    );
  }
  const initial = (profile?.name ?? profile?.username ?? '?').trim().charAt(0).toUpperCase();
  return (
    <View style={[ring, { backgroundColor: colors.blush, alignItems: 'center', justifyContent: 'center' }]}>
      <Text weight="black" size={size * 0.42} color={colors.pink}>
        {initial}
      </Text>
    </View>
  );
}
