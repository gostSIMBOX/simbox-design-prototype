import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import '../command_sets/models.dart';
import 'controller.dart';
import 'plan_dialogs.dart';

class PlanRegistryPane extends StatelessWidget {
  final PlanController controller;
  final List<CommandSet> commandSets;
  final bool compact;
  const PlanRegistryPane({
    super.key,
    required this.controller,
    required this.commandSets,
    this.compact = false,
  });

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
          const FugueIcon('application-task.png', semanticLabel: 'Планы'),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedId,
                items: [
                  for (final plan in controller.records)
                    DropdownMenuItem(
                        value: plan.id,
                        child: Text(plan.id, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (id) {
                  if (id != null) requestPlanSelection(context, controller, id);
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Добавить план',
            constraints: const BoxConstraints.tightFor(
                width: T.narrowHit, height: T.narrowHit),
            onPressed: () =>
                showCreatePlanDialog(context, controller, commandSets),
            icon: const FugueIcon('application--plus.png',
                semanticLabel: 'Добавить план'),
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
            const Expanded(child: Text('Планы', style: T.panelTitle)),
            IconButton(
              tooltip: 'Добавить план',
              constraints: const BoxConstraints.tightFor(
                  width: T.denseHit, height: T.denseHit),
              onPressed: () =>
                  showCreatePlanDialog(context, controller, commandSets),
              icon: const FugueIcon('application--plus.png',
                  semanticLabel: 'Добавить план'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Другие действия',
              icon: const FugueIcon('ui-menu.png',
                  semanticLabel: 'Другие действия'),
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'reset', child: Text('Сбросить демо-данные')),
              ],
              onSelected: (value) {
                if (value == 'reset') controller.resetDemo();
              },
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextField(
            onChanged: controller.setQuery,
            style: T.body,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'ID плана или набор команд',
              prefixIconConstraints: const BoxConstraints.tightFor(width: 34),
              prefixIcon: const Center(child: FugueIcon('magnifier.png')),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(T.radiusCtl),
                  borderSide: const BorderSide(color: T.border)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: DropdownButtonFormField<String?>(
            isExpanded: true,
            initialValue: controller.commandSetFilter,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(T.radiusCtl)),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Все наборы')),
              for (final set in commandSets)
                DropdownMenuItem(value: set.id, child: Text(set.name)),
            ],
            onChanged: controller.setCommandSetFilter,
          ),
        ),
        const Divider(height: 1, color: T.hairline),
        Expanded(
          child: controller.visiblePlans.isEmpty
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Планы не найдены', style: T.caption)))
              : ListView.builder(
                  itemCount: controller.visiblePlans.length,
                  itemBuilder: (context, index) {
                    final plan = controller.visiblePlans[index];
                    final selected = plan.id == controller.selectedId;
                    return Material(
                      color: selected
                          ? T.rowSel
                          : (index.isOdd ? T.rowOdd : T.rowEven),
                      child: InkWell(
                        onTap: () =>
                            requestPlanSelection(context, controller, plan.id),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 52),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(
                              border:
                                  Border(bottom: BorderSide(color: T.rowSep))),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 16,
                                    color: selected ? T.brandDeep : T.hairline),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(plan.id,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: T.body.copyWith(
                                                fontWeight: selected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400)),
                                        const SizedBox(height: 2),
                                        Text(
                                            '${plan.commandSetId} · ${controller.usageCount(plan.id)} симок',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: T.cellSub),
                                      ]),
                                ),
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
