import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/mock.dart';
import '../state/app_state.dart';
import '../widgets/action_group_bar.dart';
import '../widgets/dense_table.dart';
import '../widgets/panel.dart';
import 'sims_page.dart' show TableHeaderBar;

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

    final groups = <ActionGroup>[
      ActionGroup(
        key: 'hubpwr',
        label: 'Питание порта',
        icon: 'usb/hub_16.png',
        builder: (_) => Panel(
          title: 'Питание порта',
          icon: 'usb/hub_16.png',
          width: 300,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AdmButton('ВКЛ',
                icon: 'p-on.png',
                expand: true,
                onPressed: () => st.push('/usr/simbox/bin/hub-ctrl -b 02 -d 3 -P 1 -p 1',
                    const ['port powered on'])),
            const SizedBox(height: 8),
            AdmButton('ВЫКЛ',
                icon: 'p-off.png',
                expand: true,
                onPressed: () => st.push('/usr/simbox/bin/hub-ctrl -b 02 -d 3 -P 1 -p 0',
                    const ['port powered off'])),
            const SizedBox(height: 8),
            AdmButton('РЕСТАРТ',
                icon: 'power.png',
                expand: true,
                onPressed: () => st.push(
                    '/usr/simbox/bin/hub-ctrl -b 02 -d 3 -P 1 -p 0 && sleep 2 && hub-ctrl -b 02 -d 3 -P 1 -p 1',
                    const ['power cycled'])),
          ]),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TableHeaderBar(
            title: 'Ридеры (хабы)',
            count: rows.length,
            search: _search,
            onSearch: st.setQuery,
            groups: groups),
        const SizedBox(height: 12),
        Expanded(
          child: Stack(children: [
            DenseTable<HubNode>(
              cols: cols,
              rows: rows,
              idOf: (h) => h.id,
              isSelected: st.isSelected,
              onToggleRow: st.toggleRow,
              onToggleAll: () => st.toggleAll(rows.map((e) => e.id).toList()),
              sortKey: st.sortKey,
              sortDir: st.sortDir,
              onSort: st.sortBy,
            ),
            if (st.activeGroup != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ActionGroupOverlay(groups: groups, activeKey: st.activeGroup!),
              ),
          ]),
        ),
      ]),
    );
  }
}
