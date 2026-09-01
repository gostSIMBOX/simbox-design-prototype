import 'package:flutter/material.dart';
import '../data/icons_catalog.dart';
import '../design/tokens.dart';
import '../widgets/adm_icon.dart';

/// The whole GostSimBox set, laid out by semantic axis.
/// Folder = axis, filename = raw protocol value — the tooltip keeps both.
class IconsPage extends StatelessWidget {
  const IconsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.radiusCard),
          boxShadow: T.shadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Набор иконок GostSimBox', style: T.screenTitle),
          const SizedBox(height: 6),
          SizedBox(
            width: 780,
            child: Text(
              'Папка — семантическая ось, имя файла — сырое значение протокола. Все глифы 16×16, '
              'рендер только в 16px или целочисленном кратном с nearest-neighbour. '
              'Наведите на иконку — в подсказке сырой код.',
              style: T.caption.copyWith(height: 1.5),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 18),
      for (final g in iconCatalog) ...[
        _group(g),
        const SizedBox(height: 18),
      ],
      ]),
    );
  }

  Widget _group(IconGroup g) {
    return Container(
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.radiusCard),
        boxShadow: T.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: T.hairline))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(g.title, style: T.panelTitle),
            const SizedBox(width: 10),
            Text(g.path, style: T.mono.copyWith(color: T.fg2)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            children: [
              for (final item in g.items) _tile(item),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _tile(String spec) {
    final parts = spec.split('|');
    final file = parts[0], code = parts[1], label = parts[2];
    return SizedBox(
      width: 190,
      child: Tooltip(
        message: '$code — $label  ($file)',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(children: [
            AdmIcon(file),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: T.cell, overflow: TextOverflow.ellipsis),
                  Text(code, style: T.mono.copyWith(fontSize: 10, color: T.fg2),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
