import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';
import 'models.dart';
import 'response_preview.dart';

class ResponseRulesSection extends StatefulWidget {
  final CommandSetController controller;
  final bool narrow;
  const ResponseRulesSection(
      {super.key, required this.controller, this.narrow = false});

  @override
  State<ResponseRulesSection> createState() => _ResponseRulesSectionState();
}

class _ResponseRulesSectionState extends State<ResponseRulesSection> {
  final sample = TextEditingController();
  String? testRuleId;
  ResponsePreview? preview;

  CommandSetController get controller => widget.controller;

  @override
  void dispose() {
    sample.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final set = controller.selected!;
    final rules = controller.visibleRules;
    testRuleId ??= set.responseRules.firstOrNull?.id;
    return ListView(
        padding: EdgeInsets.all(widget.narrow ? 12 : 16),
        children: [
          Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                    width: widget.narrow ? double.infinity : 280,
                    child: TextField(
                      onChanged: controller.setRuleQuery,
                      style: T.body,
                      decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Поиск правил',
                          prefixIcon: Center(child: FugueIcon('magnifier.png')),
                          prefixIconConstraints:
                              BoxConstraints.tightFor(width: 34),
                          border: OutlineInputBorder()),
                    )),
                SizedBox(
                    width: 190,
                    child: DropdownButtonFormField<ResponseChannel?>(
                      isExpanded: true,
                      initialValue: controller.channelFilter,
                      decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Канал',
                          border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('Все каналы')),
                        DropdownMenuItem(
                            value: ResponseChannel.ussd, child: Text('USSD')),
                        DropdownMenuItem(
                            value: ResponseChannel.sms, child: Text('SMS')),
                        DropdownMenuItem(
                            value: ResponseChannel.callResult,
                            child: Text('Результат звонка')),
                      ],
                      onChanged: controller.setChannelFilter,
                    )),
                if (!set.isSystem)
                  FilledButton.icon(
                      onPressed: controller.addRule,
                      icon: const FugueIcon('funnel--plus.png'),
                      label: const Text('Добавить правило')),
              ]),
          const SizedBox(height: 12),
          if (rules.isEmpty)
            _EmptyRules(protected: set.isSystem, onAdd: controller.addRule)
          else
            for (var i = 0; i < rules.length; i++)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RuleCard(
                    rule: rules[i],
                    enabled: !set.isSystem,
                    onChanged: controller.updateRule,
                    onDuplicate: () => controller.duplicateRule(rules[i].id),
                    onDelete: () => controller.deleteRule(rules[i].id),
                    onMoveUp: i > 0
                        ? () => controller.reorderRule(
                            set.responseRules.indexOf(rules[i]),
                            set.responseRules.indexOf(rules[i]) - 1)
                        : null,
                  )),
          if (set.responseRules.isNotEmpty) ...[
            const SizedBox(height: 6),
            _tester(set),
          ],
        ]);
  }

  Widget _tester(CommandSet set) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.radiusCtl),
            border: Border.all(color: T.hairline)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Row(children: [
            FugueIcon('beaker.png'),
            SizedBox(width: 8),
            Text('Проверить ответ', style: T.panelTitle),
            Spacer(),
            Text('Без записи', style: T.cellSub)
          ]),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: set.responseRules.any((item) => item.id == testRuleId)
                ? testRuleId
                : set.responseRules.first.id,
            decoration: const InputDecoration(
                labelText: 'Правило',
                isDense: true,
                border: OutlineInputBorder()),
            items: [
              for (final rule in set.responseRules)
                DropdownMenuItem(value: rule.id, child: Text(rule.name))
            ],
            onChanged: (value) => setState(() {
              testRuleId = value;
              preview = null;
            }),
          ),
          const SizedBox(height: 8),
          TextField(
              controller: sample,
              minLines: 2,
              maxLines: 4,
              style: T.protocolMono,
              decoration: const InputDecoration(
                  labelText: 'Пример ответа оператора',
                  border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => setState(() => preview = controller.testRule(
                    testRuleId ?? set.responseRules.first.id, sample.text)),
                icon: const FugueIcon('beaker.png'),
                label: const Text('Проверить'),
              )),
          if (preview != null) ...[
            const SizedBox(height: 10),
            _PreviewResult(preview!)
          ],
        ]),
      );
}

class _RuleCard extends StatelessWidget {
  final ResponseRule rule;
  final bool enabled;
  final ValueChanged<ResponseRule> onChanged;
  final VoidCallback onDuplicate, onDelete;
  final VoidCallback? onMoveUp;
  const _RuleCard(
      {required this.rule,
      required this.enabled,
      required this.onChanged,
      required this.onDuplicate,
      required this.onDelete,
      this.onMoveUp});

