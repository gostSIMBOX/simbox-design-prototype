import 'package:flutter/material.dart';

/// NativeMind DS tokens (web.css / colors.css subset) used by the adminka.
class T {
  static const brand = Color(0xFF005BEA);
  static const brandLight = Color(0xFF00C6FB);
  static const bg = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const fg1 = Color(0xFF303F49);
  static const fg2 = Color(0xFFB6B6B6);
  static const fgMuted = Color(0xFF8A97A3);
  static const fgBody = Color(0xFF546675);
  static const ink = Color(0xFF1A2129);
  static const success = Color(0xFF1FB67A);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFE5484D);

  // dense-table washes: one hue, ascending strength
  static const rowEven = Color(0xFFFFFFFF);
  static final rowOdd = brand.withOpacity(0.035);
  static final headBg = brand.withOpacity(0.05);
  static final rowSel = brand.withOpacity(0.09);
  static final ruleRow = const Color(0xFF9CB2C2).withOpacity(0.12);
  static final ruleHead = const Color(0xFF9CB2C2).withOpacity(0.20);
  static final rulePanel = const Color(0xFF9CB2C2).withOpacity(0.14);

  static const gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandLight, brand],
  );

  static const cardShadow = BoxShadow(
    color: Color(0x1A9CB2C2),
    blurRadius: 32,
    offset: Offset(0, 1),
  );

  static const family = 'SFProText';
  static const mono = 'monospace';

  static ThemeData data() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: brand, surface: surface),
        textTheme: const TextTheme().apply(bodyColor: fg1, displayColor: fg1),
        splashFactory: NoSplash.splashFactory,
      );
}

/// 16×16 adminka glyph, rendered at 1× or an integer multiple, nearest-neighbour.
class Ico extends StatelessWidget {
  const Ico(this.path, {super.key, this.size = 16, this.tooltip});
  final String path;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/imgs/$path',
      width: size,
      height: size,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
    return tooltip == null ? img : Tooltip(message: tooltip!, child: img);
  }
}
