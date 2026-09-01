import 'package:flutter/material.dart';

/// NativeMind design tokens (tokens/colors.css, typography.css, web.css).
class T {
  // Brand accent — Blue / Pro
  static const brandLight = Color(0xFF00C6FB);
  static const brandDeep = Color(0xFF005BEA);
  static const brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandLight, brandDeep],
  );

  // Neutrals
  static const bg = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const fg1 = Color(0xFF303F49);
  static const fg2 = Color(0xFFB6B6B6);
  static const fgMuted = Color(0xFF8A97A3);
  static const ink = Color(0xFF1A2129);
  static const disabled = Color(0xFFE0E0E0);
  static const hairline = Color(0x249CB2C2); // rgba(156,178,194,.14)
  static const hairlineSoft = Color(0x1F9CB2C2);
  static const border = Color(0x599CB2C2);

  // Semantic
  static const success = Color(0xFF1FB67A);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFE5484D);

  // Dense table (tokens/web.css --adm-*)
  static const rowEven = Color(0xFFFFFFFF);
  static const rowOdd = Color(0x0F005BEA); // brand @ 3.5–6%
  static const headBg = Color(0x14005BEA); // brand @ 5%
  static const rowSel = Color(0x24005BEA); // brand @ 9%
  static const rowSep = Color(0x1F9CB2C2);
  static const headSep = Color(0x339CB2C2);

  static const cellPad = EdgeInsets.symmetric(horizontal: 6, vertical: 7);
  static const headPad = EdgeInsets.symmetric(horizontal: 6, vertical: 8);

  static const radiusCard = 10.0;
  static const radiusCtl = 8.0;

  static const shadow = <BoxShadow>[
    BoxShadow(color: Color(0x1A9CB2C2), blurRadius: 32, offset: Offset(0, 1)),
  ];

  // Type roles
  static const _f = 'SF Pro Text';
  static const screenTitle =
      TextStyle(fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w600, color: ink);
  static const panelTitle =
      TextStyle(fontFamily: _f, fontSize: 13, fontWeight: FontWeight.w600, color: ink);
  static const body = TextStyle(fontFamily: _f, fontSize: 13, color: fg1);
  static const cell = TextStyle(fontFamily: _f, fontSize: 12, height: 1.3, color: fg1);
  static const cellAlarm = TextStyle(
      fontFamily: _f, fontSize: 12, height: 1.3, fontWeight: FontWeight.w600, color: danger);
  static const cellSub = TextStyle(fontFamily: _f, fontSize: 10, height: 1.3, color: fgMuted);
  static const cellTertiary = TextStyle(fontFamily: _f, fontSize: 10, height: 1.3, color: fg2);
  static const head = TextStyle(
      fontFamily: _f, fontSize: 11, height: 1.25, fontWeight: FontWeight.w600, color: ink);
  static const headSub = TextStyle(fontFamily: _f, fontSize: 10, height: 1.25, color: fgMuted);
  static const caption = TextStyle(fontFamily: _f, fontSize: 12, color: fgMuted);
  static const mono = TextStyle(
      fontFamily: 'monospace', fontFamilyFallback: ['Menlo', 'Consolas'], fontSize: 11, color: fg1);
  static const monoDim = TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: ['Menlo', 'Consolas'],
      fontSize: 11,
      height: 1.7,
      color: fg1);
}

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: T.bg,
    colorScheme: base.colorScheme.copyWith(primary: T.brandDeep, surface: T.surface),
    textTheme: base.textTheme.apply(fontFamily: 'SF Pro Text', bodyColor: T.fg1),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.radiusCtl),
        border: Border.all(color: T.border),
        boxShadow: const [BoxShadow(color: Color(0x599CB2C2), blurRadius: 32, offset: Offset(0, 1))],
      ),
      textStyle: T.cell,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    checkboxTheme: CheckboxThemeData(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: const BorderSide(color: T.border, width: 1.4),
    ),
  );
}
