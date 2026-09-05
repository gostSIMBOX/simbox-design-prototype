import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';
import 'models.dart';

/// Ordered, editable list of a zone's group-selection fallback rules — the
/// second editable body of a zone, below [ZoneCodeEditor]. Every mutation
/// (add/edit/reorder/delete) writes into the *same* per-zone draft as the
/// DEF-code textarea, so one Save/Cancel bar governs both (Requirements
/// Iteration 2, Acceptance Criteria #11-14).
class GroupRulesEditor extends StatelessWidget {
  final ZoneController controller;
  const GroupRulesEditor({super.key, required this.controller});

  static const algs = ['D', 'd', '^', '*', '>', '<'];
  static const types = ['=', '-', '_'];

  @override
  Widget build(BuildContext context) {
    final zone = controller.selected;
    final rules = zone?.groupRules ?? const <GroupRule>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Правила выбора группы (${rules.length})', style: T.panelTitle),
          const Spacer(),
          TextButton.icon(
            onPressed: zone == null ? null : controller.addGroupRule,
            icon: const FugueIcon('application--plus.png'),
            label: const Text('Добавить правило'),
          ),
        ]),
        const SizedBox(height: 8),
        if (rules.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: T.border),
              borderRadius: BorderRadius.circular(T.radiusCtl),
            ),
            child: const Center(
                child: Text('Правил пока нет. Нажмите «Добавить правило».',
                    style: T.caption)),
          )
        else
          for (var i = 0; i < rules.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _RuleRow(
                key: ValueKey(i),
                rule: rules[i],
                canMoveUp: i > 0,
                canMoveDown: i < rules.length - 1,
                onLimitSlot: (v) => controller.updateGroupRule(i, limitSlot: v),
                onAlg: (v) => controller.updateGroupRule(i, alg: v),
                onType: (v) => controller.updateGroupRule(i, type: v),
                onGroup: (v) => controller.updateGroupRule(i, group: v),
                onMoveUp: () => controller.moveGroupRule(i, -1),
                onMoveDown: () => controller.moveGroupRule(i, 1),
                onDelete: () => controller.removeGroupRule(i),
              ),
            ),
      ]),
    );
  }
}

class _RuleRow extends StatefulWidget {
  final GroupRule rule;
  final bool canMoveUp;
  final bool canMoveDown;
  final ValueChanged<int> onLimitSlot;
  final ValueChanged<String> onAlg;
  final ValueChanged<String> onType;
  final ValueChanged<String> onGroup;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const _RuleRow({
    super.key,
    required this.rule,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onLimitSlot,
    required this.onAlg,
    required this.onType,
    required this.onGroup,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  @override
  State<_RuleRow> createState() => _RuleRowState();
}

class _RuleRowState extends State<_RuleRow> {
  final _group = TextEditingController();
  String _syncedGroup = '';

  @override
  void initState() {
    super.initState();
    _sync();
  }

  void _sync() {
    _group.text = widget.rule.group;
    _syncedGroup = widget.rule.group;
  }

  @override
  void dispose() {
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rule.group != _syncedGroup) _sync();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(T.radiusCtl),
      ),
      child: Row(children: [
        _labeled(
            'L',
            DropdownButton<int>(
              value: widget.rule.limitSlot,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (var i = 0; i < 10; i++)
                  DropdownMenuItem(value: i, child: Text('$i'))
              ],
              onChanged: (v) {
                if (v != null) widget.onLimitSlot(v);
              },
            )),
        const SizedBox(width: 10),
        _labeled(
            'алг',
            DropdownButton<String>(
              value: widget.rule.alg,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final a in GroupRulesEditor.algs)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) {
                if (v != null) widget.onAlg(v);
              },
            )),
        const SizedBox(width: 10),
        _labeled(
            'тип',
            DropdownButton<String>(
              value: widget.rule.type,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final t in GroupRulesEditor.types)
                  DropdownMenuItem(value: t, child: Text(t)),
              ],
              onChanged: (v) {
                if (v != null) widget.onType(v);
              },
            )),
        const SizedBox(width: 10),
        _labeled(
            'группа',
            SizedBox(
              width: 70,
              child: TextField(
                controller: _group,
                style: T.mono,
                decoration: const InputDecoration(
                    isDense: true, border: OutlineInputBorder()),
                onChanged: (v) {
                  _syncedGroup = v;
                  widget.onGroup(v);
                },
              ),
            )),
        const Spacer(),
        _iconButton(Icons.arrow_upward, widget.canMoveUp, widget.onMoveUp),
        _iconButton(
            Icons.arrow_downward, widget.canMoveDown, widget.onMoveDown),
        _iconButton(Icons.delete_outline, true, widget.onDelete),
      ]),
    );
  }

  Widget _labeled(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: T.cellSub),
          child,
        ],
      );

  Widget _iconButton(IconData icon, bool enabled, VoidCallback onTap) =>
      SizedBox(
        width: 30,
        height: 30,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(6),
            child:
                Icon(icon, size: 16, color: enabled ? T.fgMuted : T.disabled),
          ),
        ),
      );
}
