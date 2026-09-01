import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';
import 'models.dart';

class CommandsSection extends StatelessWidget {
  final CommandSetController controller;
  final bool narrow;
  const CommandsSection(
      {super.key, required this.controller, this.narrow = false});

  @override
  Widget build(BuildContext context) {
    final set = controller.selected!;
    if (set.commands.isEmpty) {
      return _EmptyCommands(controller: controller, protected: set.isSystem);
    }
    final command = controller.selectedCommand ?? set.commands.first;
    final commandIndex =
        set.commands.indexWhere((item) => item.id == command.id);
    final visibleCommands = controller.visibleCommands;
    final menuCommands = visibleCommands.any((item) => item.id == command.id)
        ? visibleCommands
        : [command, ...visibleCommands];
    return ListView(padding: EdgeInsets.all(narrow ? 12 : 16), children: [
      Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
                width: narrow ? double.infinity : 330,
                child: DropdownButtonFormField<String>(
                  initialValue: command.id,
                  isDense: true,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Команда', border: OutlineInputBorder()),
                  items: [
                    for (final item in menuCommands)
                      DropdownMenuItem(
                          value: item.id,
                          child:
                              Text(item.name, overflow: TextOverflow.ellipsis))
                  ],
                  onChanged: (value) {
                    if (value != null) controller.selectCommand(value);
                  },
                )),
            SizedBox(
              width: narrow ? double.infinity : 220,
              child: TextField(
                onChanged: controller.setCommandQuery,
                decoration: const InputDecoration(
                    hintText: 'Найти команду',
                    prefixIcon: Center(child: FugueIcon('magnifier.png')),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 34, minHeight: 32),
                    isDense: true,
                    border: OutlineInputBorder()),
              ),
            ),
            if (!set.isSystem) ...[
              PopupMenuButton<CommandPurpose>(
                tooltip: 'Добавить команду',
                onSelected: controller.addCommand,
                itemBuilder: (_) => [
                  for (final purpose in CommandPurpose.values)
                    PopupMenuItem(value: purpose, child: Text(purpose.label))
                ],
                child: const _LabeledAction(
                    icon: 'application--plus.png', label: 'Добавить'),
              ),
              IconButton(
                  tooltip: 'Дублировать',
                  onPressed: () => controller.duplicateCommand(command.id),
                  icon: const FugueIcon('document-copy.png',
                      semanticLabel: 'Дублировать')),
              IconButton(
                  tooltip: 'Переместить вверх',
                  onPressed: commandIndex > 0
                      ? () => controller.reorderCommand(
                          commandIndex, commandIndex - 1)
                      : null,
                  icon: const FugueIcon('arrow-move.png',
                      semanticLabel: 'Переместить вверх')),
              IconButton(
                  tooltip: 'Удалить команду',
                  onPressed: () => controller.deleteCommand(command.id),
                  icon: const FugueIcon('application--minus.png',
                      semanticLabel: 'Удалить команду')),
            ],
          ]),
      const SizedBox(height: 14),
      Material(
        color: T.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(T.radiusCtl),
            side: const BorderSide(color: T.hairline)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!set.isSystem)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Команда включена', style: T.body),
                value: command.enabled,
                onChanged: (value) =>
                    controller.updateCommand(command.copyWith(enabled: value)),
              ),
            TextFormField(
              key: ValueKey('command-name-${command.id}'),
              initialValue: command.name,
              enabled: !set.isSystem,
              style: T.panelTitle,
              decoration:
                  const InputDecoration(labelText: 'Название', isDense: true),
              onChanged: (value) =>
                  controller.updateCommand(command.copyWith(name: value)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('command-description-${command.id}'),
              initialValue: command.description ?? '',
              enabled: !set.isSystem,
              style: T.body,
              decoration:
                  const InputDecoration(labelText: 'Описание', isDense: true),
              onChanged: (value) => controller
                  .updateCommand(command.copyWith(description: value)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Expanded(
                  child: Text('Параметры вызова', style: T.panelTitle)),
              if (!set.isSystem)
                TextButton.icon(
                    onPressed: () {
                      var index = command.parameters.length + 1;
                      var key = 'parameter_$index';
                      while (
                          command.parameters.any((item) => item.key == key)) {
                        index++;
                        key = 'parameter_$index';
                      }
                      controller.updateCommand(command.copyWith(parameters: [
                        ...command.parameters,
                        CommandParameter(
                            key: key,
                            label: 'Параметр $index',
                            type: ParameterType.text),
                      ]));
                    },
                    icon: const FugueIcon('application--plus.png'),
                    label: const Text('Добавить')),
            ]),
            if (command.parameters.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Параметры не требуются.', style: T.cellSub))
            else
              for (var i = 0; i < command.parameters.length; i++)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _ParameterEditor(
                      parameter: command.parameters[i],
                      enabled: !set.isSystem,
                      onChanged: (parameter) {
                        final parameters =
                            List<CommandParameter>.of(command.parameters)
                              ..[i] = parameter;
                        controller.updateCommand(
                            command.copyWith(parameters: parameters));
                      },
                      onDelete: () {
                        final parameters =
                            List<CommandParameter>.of(command.parameters)
                              ..removeAt(i);
                        controller.updateCommand(
                            command.copyWith(parameters: parameters));
                      },
                    )),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      Row(children: [
        const Expanded(
            child: Text('Последовательность действий', style: T.panelTitle)),
        if (!set.isSystem)
          PopupMenuButton<String>(
            tooltip: 'Добавить действие',
            onSelected: (kind) => _addOperation(controller, command, kind),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'ussd', child: Text('USSD-диалог')),
              PopupMenuItem(value: 'sms', child: Text('SMS')),
              PopupMenuItem(value: 'call', child: Text('Звонок')),
              PopupMenuItem(value: 'at', child: Text('AT-команда')),
            ],
            child: const _LabeledAction(
                icon: 'application--plus.png', label: 'Добавить действие'),
          ),
      ]),
      const SizedBox(height: 8),
      for (var i = 0; i < command.operations.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _OperationEditor(
            operation: command.operations[i],
            enabled: !set.isSystem,
            canMoveUp: i > 0,
            canMoveDown: i < command.operations.length - 1,
            onMoveUp: () {
              final operations = List<CommandOperation>.of(command.operations);
              final item = operations.removeAt(i);
              operations.insert(i - 1, item);
              controller
                  .updateCommand(command.copyWith(operations: operations));
            },
            onMoveDown: () {
              final operations = List<CommandOperation>.of(command.operations);
              final item = operations.removeAt(i);
              operations.insert(i + 1, item);
              controller
                  .updateCommand(command.copyWith(operations: operations));
            },
            onChanged: (operation) {
              final operations = List<CommandOperation>.of(command.operations)
                ..[i] = operation;
              controller
                  .updateCommand(command.copyWith(operations: operations));
            },
            onDelete: () {
              final operations = List<CommandOperation>.of(command.operations)
                ..removeAt(i);
              controller
                  .updateCommand(command.copyWith(operations: operations));
            },
          ),
        ),
    ]);
  }

  void _addOperation(
      CommandSetController controller, OperatorCommand command, String kind) {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final operation = switch (kind) {
      'sms' => SendSmsOperation('sms_$suffix',
          destinationTemplate: '', messageTemplate: ''),
      'call' => PlaceCallOperation('call_$suffix', numberTemplate: ''),
      'at' => SendAtOperation('at_$suffix', commandTemplate: ''),
      _ => UssdDialogOperation('ussd_$suffix', start: const UssdStart('')),
    };
    controller.updateCommand(
        command.copyWith(operations: [...command.operations, operation]));
  }
}

