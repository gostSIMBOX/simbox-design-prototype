import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';
import 'repository.dart';

TextField _field(TextEditingController controller, String label,
        {bool required = false}) =>
    TextField(
      controller: controller,
      style: T.body,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(T.radiusCtl)),
      ),
    );

Future<void> showCreateZoneDialog(
    BuildContext context, ZoneController controller) async {
  final id = TextEditingController();
  final name = TextEditingController();
  final region = TextEditingController();
  String? error;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Row(children: [
          FugueIcon('application--plus.png'),
          SizedBox(width: 8),
          Text('Новое направление'),
        ]),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(id, 'ID (латиницей, уникальный)', required: true),
            const SizedBox(height: 10),
            _field(name, 'Название', required: true),
            const SizedBox(height: 10),
            _field(region, 'Регион (необязательно)'),
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
              final nameValue = name.text.trim();
              if (idValue.isEmpty || nameValue.isEmpty) {
                setState(() => error = 'ID и название обязательны.');
                return;
              }
              try {
                controller.createZone(idValue, nameValue,
                    region.text.trim().isEmpty ? null : region.text.trim());
                Navigator.pop(dialogContext);
              } on ZoneRepositoryException catch (e) {
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
  name.dispose();
  region.dispose();
}

Future<void> showEditZoneMetadataDialog(
    BuildContext context, ZoneController controller) async {
  final zone = controller.selected;
  if (zone == null) return;
  final name = TextEditingController(text: zone.name);
  final region = TextEditingController(text: zone.region ?? '');
  final billingCode = TextEditingController(text: zone.billingCode ?? '');
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Row(children: [
        FugueIcon('application--pencil.png'),
        SizedBox(width: 8),
        Text('Метаданные направления'),
      ]),
      content: SizedBox(
        width: 420,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(name, 'Название', required: true),
          const SizedBox(height: 10),
          _field(region, 'Регион (необязательно)'),
          const SizedBox(height: 10),
          _field(billingCode, 'Код направления (2 буквы, напр. NS)'),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена')),
        FilledButton(
          onPressed: () {
            controller.renameZone(
              zone.id,
              name.text.trim(),
              region.text.trim().isEmpty ? null : region.text.trim(),
              billingCode.text.trim().isEmpty
                  ? null
                  : billingCode.text.trim().toUpperCase(),
            );
            Navigator.pop(context);
          },
          child: const Text('Применить'),
        ),
      ],
    ),
  );
  name.dispose();
  region.dispose();
  billingCode.dispose();
}

Future<void> showDeleteZoneDialog(
    BuildContext context, ZoneController controller) async {
  final zone = controller.selected;
  if (zone == null) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Row(children: [
        FugueIcon('application--minus.png'),
        SizedBox(width: 8),
        Text('Удалить направление?'),
      ]),
      content: Text(
          '«${zone.name}» (${zone.id}) будет удалено вместе со всеми ${zone.defCodes.length} кодами.'),
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
  if (confirmed == true) controller.deleteZone(zone.id);
}

/// Unsaved-changes switch guard, mirrors `command_sets/registry_pane.dart`'s
/// `requestSetSelection`.
Future<void> requestZoneSelection(
    BuildContext context, ZoneController controller, String id) async {
  if (controller.requestSelectZone(id)) return;
  final discard = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Есть несохранённые изменения'),
      content: const Text(
          'Сохраните текущее направление или отмените изменения перед переключением.'),
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
