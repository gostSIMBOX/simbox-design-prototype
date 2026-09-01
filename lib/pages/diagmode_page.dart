import 'package:flutter/material.dart';
import '../data/models.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import '../widgets/action_group_bar.dart';
import '../widgets/adm_icon.dart';
import '../widgets/dense_table.dart';
import '../widgets/panel.dart';
import 'sims_page.dart' show TableHeaderBar;

class DiagmodePage extends StatefulWidget {
  const DiagmodePage({super.key});
  @override
  State<DiagmodePage> createState() => _DiagmodePageState();
}

class _DiagmodePageState extends State<DiagmodePage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final rows = st.umDevices;

    final cols = <ColDef<UmDevice>>[
      ColDef(
          key: 'st',
          w: 36,
          title: 'статус',
          build: (d) => Cell(icons: const [IcoRef('diagmode/diagmode_log.png', 'лог прошивки')])),
      ColDef(key: 'device', w: 116, label: 'device', build: (d) => Cell(mono: d.device)),
      ColDef(key: 'model', w: 64, label: 'model', build: (d) => Cell(mono: d.model)),
      ColDef(key: 'port', w: 116, label: 'port', build: (d) => Cell(mono: d.port)),
      ColDef(
          key: 'state',
          w: 48,
          label: 'статус',
          build: (d) => Cell(icons: [
                IcoRef(
                    d.pct >= 100
                        ? 'diagmode/diagmode_done.png'
                        : 'diagmode/diagmode_update.png',
                    d.pct >= 100 ? 'готово' : 'прошивается')
              ])),
      ColDef(
          key: 'pct',
          w: 180,
          label: '%',
          build: (d) => Cell(text: '${d.pct}%', sub: d.pct >= 100 ? 'завершено' : 'идёт запись')),
    ];

    final groups = <ActionGroup>[
      ActionGroup(
        key: 'fw',
        label: 'Перепрошивка',
        icon: 'diagmode/diagmode_start.png',
        builder: (_) => Panel(
          title: 'Перепрошивка',
          icon: 'diagmode/diagmode_start.png',
          width: 340,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AdmCheck(
                value: st.liveRefresh,
                onChanged: st.setLiveRefresh,
                label: 'Автообновление (1 сек)'),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AdmIcon('stop.png'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Внимание!!! Запуск перепрошивки начнётся только после вынимания SIM-карты',
                  style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: T.danger),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            AdmButton('Отправить в diagmode',
                icon: 'diagmode/diagmode_init.png',
                expand: true,
                onPressed: () => st.push('/usr/simbox/actions/diagmode.sh /dev/ttyUSB4', const [],
                    'Внимание!!! Вынуть SIM-карту')),
          ]),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TableHeaderBar(
            title: 'Свистки (update mode)',
            count: rows.length,
            search: _search,
            onSearch: st.setQuery,
            groups: groups),
        const SizedBox(height: 12),
        Expanded(
          child: Stack(children: [
            DenseTable<UmDevice>(
              cols: cols,
              rows: rows,
              idOf: (d) => d.id,
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
