import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';

/// Dense grid: one horizontal scroller, a pinned header band,
/// only the body scrolls vertically.
class SimTable extends StatefulWidget {
  const SimTable({
    super.key,
    required this.rows,
    required this.selected,
    required this.onToggleRow,
    required this.onToggleAll,
  });

  final List<Sim> rows;
  final Set<int> selected;
  final ValueChanged<int> onToggleRow;
  final VoidCallback onToggleAll;

  @override
  State<SimTable> createState() => _SimTableState();
}

class _SimTableState extends State<SimTable> {
  final _h = ScrollController();
  String _sort = 'group';
  int _dir = 1;

  double get _tableWidth =>
      34 + simColumns.fold<double>(0, (a, c) => a + c.width);

  List<Sim> get _sorted {
    final l = [...widget.rows];
    int cmp(Sim a, Sim b) {
      switch (_sort) {
        case 'group':
          return a.group.compareTo(b.group);
        case 'bal':
          return a.bal.compareTo(b.bal);
        case 'acdo':
          return a.acdo.compareTo(b.acdo);
        case 'datt':
          return a.datt.compareTo(b.datt);
        case 'number':
          return a.number.compareTo(b.number);
        case 'oper':
          return a.oper.compareTo(b.oper);
        default:
          return a.id.compareTo(b.id);
      }
    }

    l.sort((a, b) => cmp(a, b) * _dir);
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _sorted;
    return Scrollbar(
      controller: _h,
      child: SingleChildScrollView(
        controller: _h,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _tableWidth,
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemExtent: 34,
                  itemBuilder: (_, i) => _row(rows[i], i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      color: T.headBg,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 34,
            child: Checkbox(
              value: widget.selected.length == widget.rows.length &&
                  widget.rows.isNotEmpty,
              tristate: false,
              visualDensity: VisualDensity.compact,
              onChanged: (_) => widget.onToggleAll(),
            ),
          ),
          for (final c in simColumns)
            SizedBox(
              width: c.width,
              child: InkWell(
                onTap: () => setState(() {
                  if (_sort == c.key) {
                    _dir = -_dir;
                  } else {
                    _sort = c.key;
                    _dir = 1;
                  }
                }),
                child: Tooltip(
                  message: c.tooltip.isEmpty ? c.key : c.tooltip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (c.icon.isNotEmpty) Ico(c.icon),
                        if (c.label.isNotEmpty)
                          Text(
                            c.label + (_sort == c.key ? (_dir > 0 ? ' ↑' : ' ↓') : ''),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                color: T.ink),
                          ),
                        if (c.sub.isNotEmpty)
                          Text(c.sub,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                  fontSize: 10, height: 1.2, color: T.fgMuted)),
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

  Widget _row(Sim s, int i) {
    final sel = widget.selected.contains(s.id);
    final bg = sel ? T.rowSel : (i.isOdd ? T.rowOdd : T.rowEven);
    return InkWell(
      onTap: () => widget.onToggleRow(s.id),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(bottom: BorderSide(color: T.ruleRow)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Checkbox(
                value: sel,
                visualDensity: VisualDensity.compact,
                onChanged: (_) => widget.onToggleRow(s.id),
              ),
            ),
            for (final c in simColumns)
              SizedBox(
                width: c.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _cell(c.key, s),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stack(List<Widget> lines) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: lines,
      );

  Widget _p(String v, {bool warn = false}) => Text(v,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: TextStyle(
          fontSize: 12,
          height: 1.3,
          fontWeight: warn ? FontWeight.w700 : FontWeight.w400,
          color: warn ? T.danger : T.fg1));

  Widget _s(String v) => Text(v,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: const TextStyle(fontSize: 10, height: 1.25, color: T.fgMuted));

  Widget _t(String v) => Text(v,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: const TextStyle(fontSize: 10, height: 1.25, color: T.fg2));

  Widget _m(String v) => Text(v,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: const TextStyle(
          fontSize: 11, height: 1.3, fontFamily: T.mono, color: T.fg1));

  Widget _icons(List<String?> paths) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final p in paths.whereType<String>()) ...[
            Ico(p),
            const SizedBox(width: 2),
          ]
        ],
      );

  Widget _cell(String k, Sim s) {
    switch (k) {
      case 'group':
        return _stack([_icons([groupIcon(s.group)]), _s('${s.group}')]);
      case 'cap':
        return _icons([capIcon(s.cap)]);
      case 'im':
        return _icons([imIcon(s.im)]);
      case 'spec':
        return _icons([specIcon(s.spec)]);
      case 'io':
        return _icons([ioIcon(s.io), qosIcon(s.qos)]);
      case 'napr':
        return _icons([s.napr]);
      case 'plan':
        return _stack([_p(s.plan), _s('${s.nabor} / ${s.tarif}')]);
      case 'number':
        return _m(s.number);
      case 'oper':
        return _stack([_p(s.oper), _s(s.sim)]);
      case 'bal':
        return _stack([
          _t(s.balAge),
          _p(s.bal.toStringAsFixed(2), warn: s.balWarn),
          _s(s.balDiff),
        ]);
      case 'model':
        return _icons([dongleIcon(s.model), cfunIcon(s.cfun)]);
      case 'simst':
        return _icons([
          s.simst == 'ready' ? 'state/simst/ready.png' : 'simblocked.ico',
          s.srvst == 'registered' ? 'state/srvst/reg.png' : 'state/srvst/search.png',
        ]);
      case 'dongle':
        return _m(s.dongle);
      case 'tot':
        return _stack([_p('${s.tot}'), _t(s.totSub)]);
      case 'ao':
        return _stack([_p('${s.ao}'), _s('${s.ai}')]);
      case 'mo':
        return _stack([_p('${s.mo}'), _s('${s.mi}')]);
      case 'acdo':
        return _p(s.acdo.toStringAsFixed(0));
      case 'datt':
        return _p(s.datt.toStringAsFixed(1));
      default:
        return const SizedBox();
    }
  }
}
