import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import '../command_sets/models.dart';
import 'controller.dart';
import 'repository.dart';

Future<void> showCreatePlanDialog(BuildContext context,
    PlanController controller, List<CommandSet> commandSets) async {
  final id = TextEditingController();
  bool cloneMode = true;
  String? sourceId =
      controller.selected?.id ?? controller.records.firstOrNull?.id;
  String? commandSetId = commandSets.firstOrNull?.id;
  String? error;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Row(children: [
          FugueIcon('application--plus.png'),
          SizedBox(width: 8),
          Text('Новый план'),
        ]),
        content: SizedBox(
          width: 420,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: true,
                        label: Text('Клонировать'),
                        icon: FugueIcon('applications-stack.png')),
                    ButtonSegment(
                        value: false,
                        label: Text('Пустой'),
                        icon: FugueIcon('application-form.png')),
                  ],
                  selected: {cloneMode},
                  onSelectionChanged: (value) =>
                      setState(() => cloneMode = value.first),
                ),
                if (cloneMode) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: sourceId,
                    decoration: const InputDecoration(
                        labelText: 'Источник', isDense: true),
                    items: [
                      for (final plan in controller.records)
                        DropdownMenuItem(value: plan.id, child: Text(plan.id)),
                    ],
                    onChanged: (v) => setState(() => sourceId = v),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: id,
                  style: T.body,
                  decoration: InputDecoration(
                    labelText: 'ID плана (латиницей, уникальный) *',
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(T.radiusCtl)),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: commandSetId,
                  decoration: const InputDecoration(
                      labelText: 'Набор команд *', isDense: true),
                  items: [
                    for (final set in commandSets)
                      DropdownMenuItem(value: set.id, child: Text(set.name)),
                  ],
                  onChanged: (v) => setState(() => commandSetId = v),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const FugueIcon('exclamation.png'),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error!, style: T.cellAlarm)),
                  ]),
                ],
              ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final idValue = id.text.trim();
              if (idValue.isEmpty || commandSetId == null) {
                setState(() => error = 'ID и набор команд обязательны.');
                return;
              }
              if (cloneMode && sourceId == null) {
                setState(() => error = 'Выберите источник для клонирования.');
                return;
              }
              try {
                controller.createPlan(idValue, commandSetId!,
                    cloneFromId: cloneMode ? sourceId : null);
                Navigator.pop(dialogContext);
              } on PlanRepositoryException catch (e) {
                setState(() => error = e.message);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    ),
  );
  id.dispose();
}

Future<void> showDeletePlanDialog(
    BuildContext context, PlanController controller) async {
  final plan = controller.selected;
  if (plan == null) return;
  final impact = controller.inspectDelete(plan.id);

  if (!impact.allowed) {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          FugueIcon('lock.png'),
          SizedBox(width: 8),
          Text('Удаление недоступно'),
        ]),
        content: Text(impact.message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть')),
        ],
      ),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Row(children: [
        FugueIcon('application--minus.png'),
        SizedBox(width: 8),
        Text('Удалить план?'),
      ]),
      content: Text(impact.message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: T.danger),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  if (confirmed == true) controller.deletePlan(plan.id);
}

Future<void> requestPlanSelection(
    BuildContext context, PlanController controller, String id) async {
  if (controller.requestSelectPlan(id)) return;
  final discard = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Есть несохранённые изменения'),
      content: const Text(
          'Сохраните текущий план или отмените изменения перед переключением.'),
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
