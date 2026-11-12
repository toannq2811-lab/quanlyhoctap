// Shared look of the app (port of shared/lib/theme.dart widgets).
import { Image } from 'expo-image';
import { LinearGradient } from 'expo-linear-gradient';
import type { ReactNode } from 'react';
import {
  ActivityIndicator,
  Pressable,
  ScrollView,
  StyleSheet,
  Text as RNText,
  View,
  type StyleProp,
  type TextProps,
  type TextStyle,
  type ViewStyle,
} from 'react-native';
import { SafeAreaView, type Edge } from 'react-native-safe-area-context';
import Svg, { Circle } from 'react-native-svg';

import { colors, fonts, gradient } from '@/lib/theme';

type Weight = 'regular' | 'semibold' | 'bold' | 'heavy' | 'black';

/** Text in the app font (Nunito). */
export function Text({
  weight = 'regular',
  muted,
  size,
  color,
  style,
  ...props
}: TextProps & { weight?: Weight; muted?: boolean; size?: number; color?: string }) {
  return (
    <RNText
      {...props}
      style={[
        { fontFamily: fonts[weight], color: color ?? (muted ? colors.muted : colors.text), fontSize: size ?? 15 },
        style,
      ]}
    />
  );
}

export function BrandTitle({ children, size = 26, style }: { children: ReactNode; size?: number; style?: StyleProp<TextStyle> }) {
  return <RNText style={[{ fontFamily: fonts.brand, fontSize: size, color: colors.pinkDeep }, style]}>{children}</RNText>;
}

/** Page background with soft hearts, safe-area aware. */
export function Screen({
  children,
  scroll = true,
  edges = ['top'],
  padded = true,
}: {
  children: ReactNode;
  scroll?: boolean;
  edges?: Edge[];
  padded?: boolean;
}) {
  return (
    <SafeAreaView style={styles.screen} edges={edges}>
      <Hearts />
      {scroll ? (
        <ScrollView contentContainerStyle={padded && styles.padded} showsVerticalScrollIndicator={false}>
          {children}
        </ScrollView>
      ) : (
        <View style={[{ flex: 1 }, padded && styles.padded]}>{children}</View>
      )}
    </SafeAreaView>
  );
}

function Hearts() {
  const spots = [
    { top: 40, right: 24, size: 22, o: 0.18 },
    { top: 160, left: 18, size: 14, o: 0.14 },
    { top: 320, right: 40, size: 12, o: 0.12 },
    { bottom: 120, left: 30, size: 18, o: 0.12 },
  ];
  return (
    <View pointerEvents="none" style={StyleSheet.absoluteFill}>
      {spots.map(({ size, o, ...pos }, i) => (
        <RNText key={i} style={{ position: 'absolute', ...pos, fontSize: size, opacity: o, color: colors.pink }}>
          ♥
        </RNText>
      ))}
    </View>
  );
}

export function SoftCard({
  children,
  onPress,
  style,
  borderColor,
  padding = 16,
}: {
  children: ReactNode;
  onPress?: () => void;
  style?: StyleProp<ViewStyle>;
  borderColor?: string;
  padding?: number;
}) {
  const body = [styles.card, { padding }, borderColor ? { borderColor } : null, style];
  if (!onPress) return <View style={body}>{children}</View>;
  return (
    <Pressable onPress={onPress} style={({ pressed }) => [body, pressed && { opacity: 0.85 }]}>
      {children}
    </Pressable>
  );
}

export function GradientButton({
  label,
  onPress,
  icon,
  loading,
  disabled,
  style,
}: {
  label: string;
  onPress?: () => void;
  icon?: string;
  loading?: boolean;
  disabled?: boolean;
  style?: StyleProp<ViewStyle>;
}) {
  const off = disabled || !onPress;
  return (
    <Pressable
      onPress={loading || off ? undefined : onPress}
      style={({ pressed }) => [{ opacity: off ? 0.5 : pressed ? 0.85 : 1 }, style]}
    >
      <LinearGradient colors={gradient} start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }} style={styles.gradientButton}>
        {loading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text weight="heavy" color="#fff" size={16}>
            {icon ? `${icon}  ` : ''}
            {label}
          </Text>
        )}
      </LinearGradient>
    </Pressable>
  );
}

export function OutlineButton({
  label,
  onPress,
  icon,
  color = colors.pink,
  style,
  small,
}: {
  label: string;
  onPress?: () => void;
  icon?: string;
  color?: string;
  style?: StyleProp<ViewStyle>;
  small?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      disabled={!onPress}
      style={({ pressed }) => [
        styles.outlineButton,
        small && { paddingVertical: 8, paddingHorizontal: 14 },
        { opacity: !onPress ? 0.5 : pressed ? 0.7 : 1 },
        style,
      ]}
    >
      <Text weight="bold" color={color} size={small ? 13 : 15}>
        {icon ? `${icon}  ` : ''}
        {label}
      </Text>
    </Pressable>
  );
}

