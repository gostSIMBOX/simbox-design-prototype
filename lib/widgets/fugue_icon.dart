import 'package:flutter/material.dart';
import '../design/tokens.dart';

class FugueIcon extends StatelessWidget {
  final String name;
  final String? semanticLabel;
  final double size;
  final double opacity;

  const FugueIcon(this.name,
      {super.key,
      this.semanticLabel,
      this.size = T.fugueUnit,
      this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/fugue/$name',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      errorBuilder: (_, __, ___) => SizedBox.square(dimension: size),
    );
    return Opacity(opacity: opacity, child: image);
  }
}
