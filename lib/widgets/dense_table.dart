import 'package:flutter/material.dart';
import '../data/models.dart';
import '../design/tokens.dart';
import 'adm_icon.dart';

/// Dense operations table.
///
/// Explicit column widths + one horizontal scroller, so the header band and the
/// body stay locked together. Zebra is the brand tint at ascending strength —
/// odd 3.5%, header 5%, selected 9% — so a selected odd row still reads as
/// selected without a second neutral entering the palette.
///
/// The header row is pinned; only the row list scrolls vertically (both live
/// inside the same horizontal scroller, so they pan sideways together). The
/// widget therefore needs a bounded height from its parent (e.g. `Expanded`).
class DenseTable<TRow> extends StatefulWidget {
  final List<ColDef<TRow>> cols;
  final List<TRow> rows;
  final int Function(TRow) idOf;
  final bool Function(int) isSelected;
  final void Function(int) onToggleRow;
  final VoidCallback onToggleAll;
  final String? sortKey;
  final int sortDir;
  final void Function(String) onSort;

  const DenseTable({
    super.key,
    required this.cols,
    required this.rows,
    required this.idOf,
    required this.isSelected,
    required this.onToggleRow,
    required this.onToggleAll,
    required this.sortKey,
    required this.sortDir,
    required this.onSort,
  });

  @override
  State<DenseTable<TRow>> createState() => _DenseTableState<TRow>();
}

class _DenseTableState<TRow> extends State<DenseTable<TRow>> {
  final _vCtrl = ScrollController();

  @override
  void dispose() {
    _vCtrl.dispose();
    super.dispose();
  }

  static const double _checkW = 34;

  double get _totalWidth =>
      _checkW + widget.cols.fold<double>(0, (a, c) => a + c.w);

  @override
  Widget build(BuildContext context) {
    final rows = widget.rows;
    final allSelected =
        rows.isNotEmpty && rows.every((r) => widget.isSelected(widget.idOf(r)));
    return Container(
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.radiusCard),
        boxShadow: T.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _totalWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(allSelected),
                Expanded(
                  child: rows.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Ничего не найдено', style: T.caption),
                        )
                      : Scrollbar(
                          controller: _vCtrl,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _vCtrl,
                            itemCount: rows.length,
                            itemBuilder: (_, i) => _row(rows[i], i),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(bool allSelected) {
    final cols = widget.cols;
    final sortKey = widget.sortKey;
    final sortDir = widget.sortDir;
    return Container(
      decoration: const BoxDecoration(
        color: T.headBg,
        border: Border(bottom: BorderSide(color: T.headSep)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: _checkW,
            child: Padding(
              padding: T.headPad,
              child: SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: allSelected,
                  onChanged: (_) => widget.onToggleAll(),
                  activeColor: T.brandDeep,
                ),
              ),
            ),
          ),
          for (final c in cols)
            SizedBox(
              width: c.w,
              child: InkWell(
                onTap: () => widget.onSort(c.key),
                child: Tooltip(
                  message: c.title ?? c.key,
                  child: Padding(
                    padding: T.headPad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (c.icon != null) ...[
                          AdmIcon(c.icon!),
                          const SizedBox(height: 2)
                        ],
                        Text(
                          c.label +
                              (sortKey == c.key
                                  ? (sortDir > 0 ? ' ↑' : ' ↓')
                                  : ''),
                          style: T.head,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (c.sub.isNotEmpty)
                          Text(c.sub,
                              style: T.headSub,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(TRow r, int index) {
    final id = widget.idOf(r);
    final sel = widget.isSelected(id);
    return Container(
      decoration: BoxDecoration(
        color: sel ? T.rowSel : (index.isOdd ? T.rowOdd : T.rowEven),
        border: const Border(bottom: BorderSide(color: T.rowSep)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _checkW,
            child: Padding(
              padding: T.cellPad,
              child: SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: sel,
                  onChanged: (_) => widget.onToggleRow(id),
                  activeColor: T.brandDeep,
                ),
              ),
            ),
          ),
          for (final c in widget.cols)
            SizedBox(width: c.w, child: _cell(c.build(r))),
        ],
      ),
    );
  }

  /// Stacked cell, ranked by ink: note → icons → primary → mono → alarm → subs.
  Widget _cell(Cell c) {
    final children = <Widget>[];
    if (c.note.isNotEmpty) children.add(Text(c.note, style: T.cellTertiary));
    if (c.icons.isNotEmpty) children.add(IconStack(c.icons));
    if (c.text.isNotEmpty) {
      children.add(Text(c.text,
          style: c.pending ? T.cell.copyWith(color: T.brandDeep) : T.cell));
    }
    if (c.mono.isNotEmpty) children.add(Text(c.mono, style: T.mono));
    if (c.warn.isNotEmpty) children.add(Text(c.warn, style: T.cellAlarm));
    if (c.sub.isNotEmpty) children.add(Text(c.sub, style: T.cellSub));
    if (c.sub2.isNotEmpty) children.add(Text(c.sub2, style: T.cellTertiary));
    for (final l in c.links) {
      children.add(_HoverLog(l));
    }
    return Padding(
      padding: T.cellPad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// `showlog_cut.php` — the log that popped up under the cursor.
class _HoverLog extends StatelessWidget {
  final LogLink link;
  const _HoverLog(this.link);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: TextSpan(children: [
        TextSpan(
            text: '${link.title}\n',
            style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: T.ink)),
        TextSpan(text: link.lines.join('\n'), style: T.monoDim),
      ]),
      child: MouseRegion(
        cursor: SystemMouseCursors.help,
        child: Text(
          link.label,
          style: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 11,
            color: T.brandDeep,
            decoration: TextDecoration.underline,
            decorationColor: T.brandDeep,
          ),
        ),
      ),
    );
  }
}