/** Circular progress with a percentage in the middle. */
export function PercentRing({ value, size = 92, label }: { value: number; size?: number; label?: string }) {
  const stroke = 9;
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const v = Math.max(0, Math.min(1, value));
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <Svg width={size} height={size} style={StyleSheet.absoluteFill}>
        <Circle cx={size / 2} cy={size / 2} r={r} stroke={colors.blush} strokeWidth={stroke} fill="none" />
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          stroke={colors.pink}
          strokeWidth={stroke}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={`${c * v} ${c}`}
          transform={`rotate(-90 ${size / 2} ${size / 2})`}
        />
      </Svg>
      <Text weight="black" size={size / 4.6}>
        {Math.round(v * 100)}%
      </Text>
      {label ? (
        <Text muted size={11}>
          {label}
        </Text>
      ) : null}
    </View>
  );
}

export function ProgressBar({ value, color = colors.pink, height = 6 }: { value: number; color?: string; height?: number }) {
  return (
    <View style={{ height, borderRadius: height, backgroundColor: colors.blush, overflow: 'hidden' }}>
      <View style={{ width: `${Math.max(0, Math.min(1, value)) * 100}%`, height, backgroundColor: color }} />
    </View>
  );
}

export function Mascot({ size = 64 }: { size?: number }) {
  return <Image source={require('../../assets/mascot.png')} style={{ width: size, height: size }} contentFit="contain" />;
}

export function Badge({ children, color = colors.pink, bg = colors.blush }: { children: ReactNode; color?: string; bg?: string }) {
  return (
    <View style={{ alignSelf: 'flex-start', backgroundColor: bg, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 4 }}>
      <Text weight="heavy" size={12} color={color}>
        {children}
      </Text>
    </View>
  );
}

/** A square tile with a letter or emoji, used in lists. */
export function IconTile({ children, done, size = 44 }: { children: ReactNode; done?: boolean; size?: number }) {
  const inner =
    typeof children === 'string' || typeof children === 'number' ? (
      <Text weight="black" size={size * 0.42} color={done ? '#fff' : colors.pink}>
        {children}
      </Text>
    ) : (
      children
    );
  if (done) {
    return (
      <LinearGradient colors={gradient} style={[styles.tile, { width: size, height: size }]}>
        {inner}
      </LinearGradient>
    );
  }
  return <View style={[styles.tile, { width: size, height: size, backgroundColor: colors.blush }]}>{inner}</View>;
}

export function SectionTitle({ children, hint }: { children: ReactNode; hint?: string }) {
  return (
    <View style={{ marginTop: 22, marginBottom: 10 }}>
      <Text weight="black" size={18}>
        {children}
      </Text>
      {hint ? (
        <Text muted size={13}>
          {hint}
        </Text>
      ) : null}
    </View>
  );
}

export function Row({ children, gap = 10, style }: { children: ReactNode; gap?: number; style?: StyleProp<ViewStyle> }) {
  return <View style={[{ flexDirection: 'row', alignItems: 'center', gap }, style]}>{children}</View>;
}

export function Chip({ label, selected, onPress }: { label: string; selected?: boolean; onPress: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.chip,
        selected && { backgroundColor: colors.blush, borderColor: colors.pink },
      ]}
    >
      <Text weight="bold" size={14} color={selected ? colors.pink : colors.text}>
        {label}
      </Text>
    </Pressable>
  );
}

export function Empty({ text }: { text: string }) {
  return (
    <View style={{ alignItems: 'center', padding: 32, gap: 12 }}>
      <Mascot size={90} />
      <Text muted style={{ textAlign: 'center' }}>
        {text}
      </Text>
    </View>
  );
}

/** Text field style used by the login / sign-up screens. */
export const inputStyle: TextStyle = {
  backgroundColor: colors.white,
  borderWidth: 1,
  borderColor: colors.border,
  borderRadius: 14,
  paddingHorizontal: 16,
  paddingVertical: 14,
  fontSize: 16,
  fontFamily: fonts.semibold,
  color: colors.text,
  marginBottom: 12,
};

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.background },
  padded: { padding: 20, paddingBottom: 40 },
  card: {
    backgroundColor: colors.white,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.border,
    shadowColor: colors.pink,
    shadowOpacity: 0.08,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 4 },
  },
  gradientButton: {
    height: 52,
    borderRadius: 26,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 18,
  },
  outlineButton: {
    borderWidth: 1.2,
    borderColor: colors.pinkLight,
    backgroundColor: colors.white,
    borderRadius: 26,
    paddingVertical: 13,
    paddingHorizontal: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
  tile: { borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  chip: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 20,
    paddingHorizontal: 14,
    paddingVertical: 8,
    backgroundColor: colors.white,
  },
});
