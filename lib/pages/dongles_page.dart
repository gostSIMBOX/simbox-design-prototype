import 'package:flutter/material.dart';
import '../data/icon_map.dart';
import '../data/models.dart';
import '../data/mock.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import '../widgets/dense_table.dart';
import '../widgets/panel.dart';
import 'sims_page.dart' show TableHeaderBar;

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
        ColDef(key: 'model', w: 38, title: 'модель', build: (d) => Cell(icons: [Ico.dongle(d.model)])),
        ColDef(
            key: 'cfun',
            w: 34,
            title: 'передатчик',
            icon: 'p-on.png',
            build: (d) => Cell(icons: [Ico.cfun(st.cfunOf(d.id, d.cfun))])),
        ColDef(key: 'name', w: 76, label: 'Свисток', build: (d) => Cell(mono: d.name)),
        ColDef(
            key: 'lock',
            w: 108,
            title: 'блокировка',
            icon: 'lock.png',
            build: (d) => Cell(sub: d.lock)),
        ColDef(key: 'state', w: 68, label: 'state', build: (d) => Cell(text: d.state)),
        ColDef(key: 'e0', w: 38, label: 'ERR0', build: (d) => Cell(text: '${d.e0}')),
        ColDef(key: 'e1', w: 38, label: 'ERR1', build: (d) => Cell(text: '${d.e1}')),
        ColDef(key: 'e2', w: 38, label: 'ERR2', build: (d) => Cell(text: '${d.e2}')),
        ColDef(key: 'm', w: 76, label: 'M', build: (d) => Cell(text: d.m)),
        ColDef(key: 'ch', w: 48, label: 'Ch', build: (d) => Cell(text: d.ch)),
        ColDef(
            key: 'rssi',
            w: 62,
            label: 'RSSI',
            build: (d) => Cell(icons: [Ico.rssi(d.rssi)], sub: d.dbm)),
        ColDef(key: 'snr', w: 38, label: 'SNR', build: (d) => Cell(text: '${d.snr}')),
        ColDef(key: 'oper', w: 96, label: 'Oper', build: (d) => Cell(text: d.oper, sub: d.operSub)),
        ColDef(
            key: 'cell',
            w: 62,
            label: 'CELL',
            sub: 'LAC',
            build: (d) => Cell(mono: d.cell, sub: d.lac)),
        ColDef(key: 'iccid', w: 96, label: 'ICCID', build: (d) => Cell(mono: d.iccid)),
        ColDef(key: 'serial', w: 84, label: 'Serial', build: (d) => Cell(mono: d.serial)),
        ColDef(key: 'imei', w: 124, label: 'IMEI', build: (d) => Cell(mono: d.imei)),
        ColDef(key: 'fw', w: 116, label: 'firmware', build: (d) => Cell(mono: d.fw)),
        ColDef(key: 'mdl', w: 64, label: 'model', build: (d) => Cell(mono: d.mdl)),
        ColDef(key: 'audio', w: 104, label: 'audio', build: (d) => Cell(mono: d.audio)),
        ColDef(key: 'data', w: 104, label: 'data', build: (d) => Cell(mono: d.data)),
        ColDef(key: 'dev', w: 54, label: 'dev', build: (d) => Cell(mono: d.dev)),
      ];

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final rows = st.visibleDongles;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TableHeaderBar(
          title: 'Свистки (normal mode)',
          count: rows.length,
          search: _search,
          onSearch: st.setQuery),
      const SizedBox(height: 12),
      DenseTable<Dongle>(
        cols: _cols(st),
        rows: rows,
        idOf: (d) => d.id,
        isSelected: st.isSelected,
        onToggleRow: st.toggleRow,
        onToggleAll: () => st.toggleAll(rows.map((e) => e.id).toList()),
        sortKey: st.sortKey,
        sortDir: st.sortDir,
        onSort: st.sortBy,
      ),
      const SizedBox(height: 18),
      Wrap(spacing: 18, runSpacing: 18, children: [
        Panel(
          title: 'Действия со свистками',
          icon: 'dongle.png',
          width: 320,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final a in dongleActions) ...[
              AdmButton(a.label,
                  icon: a.icon,
                  tooltip: a.cmd,
                  expand: true,
                  onPressed: () => st.runOnDongles(
                      (d) => LogEntry('', '${a.cmd} ${d.name}', a.output),
                      toastText: a.label)),
              const SizedBox(height: 8),
            ],
          ]),
        ),
        Panel(
          title: 'PIN и разблокировка',
          icon: 'lock.png',
          width: 340,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: AdmField(_pin, hint: 'PIN')),
              const SizedBox(width: 8),
              AdmButton('Снять PIN', onPressed: () {
                final pin = _pin.text.isEmpty ? '0000' : _pin.text;
                st.runOnDongles(
                    (d) => LogEntry('', "asterisk -rx 'dongle cmd ${d.name} AT+CPIN=$pin'",
                        const ['OK', 'свисток перезапускается']),
                    toastText: 'PIN снят',
                    icon: 'lock.png');
              }),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: AdmButton('unlock CARDLOCK',
                      onPressed: () => st.runOnDongles(
                          (d) => LogEntry('', '/usr/simbox/bin/unlock_cardlock ${d.name}',
                              const ['CARDLOCK unlocked']),
                          toastText: 'CARDLOCK'))),
              const SizedBox(width: 8),
              Expanded(
                  child: AdmButton('U2DIAG',
                      onPressed: () => st.runOnDongles(
                          (d) => LogEntry('', '/usr/simbox/bin/u2diag -d 0 ${d.name}',
                              const ['u2diag: 0']),
                          toastText: 'U2DIAG'))),
            ]),
            const SizedBox(height: 10),
            Text('При снятии свисток перезапускается — подождите около минуты.', style: T.caption),
          ]),
        ),
        Panel(
          title: 'Режимы и AT-команда',
          icon: 'conn.png',
          width: 380,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                  child: AdmButton('set GSM',
                      onPressed: () => st.runOnDongles(
                          (d) => LogEntry(
                              '',
                              "asterisk -rx 'dongle cmd ${d.name} AT^SYSCFG=13,1,3FFFFFFF,2,4'",
                              const ['OK']),
                          toastText: 'GSM'))),
              const SizedBox(width: 8),
              Expanded(
                  child: AdmButton('set WCDMA',
                      onPressed: () => st.runOnDongles(
                          (d) => LogEntry(
                              '',
                              "asterisk -rx 'dongle cmd ${d.name} AT^SYSCFG=14,2,3FFFFFFF,2,4'",
                              const ['OK']),
                          toastText: 'WCDMA'))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: AdmField(_at, mono: true)),
              const SizedBox(width: 8),
              AdmButton('Выполнить', onPressed: () {
                final cmd = _at.text.isEmpty ? 'AT+CFUN?' : _at.text;
                st.runOnDongles(
                    (d) => LogEntry('', "asterisk -rx 'dongle cmd ${d.name} $cmd'",
                        ['+CFUN: ${st.cfunOf(d.id, d.cfun)}', 'OK']),
                    toastText: 'AT-команда');
              }),
            ]),
          ]),
        ),
      ]),
    ]);
  }
}
