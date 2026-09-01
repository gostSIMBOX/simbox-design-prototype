import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';
import 'widgets/actions_bar.dart';
import 'widgets/sidebar.dart';
import 'widgets/sim_table.dart';

void main() => runApp(const AdminkaApp());

class AdminkaApp extends StatelessWidget {
  const AdminkaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SimBox Adminka',
        debugShowCheckedModeBanner: false,
        theme: T.data(),
        home: const AdminkaShell(),
      );
}

class AdminkaShell extends StatefulWidget {
  const AdminkaShell({super.key});
  @override
  State<AdminkaShell> createState() => _AdminkaShellState();
}

class _AdminkaShellState extends State<AdminkaShell> {
  bool _navOpen = true;
  String _page = 'sim';
  String? _openGroup;
  final Set<int> _selected = {};
  final List<String> _log = [];

  void _run(ActionDef a) {
    final ids = _selected.toList()..sort();
    setState(() {
      for (final id in ids) {
        if (a.cmd.startsWith('AT+CFUN=1')) {
          simRows.firstWhere((s) => s.id == id).cfun = 1;
        } else if (a.cmd == 'AT+CFUN=0') {
          simRows.firstWhere((s) => s.id == id).cfun = 0;
        }
      }
      _log.insert(0, '[${ids.length}] ${a.cmd} → ${ids.join(", ")}');
      _openGroup = null;
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420,
        backgroundColor: T.ink,
        content: Text('${a.label} · ${ids.length} симк(и)',
            style: const TextStyle(fontSize: 13)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final title = navItems.firstWhere((n) => n.key == _page).label;
    final group = _openGroup == null
        ? null
        : actionGroups.firstWhere((g) => g.title == _openGroup);

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            expanded: _navOpen,
            activeKey: _page,
            onToggle: () => setState(() => _navOpen = !_navOpen),
            onSelect: (k) => setState(() {
              _page = k;
              _openGroup = null;
            }),
          ),
          Expanded(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: T.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [T.cardShadow],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // toolbar + overlay sheet share one stacking context
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ActionsBar(
                                title: title,
                                total: simRows.length,
                                selected: _selected.length,
                                openGroup: _openGroup,
                                onToggleGroup: (t) => setState(
                                    () => _openGroup = _openGroup == t ? null : t),
                                onRun: _run,
                              ),
                              if (group != null)
                                Positioned(
                                  top: 57,
                                  left: 0,
                                  right: 0,
                                  child: ActionsSheet(group: group, onRun: _run),
                                ),
                            ],
                          ),
                          Expanded(
                            child: _page == 'sim'
                                ? SimTable(
                                    rows: simRows,
                                    selected: _selected,
                                    onToggleRow: (id) => setState(() =>
                                        _selected.contains(id)
                                            ? _selected.remove(id)
                                            : _selected.add(id)),
                                    onToggleAll: () => setState(() {
                                      if (_selected.length == simRows.length) {
                                        _selected.clear();
                                      } else {
                                        _selected
                                          ..clear()
                                          ..addAll(simRows.map((s) => s.id));
                                      }
                                    }),
                                  )
                                : Center(
                                    child: Text('$title — раздел прототипа',
                                        style: const TextStyle(
                                            fontSize: 15, color: T.fg2)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_log.isNotEmpty) _console(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: T.surface,
          border: Border(bottom: BorderSide(color: T.rulePanel)),
        ),
        child: Row(children: [
          const Text('SimBox Adminka',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: T.ink)),
          const SizedBox(width: 10),
          const Text('up 41 days, 6:12',
              style: TextStyle(fontSize: 12, color: T.fg2)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: T.gradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('online',
                style: TextStyle(
                    fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ]),
      );

  Widget _console() => Container(
        height: 118,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        decoration: BoxDecoration(
          color: T.surface,
          border: Border(top: BorderSide(color: T.rulePanel)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Вывод команд',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: T.fg2)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(_log.clear),
                child: const Text('очистить', style: TextStyle(fontSize: 12)),
              ),
            ]),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => Text(_log[i],
                    style: const TextStyle(
                        fontFamily: T.mono, fontSize: 11, color: T.fgBody)),
              ),
            ),
          ],
        ),
      );
}
