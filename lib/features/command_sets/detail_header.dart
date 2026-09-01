import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';
import 'set_dialogs.dart';

class CommandSetDetailHeader extends StatelessWidget {
  final CommandSetController controller;
  final bool narrow;
  const CommandSetDetailHeader(
      {super.key, required this.controller, this.narrow = false});

  @override
  Widget build(BuildContext context) {
    final set = controller.selected!;
    final location = [
      set.countryName,
      if (set.region != null && set.region!.isNotEmpty) set.region!
    ].join(' / ');
    return Container(
      padding: EdgeInsets.fromLTRB(narrow ? 12 : 16, 12, 8, 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.hairline))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (set.isSystem) ...[
            const FugueIcon('lock.png', semanticLabel: 'Системный набор'),
            const SizedBox(width: 8)
          ],
          Expanded(
              child: Text(set.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.screenTitle.copyWith(fontSize: narrow ? 17 : 20))),
          if (!set.isSystem)
            IconButton(
                tooltip: 'Редактировать метаданные',
                constraints: BoxConstraints.tightFor(
                    width: narrow ? T.narrowHit : T.denseHit,
                    height: narrow ? T.narrowHit : T.denseHit),
                onPressed: () => showMetadataDialog(context, controller),
                icon: const FugueIcon('application--pencil.png',
                    semanticLabel: 'Редактировать метаданные')),
          PopupMenuButton<String>(
            tooltip: 'Действия с набором',
            icon: const FugueIcon('ui-menu.png',
                semanticLabel: 'Действия с набором'),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clone', child: Text('Клонировать')),
              if (!set.isSystem)
                const PopupMenuItem(value: 'delete', child: Text('Удалить')),
            ],
            onSelected: (value) {
              if (value == 'clone') showCreateSetDialog(context, controller);
              if (value == 'delete') showDeleteSetDialog(context, controller);
            },
          ),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Expanded(
              child: Text('${set.id} · $location',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.cellSub)),
          if (set.usedByPlanIds.isNotEmpty)
            TextButton.icon(
              style: TextButton.styleFrom(
                  minimumSize: const Size(0, T.denseHit),
                  padding: const EdgeInsets.symmetric(horizontal: 8)),
              onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Используется планами'),
                        content: Text(set.usedByPlanIds.join('\n')),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Закрыть'))
                        ],
                      )),
              icon: const FugueIcon('information.png'),
              label: Text('${set.usedByPlanIds.length} план'),
            ),
        ]),
      ]),
    );
  }
}