class _ParameterEditor extends StatelessWidget {
  final CommandParameter parameter;
  final bool enabled;
  final ValueChanged<CommandParameter> onChanged;
  final VoidCallback onDelete;

  const _ParameterEditor({
    required this.parameter,
    required this.enabled,
    required this.onChanged,
    required this.onDelete,
  });

  CommandParameter _copy({
    String? key,
    String? label,
    ParameterType? type,
    bool? required,
    bool? secret,
  }) {
    final nextType = type ?? parameter.type;
    return CommandParameter(
      key: key ?? parameter.key,
      label: label ?? parameter.label,
      type: nextType,
      required: required ?? parameter.required,
      secret: nextType == ParameterType.pin ? true : secret ?? parameter.secret,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Row(children: [
        const FugueIcon('information.png'),
        const SizedBox(width: 6),
        Expanded(
            child: Text(
                '${parameter.label} · {{${parameter.key}}}${parameter.secret ? ' · скрытый' : ''}',
                style: T.cell)),
      ]);
    }
    return Material(
      color: T.bg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(T.radiusCtl),
          side: const BorderSide(color: T.hairline)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(builder: (context, constraints) {
          final keyField = TextFormField(
            initialValue: parameter.key,
            style: T.protocolMono,
            decoration: const InputDecoration(
                labelText: 'Ключ шаблона',
                prefixText: '{{ ',
                suffixText: ' }}',
                isDense: true,
                border: OutlineInputBorder()),
            onChanged: (value) => onChanged(_copy(key: value)),
          );
          final labelField = TextFormField(
            initialValue: parameter.label,
            decoration: const InputDecoration(
                labelText: 'Название',
                isDense: true,
                border: OutlineInputBorder()),
            onChanged: (value) => onChanged(_copy(label: value)),
          );
          final typeField = DropdownButtonFormField<ParameterType>(
            initialValue: parameter.type,
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
                labelText: 'Тип', isDense: true, border: OutlineInputBorder()),
            items: [
              for (final type in ParameterType.values)
                DropdownMenuItem(value: type, child: Text(_typeLabel(type)))
            ],
            onChanged: (type) {
              if (type != null) onChanged(_copy(type: type));
            },
          );
          final fields = constraints.maxWidth < 560
              ? Column(children: [
                  keyField,
                  const SizedBox(height: 8),
                  labelField,
                  const SizedBox(height: 8),
                  typeField,
                ])
              : Row(children: [
                  Expanded(child: keyField),
                  const SizedBox(width: 8),
                  Expanded(child: labelField),
                  const SizedBox(width: 8),
                  SizedBox(width: 170, child: typeField),
                ]);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                fields,
                const SizedBox(height: 6),
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Checkbox(
                      value: parameter.required,
                      onChanged: (value) =>
                          onChanged(_copy(required: value ?? true))),
                  const Text('Обязательный'),
                  Checkbox(
                      value: parameter.secret,
                      onChanged: parameter.type == ParameterType.pin
                          ? null
                          : (value) =>
                              onChanged(_copy(secret: value ?? false))),
                  const Text('Скрытый'),
                  IconButton(
                      tooltip: 'Удалить параметр',
                      onPressed: onDelete,
                      icon: const FugueIcon('application--minus.png')),
                ]),
                if (parameter.type == ParameterType.pin ||
                    parameter.secret) ...[
                  const SizedBox(height: 4),
                  TextFormField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: T.protocolMono,
                    decoration: const InputDecoration(
                        labelText: 'Образец для проверки · не сохраняется',
                        isDense: true,
                        border: OutlineInputBorder()),
                  ),
                ],
              ]);
        }),
      ),
    );
  }

  static String _typeLabel(ParameterType type) => switch (type) {
        ParameterType.phoneNumber => 'Телефон',
        ParameterType.pin => 'PIN',
        ParameterType.text => 'Текст',
        ParameterType.integer => 'Целое число',
        ParameterType.decimal => 'Десятичное число',
      };
}

