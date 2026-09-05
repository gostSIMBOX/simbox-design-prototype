import 'package:flutter/material.dart';
import '../data/icon_map.dart';
import '../data/models.dart';
import '../data/mock.dart';
import '../state/app_state.dart';
import '../widgets/action_group_bar.dart';
import '../widgets/dense_table.dart';
import '../widgets/panel.dart';
import 'sims_page.dart' show TableHeading, TableToolbar, columnDisplayLabel;

class DonglesPage extends StatefulWidget {
  const DonglesPage({super.key});
  @override
  State<DonglesPage> createState() => _DonglesPageState();
}

class _DonglesPageState extends State<DonglesPage> {
  final _search = TextEditingController();
  final _pin = TextEditingController();
  final _at = TextEditingController(text: 'AT+CFUN?');

  @override
  void dispose() {
    _search.dispose();
    _pin.dispose();
    _at.dispose();
    super.dispose();
  }

  List<ColDef<Dongle>> _cols(AppState st) => [
        ColDef(
            key: 'model',
            w: 38,
            title: 'модель',
            build: (d) => Cell(icons: [Ico.dongle(d.model)])),
        ColDef(
            key: 'cfun',
            w: 34,
            title: 'передатчик',
            icon: 'p-on.png',
            build: (d) => Cell(icons: [Ico.cfun(st.cfunOf(d.id, d.cfun))])),
        ColDef(
            key: 'name',
            w: 76,
            label: 'Свисток',
            build: (d) => Cell(mono: d.name)),
        ColDef(
            key: 'lock',
            w: 108,
            title: 'блокировка',
            icon: 'lock.png',
            build: (d) => Cell(sub: d.lock)),
        ColDef(
            key: 'state',
            w: 68,
            label: 'state',
            build: (d) => Cell(text: d.state)),
        ColDef(
            key: 'e0',
            w: 38,
            label: 'ERR0',
            build: (d) => Cell(text: '${d.e0}')),
        ColDef(
            key: 'e1',
            w: 38,
            label: 'ERR1',
            build: (d) => Cell(text: '${d.e1}')),
        ColDef(
            key: 'e2',
            w: 38,
            label: 'ERR2',
            build: (d) => Cell(text: '${d.e2}')),
        ColDef(key: 'm', w: 76, label: 'M', build: (d) => Cell(text: d.m)),
        ColDef(key: 'ch', w: 48, label: 'Ch', build: (d) => Cell(text: d.ch)),
        ColDef(
            key: 'rssi',
            w: 62,
            label: 'RSSI',
            build: (d) => Cell(icons: [Ico.rssi(d.rssi)], sub: d.dbm)),
        ColDef(
            key: 'snr',
            w: 38,
            label: 'SNR',
            build: (d) => Cell(text: '${d.snr}')),
        ColDef(
            key: 'oper',
            w: 96,
            label: 'Oper',
            build: (d) => Cell(text: d.oper, sub: d.operSub)),
        ColDef(
            key: 'cell',
            w: 62,
            label: 'CELL',
            sub: 'LAC',
            build: (d) => Cell(mono: d.cell, sub: d.lac)),
        ColDef(
            key: 'iccid',
            w: 96,
            label: 'ICCID',
            build: (d) => Cell(mono: d.iccid)),
        ColDef(
            key: 'serial',
            w: 84,
            label: 'Serial',
            build: (d) => Cell(mono: d.serial)),
        ColDef(
            key: 'imei',
            w: 124,
            label: 'IMEI',
            build: (d) => Cell(mono: d.imei)),
        ColDef(
            key: 'fw',
            w: 116,
            label: 'firmware',
            build: (d) => Cell(mono: d.fw)),
        ColDef(
            key: 'mdl', w: 64, label: 'model', build: (d) => Cell(mono: d.mdl)),
        ColDef(
            key: 'audio',
            w: 104,
            label: 'audio',
            build: (d) => Cell(mono: d.audio)),
        ColDef(
            key: 'data',
            w: 104,
            label: 'data',
            build: (d) => Cell(mono: d.data)),
        ColDef(
            key: 'dev', w: 54, label: 'dev', build: (d) => Cell(mono: d.dev)),
      ];

  List<ColDef<Dongle>> _visibleCols(AppState st, List<ColDef<Dongle>> all) {
    final defaults = [for (final c in all) c.key];
    final order = st.columnOrderFor(AdmPage.dongle, defaults);
    final hidden = st.hiddenColumnsFor(AdmPage.dongle);
    final byKey = {for (final c in all) c.key: c};
    return [
      for (final k in order)
        if (!hidden.contains(k) && byKey.containsKey(k)) byKey[k]!
    ];
  }

