import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';

Future<void> showMetadataDialog(
    BuildContext context, CommandSetController controller) async {
  final set = controller.selected;
  if (set == null || set.isSystem) return;
  final name = TextEditingController(text: set.name);
  final operator = TextEditingController(text: set.operatorName);
  final code = TextEditingController(text: set.countryCode);
  final country = TextEditingController(text: set.countryName);
  final region = TextEditingController(text: set.region ?? '');
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Row(children: [
        FugueIcon('application--pencil.png'),
        SizedBox(width: 8),
        Text('Метаданные набора')
      ]),
      content: SizedBox(
          width: 460,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(name, 'Название'),
            const SizedBox(height: 10),
            _field(operator, 'Оператор'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(flex: 2, child: _field(code, 'Код страны')),
              const SizedBox(width: 10),
              Expanded(flex: 5, child: _field(country, 'Страна'))
            ]),
            const SizedBox(height: 10),
            _field(region, 'Регион (необязательно)'),
          ])),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена')),
        FilledButton(
            onPressed: () {
              controller.updateMetadata(
                  name: name.text,
                  operatorName: operator.text,
                  countryCode: code.text.trim().toUpperCase(),
                  countryName: country.text,
                  region:
                      region.text.trim().isEmpty ? null : region.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Применить')),
      ],
    ),
  );
  name.dispose();
  operator.dispose();
  code.dispose();
  country.dispose();
  region.dispose();
}

Future<void> showCreateSetDialog(
    BuildContext context, CommandSetController controller) async {
  final id = TextEditingController();
  final name = TextEditingController();
  final operator = TextEditingController();
  final code = TextEditingController(text: 'RU');
  final country = TextEditingController(text: 'Россия');
  final region = TextEditingController();
  var clone = true;
  var sourceId = controller.selectedId ?? controller.records.first.id;
  String? error;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
              title: const Row(children: [
                FugueIcon('application--plus.png'),
                SizedBox(width: 8),
                Text('Новый набор команд')
              ]),
              content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            selected: {
                              clone
                            },
                            onSelectionChanged: (value) =>
                                setState(() => clone = value.first)),
                        if (clone) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                              initialValue: sourceId,
                              decoration: const InputDecoration(
                                  labelText: 'Исходный набор',
                                  border: OutlineInputBorder()),
                              items: [
                                for (final item in controller.records)
                                  DropdownMenuItem(
                                      value: item.id, child: Text(item.name))
                              ],
                              onChanged: (value) =>
                                  sourceId = value ?? sourceId),
                        ],
                        const SizedBox(height: 12),
                        _field(id, 'Новый стабильный ID'),
                        const SizedBox(height: 10),
                        _field(name, 'Название'),
                        const SizedBox(height: 10),
                        _field(operator, 'Оператор'),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(flex: 2, child: _field(code, 'Код')),
                          const SizedBox(width: 10),
                          Expanded(flex: 5, child: _field(country, 'Страна'))
                        ]),
                        const SizedBox(height: 10),
                        _field(region, 'Регион (необязательно)'),
                        if (error != null) ...[
                          const SizedBox(height: 10),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FugueIcon('exclamation.png'),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(error!, style: T.cellAlarm)),
                              ]),
                        ],
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Отмена')),
                FilledButton(
                    onPressed: () {
                      final result = clone
                          ? controller.cloneSet(sourceId,
                              id: id.text.trim(),
                              name: name.text.trim(),
                              operator: operator.text.trim(),
                              countryCode: code.text.trim().toUpperCase(),
                              countryName: country.text.trim(),
                              region: region.text.trim())
                          : controller.createBlank(
                              id: id.text.trim(),
                              name: name.text.trim(),
                              operator: operator.text.trim(),
                              countryCode: code.text.trim().toUpperCase(),
                              countryName: country.text.trim(),
                              region: region.text.trim());
                      if (result.isValid) {
                        Navigator.pop(dialogContext);
                      } else {
                        setState(() => error = result.issues.first.message);
                      }
                    },
                    child: const Text('Создать')),
              ],
            )),
  );
  id.dispose();
  name.dispose();
  operator.dispose();
  code.dispose();
  country.dispose();
  region.dispose();
}

Future<void> showDeleteSetDialog(
    BuildContext context, CommandSetController controller) async {
  final set = controller.selected;
  if (set == null) return;
  final impact = controller.inspectDelete(set.id);
  if (!impact.allowed) {
    await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
              title: const Row(children: [
                FugueIcon('lock.png'),
                SizedBox(width: 8),
                Text('Удаление недоступно')
              ]),
              content: Text([
                impact.message,
                if (impact.planIds.isNotEmpty)
                  'Планы: ${impact.planIds.join(', ')}'
              ].join('\n')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Закрыть'))
              ],
            ));
    return;
  }
  final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
            title: const Row(children: [
              FugueIcon('application--minus.png'),
              SizedBox(width: 8),
              Text('Удалить набор?')
            ]),
            content: Text('${set.name}\n\n${impact.message}'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена')),
              FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: T.danger),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Удалить')),
            ],
          ));
  if (confirmed == true) controller.confirmDelete(set.id);
}

TextField _field(TextEditingController controller, String label) => TextField(
      controller: controller,
      style: T.body,
      decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(T.radiusCtl))),
    );
