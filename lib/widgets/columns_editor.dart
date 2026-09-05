import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import 'action_group_bar.dart';

/// Inline column show/hide/reorder editor — occupies the same toolbar-row
/// slot as [ActionRail] (mutually exclusive, toggled by [AppState.columnsOpen]).
/// Never grows vertically: overflow scrolls horizontally, same as the rail.
class ColumnsEditor extends StatelessWidget {
  final AdmPage page;
  final List<({String key, String label})> allColumns;
  const ColumnsEditor(
      {super.key, required this.page, required this.allColumns});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final defaults = [for (final c in allColumns) c.key];
    final order = st.columnOrderFor(page, defaults);
    final hidden = st.hiddenColumnsFor(page);
    final labelOf = {for (final c in allColumns) c.key: c.label};

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RailIconButton(
              icon: Icons.arrow_back,
              tooltip: 'Отмена',
              onTap: st.toggleColumns),
          const SizedBox(width: 8),
          RailIconButton(
            icon: Icons.refresh,
            tooltip: 'Сбросить',
            onTap: () => st.resetColumns(page, defaults),
          ),
          const SizedBox(width: 10),
          for (var i = 0; i < order.length; i++) ...[
            _ColumnChip(
              label: labelOf[order[i]] ?? order[i],
              checked: !hidden.contains(order[i]),
              canMoveLeft: i > 0,
              canMoveRight: i < order.length - 1,
              onToggle: () => st.toggleColumnHidden(page, order[i]),
              onMoveLeft: () => st.moveColumn(page, order[i], -1, defaults),
              onMoveRight: () => st.moveColumn(page, order[i], 1, defaults),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _ColumnChip extends StatelessWidget {
  final String label;
  final bool checked;
  final bool canMoveLeft;
  final bool canMoveRight;
  final VoidCallback onToggle;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  const _ColumnChip({
    required this.label,
    required this.checked,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.onToggle,
    required this.onMoveLeft,
    required this.onMoveRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 4, right: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(T.radiusCtl),
        border: Border.all(color: T.border),
        color: T.surface,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
              value: checked,
              onChanged: (_) => onToggle(),
              activeColor: T.brandDeep),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontFamily: 'SF Pro Text', fontSize: 11, color: T.fg1),
            overflow: TextOverflow.ellipsis),
        _moveButton(Icons.chevron_left, canMoveLeft, onMoveLeft),
        _moveButton(Icons.chevron_right, canMoveRight, onMoveRight),
      ]),
    );
  }

  Widget _moveButton(IconData icon, bool enabled, VoidCallback onTap) {
    return SizedBox(
      width: 22,
      height: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(5),
          child: Icon(icon, size: 16, color: enabled ? T.fgMuted : T.disabled),
        ),
      ),
    );
  }
}