  List<ActionGroup> _groups(AppState st) => [
        ActionGroup(
          key: 'dact',
          label: 'Действия со свистками',
          icon: 'dongle.png',
          subActions: [
            SubAction(
              key: 'all',
              label: 'Действия со свистками',
              builder: (_) => Wrap(spacing: 8, runSpacing: 8, children: [
                for (final a in dongleActions)
                  AdmButton(a.label,
                      icon: a.icon,
                      tooltip: a.cmd,
                      onPressed: () => st.runOnDongles(
                          (d) => LogEntry('', '${a.cmd} ${d.name}', a.output),
                          toastText: a.label)),
              ]),
            ),
          ],
        ),
        ActionGroup(
          key: 'pin',
          label: 'PIN и разблокировка',
          icon: 'lock.png',
          subActions: [
            SubAction(
              key: 'pin',
              label: 'Снять PIN',
              builder: (_) => Row(mainAxisSize: MainAxisSize.min, children: [
                AdmField(_pin, hint: 'PIN', width: 100),
                const SizedBox(width: 8),
                AdmButton('Снять PIN', primary: true, onPressed: () {
                  final pin = _pin.text.isEmpty ? '0000' : _pin.text;
                  st.runOnDongles(
                      (d) => LogEntry(
                          '',
                          "asterisk -rx 'dongle cmd ${d.name} AT+CPIN=$pin'",
                          const ['OK', 'свисток перезапускается']),
                      toastText: 'PIN снят',
                      icon: 'lock.png');
                }),
                const SizedBox(width: 10),
                Text('свисток перезапускается — подождите около минуты',
                    style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 11,
                        color: Color(0xFF8A97A3))),
              ]),
            ),
            SubAction(
              key: 'cardlock',
              label: 'unlock CARDLOCK',
              builder: (_) => AdmButton('unlock CARDLOCK',
                  onPressed: () => st.runOnDongles(
                      (d) => LogEntry(
                          '',
                          '/usr/simbox/bin/unlock_cardlock ${d.name}',
                          const ['CARDLOCK unlocked']),
                      toastText: 'CARDLOCK')),
            ),
            SubAction(
              key: 'u2diag',
              label: 'U2DIAG',
              builder: (_) => AdmButton('U2DIAG',
                  onPressed: () => st.runOnDongles(
                      (d) => LogEntry(
                          '',
                          '/usr/simbox/bin/u2diag -d 0 ${d.name}',
                          const ['u2diag: 0']),
                      toastText: 'U2DIAG')),
            ),
          ],
        ),
        ActionGroup(
          key: 'modes',
          label: 'Режимы и AT-команда',
          icon: 'conn.png',
          subActions: [
            SubAction(
              key: 'gsm',
              label: 'set GSM',
              builder: (_) => AdmButton('set GSM',
                  primary: true,
                  onPressed: () => st.runOnDongles(
                      (d) => LogEntry(
                          '',
                          "asterisk -rx 'dongle cmd ${d.name} AT^SYSCFG=13,1,3FFFFFFF,2,4'",
                          const ['OK']),
                      toastText: 'GSM')),
            ),
            SubAction(
              key: 'wcdma',
              label: 'set WCDMA',
              builder: (_) => AdmButton('set WCDMA',
                  primary: true,
                  onPressed: () => st.runOnDongles(
                      (d) => LogEntry(
                          '',
                          "asterisk -rx 'dongle cmd ${d.name} AT^SYSCFG=14,2,3FFFFFFF,2,4'",
                          const ['OK']),
                      toastText: 'WCDMA')),
            ),
            SubAction(
              key: 'at',
              label: 'AT-команда',
              builder: (_) => Row(mainAxisSize: MainAxisSize.min, children: [
                AdmField(_at, mono: true, width: 160),
                const SizedBox(width: 8),
                AdmButton('Выполнить', primary: true, onPressed: () {
                  final cmd = _at.text.isEmpty ? 'AT+CFUN?' : _at.text;
                  st.runOnDongles(
                      (d) => LogEntry(
                          '',
                          "asterisk -rx 'dongle cmd ${d.name} $cmd'",
                          ['+CFUN: ${st.cfunOf(d.id, d.cfun)}', 'OK']),
                      toastText: 'AT-команда');
                }),
              ]),
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final rows = st.visibleDongles;
    final groups = _groups(st);
    final allCols = _cols(st);

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TableHeading(title: 'Свистки (normal mode)', count: rows.length),
        const SizedBox(height: 10),
        TableToolbar(
          groups: groups,
          search: _search,
          onSearch: st.setQuery,
          page: AdmPage.dongle,
          allColumns: [
            for (final c in allCols) (key: c.key, label: columnDisplayLabel(c))
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: DenseTable<Dongle>(
            cols: _visibleCols(st, allCols),
            rows: rows,
            idOf: (d) => d.id,
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
