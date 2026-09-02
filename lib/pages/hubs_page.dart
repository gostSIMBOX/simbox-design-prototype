import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/mock.dart';
import '../state/app_state.dart';
import '../widgets/action_group_bar.dart';
import '../widgets/dense_table.dart';
import '../widgets/panel.dart';
import 'sims_page.dart' show TableHeading, TableToolbar, columnDisplayLabel;

class HubsPage extends StatefulWidget {
  const HubsPage({super.key});
  @override
  State<HubsPage> createState() => _HubsPageState();
}

class _HubsPageState extends State<HubsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final rows = hubTree;

    final cols = <ColDef<HubNode>>[
      ColDef(key: 'tree', w: 84, title: 'дерево устройств', build: (h) => Cell(icons: h.icons)),
      ColDef(key: 'device', w: 340, label: 'device', build: (h) => Cell(mono: h.device)),
      ColDef(key: 'port', w: 120, label: 'bus:dev:port', build: (h) => Cell(mono: h.port)),
    ];

    final defaultIds = [for (final c in cols) c.key];
    final order = st.columnOrderFor(AdmPage.hubs, defaultIds);
    final hidden = st.hiddenColumnsFor(AdmPage.hubs);
    final byKey = {for (final c in cols) c.key: c};
    final visibleCols = [
      for (final k in order) if (!hidden.contains(k) && byKey.containsKey(k)) byKey[k]!
    ];

    final groups = <ActionGroup>[
      ActionGroup(
        key: 'hubpwr',
        label: 'Питание порта',
        icon: 'usb/hub_16.png',
        subActions: [
          SubAction(
            key: 'all',
            label: 'Питание порта',
            builder: (_) => Wrap(spacing: 8, runSpacing: 8, children: [
              AdmButton('ВКЛ',
                  icon: 'p-on.png',
                  onPressed: () => st.push('/usr/simbox/bin/hub-ctrl -b 02 -d 3 -P 1 -p 1',
                      const ['port powered on'])),
              AdmButton('ВЫКЛ',
                  icon: 'p-off.png',
                  onPressed: () => st.push('/usr/simbox/bin/hub-ctrl -b 02 -d 3 -P 1 -p 0',
                      const ['port powered off'])),
              AdmButton('РЕСТАРТ',
                  icon: 'power.png',
                  onPressed: () => st.push(
                      '/usr/simbox/bin/hub-ctrl -b 02 -d 3 -P 1 -p 0 && sleep 2 && hub-ctrl -b 02 -d 3 -P 1 -p 1',
                      const ['power cycled'])),
            ]),
          ),
        ],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TableHeading(title: 'Хабы (Hubs)', count: rows.length),
        const SizedBox(height: 10),
        TableToolbar(
          groups: groups,
          search: _search,
          onSearch: st.setQuery,
          page: AdmPage.hubs,
          allColumns: [for (final c in cols) (key: c.key, label: columnDisplayLabel(c))],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: DenseTable<HubNode>(
            cols: visibleCols,
            rows: rows,
            idOf: (h) => h.id,
            isSelected: st.isSelected,
            onToggleRow: st.toggleRow,
            onToggleAll: () => st.toggleAll(rows.map((e) => e.id).toList()),
            sortKey: st.sortKey,
            sortDir: st.sortDir,
            onSort: st.sortBy,
          ),
        ),
      ]),
    );
  }
}