  @override
  Widget build(BuildContext context) => Material(
        color: T.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(T.radiusCtl),
            side: const BorderSide(color: T.hairline)),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: const FugueIcon('funnel--pencil.png'),
          title: Row(children: [
            Expanded(child: Text(rule.name, style: T.panelTitle)),
            Text(rule.enabled ? 'Включено' : 'Выключено', style: T.cellSub)
          ]),
          subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WHEN  ${_matchSummary()}', style: T.cell),
                    Text(
                        'TAKE   ${rule.effects.isEmpty ? '—' : rule.effects.map((item) => item.field.label).join(', ')}',
                        style: T.cell),
                    Text(
                        'SAVE   ${rule.outcome?.label ?? rule.effects.map((item) => item.field.label).join(', ')}',
                        style: T.cell),
                  ])),
          trailing: enabled
              ? PopupMenuButton<String>(
                  icon: const FugueIcon('ui-menu.png'),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'copy', child: Text('Дублировать')),
                    if (onMoveUp != null)
                      const PopupMenuItem(
                          value: 'up', child: Text('Переместить вверх')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Удалить')),
                  ],
                  onSelected: (value) {
                    if (value == 'copy') onDuplicate();
                    if (value == 'up') onMoveUp?.call();
                    if (value == 'delete') onDelete();
                  },
                )
              : null,
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          children: [_editor()],
        ),
      );

  String _matchSummary() => switch (rule.matcher.mode) {
        MatchMode.contains => 'содержит «${rule.matcher.pattern}»',
        MatchMode.startsWith => 'начинается с «${rule.matcher.pattern}»',
        MatchMode.regularExpression => 'regex `${rule.matcher.pattern}`',
      };

  Widget _editor() =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: TextFormField(
                  key: ValueKey('${rule.id}-name'),
                  initialValue: rule.name,
                  enabled: enabled,
                  decoration: const InputDecoration(
                      labelText: 'Название', isDense: true),
                  onChanged: (value) => onChanged(rule.copyWith(name: value)))),
          const SizedBox(width: 12),
          Switch(
              value: rule.enabled,
              onChanged: enabled
                  ? (value) => onChanged(rule.copyWith(enabled: value))
                  : null),
        ]),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, constraints) {
          final mode = _matchModeField();
          final pattern = _matchPatternField();
          if (constraints.maxWidth < 560) {
            return Column(children: [mode, const SizedBox(height: 8), pattern]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 190, child: mode),
            const SizedBox(width: 10),
            Expanded(child: pattern),
          ]);
        }),
        const SizedBox(height: 12),
        for (var i = 0; i < rule.effects.length; i++)
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EffectRow(
                effect: rule.effects[i],
                enabled: enabled,
                onChanged: (effect) {
                  final effects = List<ResponseEffect>.of(rule.effects)
                    ..[i] = effect;
                  onChanged(rule.copyWith(effects: effects));
                },
                onDelete: () {
                  final effects = List<ResponseEffect>.of(rule.effects)
                    ..removeAt(i);
                  onChanged(rule.copyWith(effects: effects));
                },
              )),
        if (enabled)
          Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onChanged(rule.copyWith(effects: [
                  ...rule.effects,
                  const ResponseEffect(
                      field: ResponseField.remainingMinutes,
                      source: ValueSource.capture,
                      captureNameOrIndex: '1',
                      normalizers: [Normalizer.integerNumber])
                ])),
                icon: const FugueIcon('funnel--plus.png'),
                label: const Text('Добавить TAKE / SAVE'),
              )),
        const SizedBox(height: 4),
        DropdownButtonFormField<SemanticOutcome?>(
          isExpanded: true,
          initialValue: rule.outcome,
          decoration: const InputDecoration(
              labelText: 'EMIT · семантический результат (необязательно)',
              isDense: true,
              border: OutlineInputBorder()),
          items: [
            const DropdownMenuItem(value: null, child: Text('Без результата')),
            for (final outcome in SemanticOutcome.values)
              DropdownMenuItem(value: outcome, child: Text(outcome.label))
          ],
          onChanged: enabled
              ? (value) => onChanged(
                  rule.copyWith(outcome: value, clearOutcome: value == null))
              : null,
        ),
      ]);

  Widget _matchModeField() => DropdownButtonFormField<MatchMode>(
        isExpanded: true,
        initialValue: rule.matcher.mode,
        decoration: const InputDecoration(
            labelText: 'WHEN', isDense: true, border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: MatchMode.contains, child: Text('Содержит')),
          DropdownMenuItem(
              value: MatchMode.startsWith, child: Text('Начинается с')),
          DropdownMenuItem(
              value: MatchMode.regularExpression,
              child: Text('Regex · Advanced')),
        ],
        onChanged: enabled
            ? (value) {
                if (value != null) {
                  onChanged(rule.copyWith(
                      matcher: rule.matcher.copyWith(mode: value)));
                }
              }
            : null,
      );

  Widget _matchPatternField() => TextFormField(
      key: ValueKey('${rule.id}-pattern'),
      initialValue: rule.matcher.pattern,
      enabled: enabled,
      style: rule.matcher.mode == MatchMode.regularExpression
          ? T.protocolMono
          : T.body,
      decoration: const InputDecoration(
          labelText: 'Шаблон ответа',
          isDense: true,
          border: OutlineInputBorder()),
      onChanged: (value) => onChanged(
          rule.copyWith(matcher: rule.matcher.copyWith(pattern: value))));
}