class _OperationEditor extends StatelessWidget {
  final CommandOperation operation;
  final bool enabled;
  final bool canMoveUp;
  final bool canMoveDown;
  final ValueChanged<CommandOperation> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  const _OperationEditor(
      {required this.operation,
      required this.enabled,
      required this.canMoveUp,
      required this.canMoveDown,
      required this.onChanged,
      required this.onDelete,
      required this.onMoveUp,
      required this.onMoveDown});

  String get icon => switch (operation) {
        UssdDialogOperation() => 'mobile-phone--arrow.png',
        SendSmsOperation() => 'mail.png',
        PlaceCallOperation() => 'telephone.png',
        SendAtOperation() => 'terminal.png',
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: T.bg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(T.radiusCtl),
          side: const BorderSide(color: T.hairline)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: FugueIcon(icon, semanticLabel: operation.typeLabel),
        title: Text(operation.typeLabel, style: T.panelTitle),
        subtitle: Text(_summary(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: T.protocolMono),
        trailing: enabled
            ? PopupMenuButton<String>(
                tooltip: 'Действия с шагом',
                onSelected: (action) {
                  if (action == 'up') onMoveUp();
                  if (action == 'down') onMoveDown();
                  if (action == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'up',
                          enabled: canMoveUp,
                          child: const _MenuAction(
                              icon: 'arrow-090.png', label: 'Выше')),
                      PopupMenuItem(
                          value: 'down',
                          enabled: canMoveDown,
                          child: const _MenuAction(
                              icon: 'arrow-270.png', label: 'Ниже')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: 'delete',
                          child: _MenuAction(
                              icon: 'application--minus.png',
                              label: 'Удалить')),
                    ],
                icon: const FugueIcon('application-task.png'))
            : null,
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [_fields()],
      ),
    );
  }

  String _summary() => switch (operation) {
        UssdDialogOperation o => [
            o.start.payloadTemplate,
            ...o.replies.map((r) => r.payloadTemplate)
          ].join(' → '),
        SendSmsOperation o => '${o.destinationTemplate} · ${o.messageTemplate}',
        PlaceCallOperation o => o.numberTemplate,
        SendAtOperation o => o.commandTemplate,
      };

  Widget _fields() {
    if (operation case final UssdDialogOperation value) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _protocolField(
            '${value.id}-start',
            'Start',
            value.start.payloadTemplate,
            enabled,
            (text) => onChanged(value.copyWith(
                start: value.start.copyWith(payloadTemplate: text)))),
        for (var i = 0; i < value.replies.length; i++) ...[
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Center(
                  child: Text('↓ после ответа оператора', style: T.cellSub))),
          LayoutBuilder(builder: (context, constraints) {
            final replyField = _protocolField(
                '${value.id}-${value.replies[i].id}-payload',
                'Reply ${i + 1}',
                value.replies[i].payloadTemplate,
                enabled, (text) {
              final replies = List<UssdReply>.of(value.replies)
                ..[i] = value.replies[i].copyWith(payloadTemplate: text);
              onChanged(value.copyWith(replies: replies));
            });
            final fallbackField = TextFormField(
              key: ValueKey('${value.id}-${value.replies[i].id}-fallback'),
              initialValue:
                  value.replies[i].fallbackAfterSeconds?.toString() ?? '',
              enabled: enabled,
              keyboardType: TextInputType.number,
              style: T.protocolMono,
              decoration: const InputDecoration(
                  labelText: 'Fallback, сек',
                  isDense: true,
                  border: OutlineInputBorder()),
              onChanged: (text) {
                final replies = List<UssdReply>.of(value.replies)
                  ..[i] = value.replies[i].copyWith(
                      fallbackAfterSeconds: int.tryParse(text),
                      clearFallback: text.trim().isEmpty);
                onChanged(value.copyWith(replies: replies));
              },
            );
            final replyActions = enabled
                ? PopupMenuButton<String>(
                    tooltip: 'Действия с Reply',
                    icon: const FugueIcon('application-task.png'),
                    onSelected: (action) {
                      final replies = List<UssdReply>.of(value.replies);
                      if (action == 'up' && i > 0) {
                        final item = replies.removeAt(i);
                        replies.insert(i - 1, item);
                      }
                      if (action == 'down' && i < replies.length - 1) {
                        final item = replies.removeAt(i);
                        replies.insert(i + 1, item);
                      }
                      if (action == 'delete') replies.removeAt(i);
                      onChanged(value.copyWith(replies: replies));
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'up',
                          enabled: i > 0,
                          child: const _MenuAction(
                              icon: 'arrow-090.png', label: 'Выше')),
                      PopupMenuItem(
                          value: 'down',
                          enabled: i < value.replies.length - 1,
                          child: const _MenuAction(
                              icon: 'arrow-270.png', label: 'Ниже')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: 'delete',
                          child: _MenuAction(
                              icon: 'application--minus.png',
                              label: 'Удалить')),
                    ],
                  )
                : null;
            if (constraints.maxWidth < 470) {
              return Column(children: [
                replyField,
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: fallbackField),
                  if (replyActions != null) replyActions,
                ]),
              ]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: replyField),
              const SizedBox(width: 8),
              SizedBox(width: 145, child: fallbackField),
              if (replyActions != null) replyActions,
            ]);
          }),
        ],
        if (enabled)
          Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onChanged(value.copyWith(replies: [
                  ...value.replies,
                  UssdReply(
                      'reply_${DateTime.now().microsecondsSinceEpoch}', '')
                ])),
                icon: const FugueIcon('application--plus.png'),
                label: const Text('Добавить Reply'),
              )),
      ]);
    }
    if (operation case final SendSmsOperation value) {
      return Column(children: [
        _protocolField(
            '${value.id}-destination',
            'Получатель',
            value.destinationTemplate,
            enabled,
            (text) => onChanged(value.copyWith(destinationTemplate: text))),
        const SizedBox(height: 8),
        _protocolField(
            '${value.id}-message',
            'Текст SMS',
            value.messageTemplate,
            enabled,
            (text) => onChanged(value.copyWith(messageTemplate: text))),
      ]);
    }
    if (operation case final PlaceCallOperation value) {
      return _protocolField('${value.id}-number', 'Номер', value.numberTemplate,
          enabled, (text) => onChanged(value.copyWith(numberTemplate: text)));
    }
    final value = operation as SendAtOperation;
    return _protocolField(
        '${value.id}-command',
        'AT-команда',
        value.commandTemplate,
        enabled,
        (text) => onChanged(value.copyWith(commandTemplate: text)));
  }
}

