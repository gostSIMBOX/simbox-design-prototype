import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'code_editor.dart';
import 'controller.dart';
import 'zone_dialogs.dart';

class ZoneRegistryPane extends StatelessWidget {
  final ZoneController controller;
  final bool compact;
  const ZoneRegistryPane({super.key, required this.controller, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: T.surface, borderRadius: BorderRadius.circular(T.radiusCard), boxShadow: T.shadow),
        child: Row(children: [
          const FugueIcon('application-list.png', semanticLabel: 'Направления'),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedId,
                items: [
                  for (final zone in controller.records)
                    DropdownMenuItem(value: zone.id, child: Text(zone.name, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (id) {
                  if (id != null) requestZoneSelection(context, controller, id);
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Добавить направление',
            constraints: const BoxConstraints.tightFor(width: T.narrowHit, height: T.narrowHit),
            onPressed: () => showCreateZoneDialog(context, controller),
            icon: const FugueIcon('application--plus.png', semanticLabel: 'Добавить направление'),
          ),
        ]),
      );
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
          color: T.surface, borderRadius: BorderRadius.circular(T.radiusCard), boxShadow: T.shadow),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
          child: Row(children: [
            const Expanded(child: Text('Направления', style: T.panelTitle)),
            IconButton(
              tooltip: 'Добавить направление',
              constraints: const BoxConstraints.tightFor(width: T.denseHit, height: T.denseHit),
              onPressed: () => showCreateZoneDialog(context, controller),
              icon: const FugueIcon('application--plus.png', semanticLabel: 'Добавить направление'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Другие действия',
              icon: const FugueIcon('ui-menu.png', semanticLabel: 'Другие действия'),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'reset', child: Text('Сбросить демо-данные')),
              ],
              onSelected: (value) {
                if (value == 'reset') controller.resetDemo();
              },
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: TextField(
            onChanged: controller.setQuery,
            style: T.body,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'ID, название или регион',
              prefixIconConstraints: const BoxConstraints.tightFor(width: 34),
              prefixIcon: const Center(child: FugueIcon('magnifier.png')),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(T.radiusCtl), borderSide: const BorderSide(color: T.border)),
            ),
          ),
        ),
        const Divider(height: 1, color: T.hairline),
        Expanded(
          child: controller.visibleZones.isEmpty
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20), child: Text('Направления не найдены', style: T.caption)))
              : ListView.builder(
                  itemCount: controller.visibleZones.length,
                  itemBuilder: (context, index) {
                    final zone = controller.visibleZones[index];
                    final selected = zone.id == controller.selectedId;
                    return Material(
                      color: selected ? T.rowSel : (index.isOdd ? T.rowOdd : T.rowEven),
                      child: InkWell(
                        onTap: () => requestZoneSelection(context, controller, zone.id),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 58),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.rowSep))),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(padding: const EdgeInsets.only(top: 2), child: ZoneIcon(zone)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(zone.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: T.body.copyWith(
                                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                                const SizedBox(height: 2),
                                Text('${zone.id}${zone.region != null ? ' · ${zone.region}' : ''}',
                                    maxLines: 1, overflow: TextOverflow.ellipsis, style: T.cellSub),
                              ]),
                            ),
                            const SizedBox(width: 6),
                            Text('${zone.defCodes.length}', style: T.cellSub),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