class _EffectRow extends StatelessWidget {
  final ResponseEffect effect;
  final bool enabled;
  final ValueChanged<ResponseEffect> onChanged;
  final VoidCallback onDelete;
  const _EffectRow(
      {required this.effect,
      required this.enabled,
      required this.onChanged,
      required this.onDelete});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(children: [
            _fieldPicker(),
            const SizedBox(height: 8),
            _sourcePicker(),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _valueField()),
              if (enabled)
                IconButton(
                    tooltip: 'Удалить результат',
                    onPressed: onDelete,
                    icon: const FugueIcon('application--minus.png')),
            ]),
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _fieldPicker()),
          const SizedBox(width: 8),
          SizedBox(width: 155, child: _sourcePicker()),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: _valueField()),
          if (enabled)
            IconButton(
                tooltip: 'Удалить результат',
                onPressed: onDelete,
                icon: const FugueIcon('application--minus.png')),
        ]);
      });

  Widget _fieldPicker() => DropdownButtonFormField<ResponseField>(
      isExpanded: true,
      initialValue: effect.field,
      decoration: const InputDecoration(
          labelText: 'SAVE', isDense: true, border: OutlineInputBorder()),
      items: [
        for (final field in ResponseField.values)
          DropdownMenuItem(value: field, child: Text(field.label))
      ],
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(effect.copyWith(field: value));
            }
          : null);

  Widget _sourcePicker() => DropdownButtonFormField<ValueSource>(
      isExpanded: true,
      initialValue: effect.source,
      decoration: const InputDecoration(
          labelText: 'TAKE', isDense: true, border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(
            value: ValueSource.fullMatch, child: Text('Всё совпадение')),
        DropdownMenuItem(
            value: ValueSource.capture, child: Text('Группа regex')),
        DropdownMenuItem(
            value: ValueSource.fixedValue, child: Text('Фиксированное')),
      ],
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(effect.copyWith(source: value));
            }
          : null);

  Widget _valueField() => TextFormField(
        key: ValueKey(
            '${effect.field}-${effect.source}-${effect.captureNameOrIndex}-${effect.fixedValue}'),
        initialValue: effect.source == ValueSource.fixedValue
            ? effect.fixedValue ?? ''
            : effect.captureNameOrIndex ?? '',
        enabled: enabled && effect.source != ValueSource.fullMatch,
        style: T.protocolMono,
        decoration: InputDecoration(
            labelText:
                effect.source == ValueSource.fixedValue ? 'Значение' : 'Группа',
            isDense: true,
            border: const OutlineInputBorder()),
        onChanged: (value) => onChanged(effect.source == ValueSource.fixedValue
            ? effect.copyWith(fixedValue: value)
            : effect.copyWith(captureNameOrIndex: value)),
      );
}

class _PreviewResult extends StatelessWidget {
  final ResponsePreview preview;
  const _PreviewResult(this.preview);
  @override
  Widget build(BuildContext context) {
    final ok = preview.matched && preview.error == null;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: ok ? const Color(0x101FB67A) : const Color(0x10E5484D),
          borderRadius: BorderRadius.circular(T.radiusCtl)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FugueIcon(ok ? 'tick.png' : 'exclamation.png'),
        const SizedBox(width: 8),
        Expanded(
            child: Text(
                preview.error ??
                    (!preview.matched
                        ? 'Совпадений нет. Без записи.'
                        : [
                            if (preview.matchedText != null)
                              'Совпадение: ${preview.matchedText}',
                            ...preview.values.entries.map(
                                (item) => '${item.key.label}: ${item.value}'),
                            if (preview.outcome != null)
                              'Результат: ${preview.outcome!.label}',
                            'Без записи.',
                          ].join('\n')),
                style: ok ? T.cell : T.cellAlarm)),
      ]),
    );
  }
}

class _EmptyRules extends StatelessWidget {
  final bool protected;
  final VoidCallback onAdd;
  const _EmptyRules({required this.protected, required this.onAdd});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        FugueIcon(protected ? 'lock.png' : 'funnel--pencil.png'),
        const SizedBox(height: 10),
        Text(
            protected
                ? 'В системном fallback нет явных правил.'
                : 'В наборе пока нет правил ответа.',
            style: T.body),
        if (!protected) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
              onPressed: onAdd,
              icon: const FugueIcon('funnel--plus.png'),
              label: const Text('Добавить первое правило'))
        ],
      ]));
}