Widget _protocolField(String fieldKey, String label, String value, bool enabled,
        ValueChanged<String> onChanged) =>
    TextFormField(
      key: ValueKey(fieldKey),
      initialValue: value,
      enabled: enabled,
      style: T.protocolMono,
      decoration: InputDecoration(
          labelText: label, isDense: true, border: const OutlineInputBorder()),
      onChanged: onChanged,
    );

class _LabeledAction extends StatelessWidget {
  final String icon, label;
  const _LabeledAction({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: T.denseHit),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
            border: Border.all(color: T.border),
            borderRadius: BorderRadius.circular(T.radiusCtl)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          FugueIcon(icon),
          const SizedBox(width: 6),
          Text(label, style: T.body)
        ]),
      );
}

class _MenuAction extends StatelessWidget {
  final String icon;
  final String label;
  const _MenuAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        FugueIcon(icon),
        const SizedBox(width: 8),
        Text(label),
      ]);
}

class _EmptyCommands extends StatelessWidget {
  final CommandSetController controller;
  final bool protected;
  const _EmptyCommands({required this.controller, required this.protected});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FugueIcon(protected ? 'lock.png' : 'application-task.png',
                size: 16),
            const SizedBox(height: 10),
            Text(
                protected
                    ? 'В системном fallback нет явных команд.'
                    : 'В наборе пока нет команд.',
                style: T.body),
            if (!protected) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                  onPressed: () =>
                      controller.addCommand(CommandPurpose.getBalance),
                  icon: const FugueIcon('application--plus.png'),
                  label: const Text('Добавить первую команду'))
            ],
          ])));
}
