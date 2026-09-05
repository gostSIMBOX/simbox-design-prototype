import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import '../command_sets/models.dart';
import 'controller.dart';
import 'plan_dialogs.dart';
import 'sections/section_fields.dart';

class PlanDetailHeader extends StatelessWidget {
  final PlanController controller;
  final List<CommandSet> commandSets;
  final bool narrow;
  const PlanDetailHeader({
    super.key,
    required this.controller,
    required this.commandSets,
    this.narrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected!;
    return Container(
      padding: EdgeInsets.fromLTRB(narrow ? 12 : 16, 12, 8, 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.hairline))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(plan.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.screenTitle.copyWith(fontSize: narrow ? 17 : 20))),
          PopupMenuButton<String>(
            tooltip: 'Действия с планом',
            icon: const FugueIcon('ui-menu.png',
                semanticLabel: 'Действия с планом'),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clone', child: Text('Клонировать')),
              // default is protected — the delete action itself is absent,
              // not merely blocked after confirmation (Specifications' edge
              // case table).
              if (plan.id != 'default')
                const PopupMenuItem(value: 'delete', child: Text('Удалить')),
            ],
            onSelected: (value) async {
              final commandSets = this.commandSets;
              if (value == 'clone') {
                await showCreatePlanDialog(context, controller, commandSets);
              } else if (value == 'delete') {
                await showDeletePlanDialog(context, controller);
              }
            },
          ),
        ]),
        const SizedBox(height: 6),
        Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: plan.commandSetId,
                  decoration: const InputDecoration(
                      labelText: 'Набор команд', isDense: true),
                  items: [
                    for (final set in commandSets)
                      DropdownMenuItem(value: set.id, child: Text(set.name)),
                  ],
                  onChanged: (v) {
                    if (v != null) controller.updateIdentity(commandSetId: v);
                  },
                ),
              ),
              IntField(
                key: ValueKey('priority-${plan.id}-${plan.priority}'),
                label: 'Приоритет',
                value: plan.priority,
                onChanged: (v) => controller.updateIdentity(priority: v),
              ),
              _ProTagField(
                key: ValueKey('pro-${plan.id}-${plan.proTag}'),
                value: plan.proTag,
                onChanged: (v) => controller.updateIdentity(
                    proTag: v, clearProTag: v == null),
              ),
              Text('используется ${controller.usageCount(plan.id)} симками',
                  style: T.cellSub),
            ]),
      ]),
    );
  }
}

/// Routing tag copied from Plan to SIM and compared by direction algorithms
/// P/p/v — not a product tier. Empty is the normal state for most plans.
class _ProTagField extends StatefulWidget {
  final String? value;
  final void Function(String? value) onChanged;
  const _ProTagField({super.key, required this.value, required this.onChanged});
  @override
  State<_ProTagField> createState() => _ProTagFieldState();
}

class _ProTagFieldState extends State<_ProTagField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value ?? '');
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChange);

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final text = _controller.text.trim();
    widget.onChanged(text.isEmpty ? null : text);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 160,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: T.body,
          decoration: InputDecoration(
            labelText: 'PRO (routing tag)',
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(T.radiusCtl)),
          ),
          onSubmitted: (_) => _commit(),
        ),
      );
}
