import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';
import 'set_dialogs.dart';

class CommandSetRegistryPane extends StatelessWidget {
  final CommandSetController controller;
  final bool compact;
  const CommandSetRegistryPane(
      {super.key, required this.controller, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.radiusCard),
            boxShadow: T.shadow),
        child: Row(children: [
          const FugueIcon('application-list.png',
              semanticLabel: 'Наборы команд'),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedId,
                items: [
                  for (final set in controller.records)
                    DropdownMenuItem(
                        value: set.id,
                        child: Text(set.name, overflow: TextOverflow.ellipsis))
                ],
                onChanged: (id) {
                  if (id != null) requestSetSelection(context, controller, id);
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Добавить набор',
            constraints: const BoxConstraints.tightFor(
                width: T.narrowHit, height: T.narrowHit),
            onPressed: () => showCreateSetDialog(context, controller),
            icon: const FugueIcon('application--plus.png',
                semanticLabel: 'Добавить набор'),
          ),
        ]),
      );
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.radiusCard),
          boxShadow: T.shadow),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
          child: Row(children: [
            const Expanded(child: Text('Наборы команд', style: T.panelTitle)),
            IconButton(
              tooltip: 'Добавить набор',
              constraints: const BoxConstraints.tightFor(
                  width: T.denseHit, height: T.denseHit),
              onPressed: () => showCreateSetDialog(context, controller),
              icon: const FugueIcon('application--plus.png',
                  semanticLabel: 'Добавить набор'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Другие действия',
              icon: const FugueIcon('ui-menu.png',
                  semanticLabel: 'Другие действия'),
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'reset', child: Text('Сбросить демо-данные'))
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
            onChanged: controller.setSetQuery,
            style: T.body,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Оператор, регион или ID',
              prefixIconConstraints: const BoxConstraints.tightFor(width: 34),
              prefixIcon: const Center(child: FugueIcon('magnifier.png')),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(T.radiusCtl),
                  borderSide: const BorderSide(color: T.border)),
            ),
          ),
        ),
        const Divider(height: 1, color: T.hairline),
        Expanded(
          child: controller.visibleSets.isEmpty
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Наборы не найдены', style: T.caption)))
              : ListView.builder(
                  itemCount: controller.visibleSets.length,
                  itemBuilder: (context, index) {
                    final set = controller.visibleSets[index];
                    final selected = set.id == controller.selectedId;
                    return Material(
                      color: selected
                          ? T.rowSel
                          : index.isOdd
                              ? T.rowOdd
                              : T.rowEven,
                      child: InkWell(
                        onTap: () =>
                            requestSetSelection(context, controller, set.id),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 58),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(
                              border:
                                  Border(bottom: BorderSide(color: T.rowSep))),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: FugueIcon(set.isSystem
                                        ? 'lock.png'
                                        : 'application-list.png')),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(set.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: T.body.copyWith(
                                              fontWeight: selected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${set.id} · ${set.region ?? set.countryName}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: T.cellSub),
                                    ])),
                                const SizedBox(width: 6),
                                Text(
                                    '${set.commands.length}/${set.responseRules.length}',
                                    style: T.cellSub),
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

Future<void> requestSetSelection(
    BuildContext context, CommandSetController controller, String id) async {
  if (controller.requestSelectSet(id)) return;
  final discard = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Есть несохранённые изменения'),
      content: const Text(
          'Сохраните текущий набор или отмените изменения перед переключением.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Продолжить редактирование')),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Отменить изменения')),
      ],
    ),
  );
  if (discard == true) {
    controller.discardAndContinue();
  } else {
    controller.keepEditing();
  }
}
