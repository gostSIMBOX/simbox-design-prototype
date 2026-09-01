import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';

/// Title + "Всего: N" + action groups, all on one row.
/// The expanded group opens as an overlay so the table never shifts.
class ActionsBar extends StatelessWidget {
  const ActionsBar({
    super.key,
    required this.title,
    required this.total,
    required this.selected,
    required this.openGroup,
    required this.onToggleGroup,
    required this.onRun,
  });

  final String title;
  final int total, selected;
  final String? openGroup;
  final ValueChanged<String> onToggleGroup;
  final void Function(ActionDef) onRun;

  @override
  Widget build(BuildContext context) {
    final hasSel = selected > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: T.rulePanel)),
      ),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: T.ink)),
          const SizedBox(width: 12),
          Text('Всего: $total',
              style: const TextStyle(fontSize: 13, color: T.fgMuted)),
          const SizedBox(width: 16),
          for (final g in actionGroups) ...[
            _GroupButton(
              group: g,
              open: openGroup == g.title,
              enabled: hasSel,
              onTap: () => onToggleGroup(g.title),
            ),
            const SizedBox(width: 6),
          ],
          const Spacer(),
          if (hasSel)
            Text('выбрано: $selected',
                style: const TextStyle(
                    fontSize: 12, color: T.brand, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GroupButton extends StatelessWidget {
  const _GroupButton({
    required this.group,
    required this.open,
    required this.enabled,
    required this.onTap,
  });

  final ActionGroup group;
  final bool open, enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: open ? T.rowSel : T.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: open ? T.brand.withOpacity(0.35) : T.ruleHead),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Ico(group.icon),
              const SizedBox(width: 6),
              Text(group.title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: open ? T.brand : T.fgBody)),
              const SizedBox(width: 4),
              Icon(open ? Icons.expand_less : Icons.expand_more,
                  size: 15, color: open ? T.brand : T.fg2),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Overlay sheet with the open group's commands.
class ActionsSheet extends StatelessWidget {
  const ActionsSheet({super.key, required this.group, required this.onRun});
  final ActionGroup group;
  final void Function(ActionDef) onRun;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FE),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: T.ruleHead)),
          boxShadow: const [
            BoxShadow(color: Color(0x599CB2C2), blurRadius: 32, offset: Offset(0, 12))
          ],
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in group.items)
              Tooltip(
                message: a.cmd,
                child: Material(
                  color: T.surface,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onRun(a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: T.ruleHead),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Ico(a.icon),
                        const SizedBox(width: 6),
                        Text(a.label,
                            style: const TextStyle(
                                fontSize: 12, color: T.fgBody)),
                      ]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
