import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'code_editor.dart';
import 'controller.dart';
import 'zone_dialogs.dart';

class ZoneDetailHeader extends StatelessWidget {
  final ZoneController controller;
  final bool narrow;
  const ZoneDetailHeader(
      {super.key, required this.controller, this.narrow = false});

  @override
  Widget build(BuildContext context) {
    final zone = controller.selected!;
    return Container(
      padding: EdgeInsets.fromLTRB(narrow ? 12 : 16, 12, 8, 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.hairline))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ZoneIcon(zone, size: 20)),
          Expanded(
              child: Text(zone.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.screenTitle.copyWith(fontSize: narrow ? 17 : 20))),
          IconButton(
              tooltip: 'Редактировать метаданные',
              constraints: BoxConstraints.tightFor(
                  width: narrow ? T.narrowHit : T.denseHit,
                  height: narrow ? T.narrowHit : T.denseHit),
              onPressed: () => showEditZoneMetadataDialog(context, controller),
              icon: const FugueIcon('application--pencil.png',
                  semanticLabel: 'Редактировать метаданные')),
          PopupMenuButton<String>(
            tooltip: 'Действия с направлением',
            icon: const FugueIcon('ui-menu.png',
                semanticLabel: 'Действия с направлением'),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Удалить')),
            ],
            onSelected: (value) {
              if (value == 'delete') showDeleteZoneDialog(context, controller);
            },
          ),
        ]),
        const SizedBox(height: 3),
        Text('${zone.id}${zone.region != null ? ' · ${zone.region}' : ''}',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: T.cellSub),
      ]),
    );
  }
}
