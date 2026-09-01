import 'package:flutter/material.dart';
import '../data/models.dart';

/// 16×16 source glyph. Render at 16 or an integer multiple, nearest-neighbour —
/// fractional sizes resample and blur the pixel grid.
class AdmIcon extends StatelessWidget {
  final String path;
  final String? title;
  final double size;
  const AdmIcon(this.path, {super.key, this.title, this.size = 16});

  factory AdmIcon.ref(IcoRef r, {double size = 16}) =>
      AdmIcon(r.path, title: r.title, size: size);

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
    if (title == null || title!.isEmpty) return img;
    return Tooltip(message: title!, child: img);
  }
}

class IconStack extends StatelessWidget {
  final List<IcoRef> icons;
  final double gap;
  const IconStack(this.icons, {super.key, this.gap = 2});

  @override
  Widget build(BuildContext context) {
    if (icons.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [for (final i in icons) AdmIcon.ref(i)],
    );
  }
}
