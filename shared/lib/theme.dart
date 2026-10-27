import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const pink = Color(0xFFEC5B8D);
  static const pinkDeep = Color(0xFFD94078);
  static const pinkLight = Color(0xFFF9A8C4);
  static const blush = Color(0xFFFDE4EE);
  static const background = Color(0xFFFFF4F8);
  static const text = Color(0xFF3A2A33);
  static const muted = Color(0xFF9A8790);
  static const green = Color(0xFF3DBE7A);
  static const red = Color(0xFFF0506E);
  static const border = Color(0xFFF6D3E1);

  static const gradient = LinearGradient(
    colors: [Color(0xFFF58AB0), Color(0xFFE94E86)],
  );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pink,
      primary: AppColors.pink,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  return base.copyWith(
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      foregroundColor: AppColors.text,
      titleTextStyle: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.pink, width: 1.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.pink,
        side: const BorderSide(color: AppColors.pinkLight),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

TextStyle brandTitle(double size) => GoogleFonts.baloo2(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: AppColors.pinkDeep,
      height: 1.1,
    );

TextStyle handwriting(double size) =>
    GoogleFonts.dancingScript(fontSize: size, color: AppColors.pink, height: 1.3);

/// Pink pill button with a gradient fill.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
        Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, color: Colors.white, size: 20),
        ],
      ],
    );
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// White rounded card with a soft pink shadow.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = Colors.white,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor ?? AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Centers content and caps its width on wide (desktop) screens.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}

/// Circular progress ring with a percentage in the middle.
class PercentRing extends StatelessWidget {
  const PercentRing({super.key, required this.value, this.size = 96, this.label});

  final double value;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: size * 0.1,
            strokeCap: StrokeCap.round,
            color: AppColors.pink,
            backgroundColor: AppColors.blush,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(value * 100).round()}%',
                    style: TextStyle(
                        fontSize: size * 0.22, fontWeight: FontWeight.w900)),
                if (label != null)
                  Text(label!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: size * 0.09, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Study For You" heart mascot (cropped from the app logo).
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/mascot.png', package: 'study_shared',
          width: size, height: size, fit: BoxFit.contain, filterQuality: FilterQuality.medium);
}

/// Round avatar showing the mascot.
class MascotAvatar extends StatelessWidget {
  const MascotAvatar({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        decoration: BoxDecoration(
          color: AppColors.blush,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: AppColors.pink.withValues(alpha: 0.2), blurRadius: 8),
          ],
        ),
        child: Image.asset('assets/mascot.png', package: 'study_shared',
            fit: BoxFit.contain, filterQuality: FilterQuality.medium),
      );
}

/// Faint hearts scattered in the background of a screen.
class HeartBackdrop extends StatelessWidget {
  const HeartBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const spots = [
      (0.06, 0.12, 22.0), (0.88, 0.08, 16.0), (0.92, 0.42, 26.0),
      (0.04, 0.6, 18.0), (0.85, 0.82, 20.0), (0.12, 0.9, 14.0),
    ];
    return LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF7FA), Color(0xFFFFE6EF)],
                ),
              ),
            ),
          ),
          for (final (x, y, s) in spots)
            Positioned(
              left: c.maxWidth * x,
              top: c.maxHeight * y,
              child: Icon(Icons.favorite,
                  size: s, color: AppColors.pinkLight.withValues(alpha: 0.35)),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
