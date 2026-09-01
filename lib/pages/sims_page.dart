import 'package:flutter/material.dart';
import '../data/icon_map.dart';
import '../data/models.dart';
import '../data/mock.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import '../widgets/action_group_bar.dart';
import '../widgets/dense_table.dart';
import '../widgets/panel.dart';

class SimsPage extends StatefulWidget {
  const SimsPage({super.key});
  @override
  State<SimsPage> createState() => _SimsPageState();
}

class _SimsPageState extends State<SimsPage> {
  final _search = TextEditingController();
  final _delay = TextEditingController(text: '0');
  final _rnd = TextEditingController(text: '0');
  final _ussd = TextEditingController(text: '*100#');
  final _smsTo = TextEditingController();
  final _smsTxt = TextEditingController();
  final _call = TextEditingController();
  final _group = TextEditingController();
  String _plan = naborNames.first;

  @override
  void dispose() {
    for (final c in [_search, _delay, _rnd, _ussd, _smsTo, _smsTxt, _call, _group]) {
      c.dispose();
    }
    super.dispose();
  }

  LogLink _log(Sim s, String kind) => LogLink(
        kind,
        '${kind == 'calls' ? 'Лог звонков' : 'Лог USSD и SMS'} ${s.dongle}',
        kind == 'calls'
            ? const [
                '29.07 11:40 out 89261112233 ANSWER 62s ACD 1.03',
                '29.07 11:12 in  9219981122 ANSWER 41s',
                '29.07 10:58 out 0611 NOANSWER 0s',
                '29.07 10:31 out 89031234567 BUSY 0s',
              ]
            : [
                '29.07 11:44 USSD *100# -> Баланс: ${s.bal.toStringAsFixed(2)} р.',
                '29.07 09:02 SMS from 000100 "Пополнение 100 р."',
                '28.07 21:15 USSD *105*00# -> Тариф МС',
                '28.07 12:03 SMS to 9219981122 "test"',
              ],
      );

  List<ColDef<Sim>> _cols(AppState st) => [
        ColDef(
            key: 'group',
            w: 62,
            label: 'group',
            title: 'группа и расписание',
            build: (s) => Cell(
                icons: Ico.group(s.group, st.pauseOf(s.id, s.pause)), sub: '${s.group}')),
        ColDef(
            key: 'cap',
            w: 30,
            title: 'капча',
            icon: 'qos/capok.png',
            build: (s) => Cell(icons: [Ico.captcha(s.cap)])),
        ColDef(
            key: 'im',
            w: 30,
            title: 'мульти-сим',
            icon: 'im/imb.png',
            build: (s) => Cell(icons: [if (Ico.im(s.im) != null) Ico.im(s.im)!])),
        ColDef(
            key: 'spec',
            w: 30,
            title: 'спец-режим',
            icon: 'spec/pre.png',
            build: (s) => Cell(icons: [if (Ico.spec(s.spec) != null) Ico.spec(s.spec)!])),
        ColDef(
            key: 'io',
            w: 54,
            label: 'state',
            title: 'направление и качество',
            build: (s) => Cell(icons: [
                  if (Ico.io(s.io) != null) Ico.io(s.io)!,
                  if (Ico.qos(s.qos, s.io) != null) Ico.qos(s.qos, s.io)!,
                ])),
        ColDef(
            key: 'napr',
            w: 38,
            label: 'напр',
            title: 'направление',
            build: (s) => Cell(icons: [Ico.napr(s.napr)])),
        ColDef(
            key: 'plan',
            w: 118,
            label: 'план',
            sub: 'набор / тариф',
            build: (s) =>
                Cell(text: s.plan, sub: s.nabor + (s.tarif.isEmpty ? '' : ' / ${s.tarif}'))),
        ColDef(key: 'number', w: 96, label: 'number', build: (s) => Cell(mono: s.number)),
        ColDef(
            key: 'oper',
            w: 92,
            label: 'operator',
            sub: 'sim',
            build: (s) => Cell(text: s.oper, sub: s.sim)),
        ColDef(
            key: 'bal',
            w: 118,
            label: 'balance',
            sub: 'bal_diff',
            build: (s) => Cell(
                  note: s.balAge,
                  text: s.balWarn ? '' : s.bal.toStringAsFixed(2),
                  warn: s.balWarn ? s.bal.toStringAsFixed(2) : '',
                  sub: s.op,
                  sub2: s.balDiff,
                )),
        ColDef(
            key: 'model',
            w: 48,
            label: 'dongle',
            title: 'модель и передатчик',
            build: (s) => Cell(icons: [Ico.dongle(s.model), Ico.cfun(st.cfunOf(s.id, s.cfun))])),
        ColDef(
            key: 'simst',
            w: 44,
            label: 'st',
            title: 'simst / srvst',
            build: (s) => Cell(icons: [Ico.simst(s.simst), Ico.srvst(s.srvst)])),
        ColDef(key: 'dongle', w: 68, label: 'dev', build: (s) => Cell(mono: s.dongle)),
        ColDef(
            key: 'tot',
            w: 92,
            label: 'tot',
            sub: 'IMB/C · IMN/D/E',
            build: (s) => Cell(text: '${s.tot}', sub2: s.totSub)),
        ColDef(
            key: 'ao',
            w: 44,
            label: 'a-o',
            sub: 'a-i',
            build: (s) => Cell(text: '${s.ao}', sub: '${s.ai}')),
        ColDef(
            key: 'mo',
            w: 44,
            label: 'm-o',
            sub: 'm-i',
            build: (s) => Cell(text: '${s.mo}', sub: '${s.mi}')),
        ColDef(key: 'acdo', w: 46, label: 'ACD-o', build: (s) => Cell(text: s.acdo.toStringAsFixed(2))),
        ColDef(key: 'acdi', w: 46, label: 'ACD-i', build: (s) => Cell(text: s.acdi.toStringAsFixed(2))),
        ColDef(
            key: 'acdl',
            w: 52,
            label: 'ACDL',
            build: (s) => s.acdlBad
                ? Cell(icons: const [IcoRef('low_acdl.png', 'низкий ACDL')], warn: '${s.acdl}')
                : Cell(text: '${s.acdl}')),
        ColDef(
            key: 'datt',
            w: 48,
            label: 'DATT',
            build: (s) => s.dattBad
                ? Cell(icons: const [IcoRef('high_datt.png', 'высокий DATT')], warn: '${s.datt}')
                : Cell(text: '${s.datt}')),
        ColDef(
            key: 'iatt',
            w: 44,
            label: 'IATT',
            build: (s) => Cell(
                icons: s.iatt > 3 ? const [IcoRef('need_in.png', 'нужен входящий')] : const [],
                text: '${s.iatt}')),
        ColDef(
            key: 'satt',
            w: 40,
            label: 'SATT',
            build: (s) =>
                Cell(icons: s.satt > 0 ? const [IcoRef('satt.png', 'нужен SMS')] : const [])),
        ColDef(
            key: 'may',
            w: 72,
            label: 'MAY',
            sub: 'MON',
            icon: 'may.png',
            build: (s) => Cell(text: 'MAY ${s.may}', sub: 'MON ${s.mon}')),
        ColDef(key: 'asrl', w: 46, label: 'ASRL', build: (s) => Cell(text: s.asrl.toStringAsFixed(2))),
        ColDef(key: 'pdd0', w: 46, label: 'PDDL0', build: (s) => Cell(text: '${s.pdd0}')),
        ColDef(key: 'pdd1', w: 46, label: 'PDDL1', build: (s) => Cell(text: '${s.pdd1}')),
        ColDef(key: 'pri', w: 34, label: 'pri', build: (s) => Cell(text: '${s.pri}')),
        ColDef(
            key: 'lim0',
            w: 80,
            label: 'LIMIT0',
            sub: 'LIMIT1',
            build: (s) => Cell(text: s.lim0, sub: s.lim1)),
        ColDef(
            key: 'lac',
            w: 62,
            label: 'LAC',
            sub: 'CELL',
            build: (s) => Cell(mono: s.lac, sub: s.cell)),
        ColDef(
            key: 'imei',
            w: 128,
            label: 'IMEI',
            build: (s) => s.imeiWarn ? Cell(warn: s.imei) : Cell(mono: s.imei)),
        ColDef(key: 'imsi', w: 132, label: 'IMSI', build: (s) => Cell(mono: s.imsi)),
        ColDef(
            key: 'log',
            w: 78,
            label: 'log',
            build: (s) => Cell(links: [_log(s, 'ussd&sms'), _log(s, 'calls')])),
        ColDef(
            key: 'dates',
            w: 96,
            label: 'засунут',
            sub: '1й / посл. / автоблок',
            build: (s) =>
                Cell(note: s.dates[0], text: s.dates[1], sub: s.dates[2], sub2: s.dates[3])),
      ];

  List<ActionGroup> _groups(AppState st) => [
        ActionGroup(
            key: 'power',
            label: 'Передатчик и статус',
            icon: 'state/state_dial.png',
            builder: (_) => _transmitter(st)),
        ActionGroup(
            key: 'simple',
            label: 'Действия простые',
            icon: 'ussdsms.png',
            builder: (_) => _simpleActions(st)),
        ActionGroup(
            key: 'smart',
            label: 'Действия хитрые',
            icon: 'free.png',
            builder: (_) => _smartActions(st)),
        ActionGroup(
            key: 'plans',
            label: 'Группы и планы',
            icon: 'spec/nav.png',
            builder: (_) => _groupsAndPlans(st)),
        ActionGroup(
            key: 'export',
            label: 'Экспорт / Импорт',
            icon: 'sms_out.png',
            builder: (_) => _exports(st)),
      ];

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final rows = st.visibleSims;
    final groups = _groups(st);

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TableHeaderBar(
          title: 'Симки',
          count: rows.length,
          search: _search,
          onSearch: st.setQuery,
          groups: groups,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Stack(children: [
            DenseTable<Sim>(
              cols: _cols(st),
              rows: rows,
              idOf: (s) => s.id,
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

  Widget _transmitter(AppState st) => Panel(
        title: 'Передатчик и статус',
        icon: 'state/state_dial.png',
        width: 340,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: AdmButton('ВКЛ', icon: 'p-on.png', onPressed: () {
              st.setPower(1);
              st.runOnSelection(
                  (r) => LogEntry('', '/usr/simbox/actions/connect.sh ${r.dongle} on',
                      const ['AT+CFUN=1', 'OK']),
                  toastText: 'Передатчик включён',
                  icon: 'p-on.png');
            })),
            const SizedBox(width: 10),
            Expanded(
                child: AdmButton('ВЫКЛ', icon: 'p-off.png', onPressed: () {
              st.setPower(5);
              st.runOnSelection(
                  (r) => LogEntry('', '/usr/simbox/actions/connect.sh ${r.dongle} off',
                      const ['AT+CFUN=5', 'OK']),
                  toastText: 'Передатчик выключен',
                  icon: 'p-off.png');
            })),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: AdmButton('Пауза', icon: 'pause2.png', onPressed: () {
              st.setPause(1);
              st.runOnSelection(
                  (r) => LogEntry(
                      '', 'echo 1 > /var/simbox/sim/settings/${r.imsi}.pause', const ['pause=1']),
                  toastText: 'Поставлено на паузу',
                  icon: 'pause2.png');
            })),
            const SizedBox(width: 10),
            Expanded(
                child: AdmButton('В работу', icon: 'play.png', onPressed: () {
              st.setPause(0);
              st.runOnSelection(
                  (r) => LogEntry('', '/usr/simbox/actions/activate_work.sh ${r.dongle}',
                      const ['group -> 101', 'OK']),
                  toastText: 'Отправлено в работу',
                  icon: 'play.png');
            })),
          ]),
          const SizedBox(height: 10),
          AdmCheck(
              value: st.queueMode,
              onChanged: st.setQueueMode,
              label: 'Вместо запуска — в очередь'),
          const SizedBox(height: 8),
          Row(children: [
            Text('Задержка', style: T.caption),
            const SizedBox(width: 8),
            AdmField(_delay, width: 52),
            const SizedBox(width: 8),
            Flexible(child: Text('+ случайная до', style: T.caption)),
            const SizedBox(width: 8),
            AdmField(_rnd, width: 52),
            const SizedBox(width: 6),
            Text('сек', style: T.caption),
          ]),
        ]),
      );

  Widget _simpleActions(AppState st) => Panel(
        title: 'Действия простые',
        icon: 'ussdsms.png',
        width: 430,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            SizedBox(width: 54, child: Text('USSD', style: T.body)),
            Expanded(child: AdmField(_ussd)),
            const SizedBox(width: 8),
            AdmButton('Отправить', onPressed: () {
              final v = _ussd.text.isEmpty ? '*100#' : _ussd.text;
              st.runOnSelection(
                  (r) => LogEntry('', "asterisk -rx 'dongle ussd ${r.dongle} $v'", [
                        '+CUSD: 0,"Баланс: ${r.bal.toStringAsFixed(2)} р.",15',
                        'OK'
                      ]),
                  toastText: 'USSD отправлен',
                  icon: 'ussdsms.png');
            }),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            SizedBox(width: 54, child: Text('SMS', style: T.body)),
            AdmField(_smsTo, hint: 'номер', width: 104),
            const SizedBox(width: 8),
            Expanded(child: AdmField(_smsTxt, hint: 'сообщение')),
            const SizedBox(width: 8),
            AdmButton('SMS', onPressed: () {
              final to = _smsTo.text.isEmpty ? '9219981122' : _smsTo.text;
              final tx = _smsTxt.text.isEmpty ? 'test' : _smsTxt.text;
              st.runOnSelection(
                  (r) => LogEntry('', "asterisk -rx 'dongle sms ${r.dongle} $to $tx'",
                      const ['+CMGS: 42', 'OK']),
                  toastText: 'SMS отправлена',
                  icon: 'sms_out.png');
            }),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            SizedBox(width: 54, child: Text('Звонок', style: T.body)),
            Expanded(child: AdmField(_call, hint: '89261112233')),
            const SizedBox(width: 8),
            AdmButton('Call60', onPressed: () {
              final n = _call.text.isEmpty ? '89261112233' : _call.text;
              st.runOnSelection(
                  (r) => LogEntry(
                      '',
                      "asterisk -rx 'channel originate Dongle/${r.dongle}/$n application Wait 60'",
                      const ['DialStatus: ANSWER', 'duration 60s']),
                  toastText: 'Звонок с тишиной',
                  icon: 'state/state_dial.png');
            }),
            const SizedBox(width: 8),
            AdmButton('CallSpeak', onPressed: () {
              final n = _call.text.isEmpty ? '89261112233' : _call.text;
              st.runOnSelection(
                  (r) => LogEntry(
                      '',
                      "asterisk -rx 'channel originate Dongle/${r.dongle}/$n extension speak@simbox'",
                      const ['DialStatus: ANSWER', 'recog: 50 (голос)']),
                  toastText: 'Звонок с разговором',
                  icon: 'spec/in_sound.png');
            }),
          ]),
          const SizedBox(height: 10),
          Text('Формат как на телефоне: 0611 или 89261112233. w — пауза 0.5 сек.',
              style: T.caption),
        ]),
      );

  Widget _smartActions(AppState st) => Panel(
        title: 'Действия хитрые',
        icon: 'free.png',
        width: 320,
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in smartActions)
            SizedBox(
              width: 136,
              child: AdmButton(a.label,
                  icon: a.icon,
                  tooltip: '/usr/simbox/actions/${a.cmd}',
                  expand: true,
                  onPressed: () => st.runOnSelection(
                      (r) => LogEntry(
                          '', '/usr/simbox/actions/${a.cmd} ${r.dongle} ${r.imsi}', a.output),
                      toastText: '${a.label}: отправлено')),
            ),
        ]),
      );

  Widget _groupsAndPlans(AppState st) => Panel(
        title: 'Группы и планы',
        icon: 'spec/nav.png',
        width: 360,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Text('Группа', style: T.body),
            const SizedBox(width: 8),
            AdmField(_group, hint: '101', width: 80),
            const SizedBox(width: 8),
            AdmButton('Set group', onPressed: () {
              final g = _group.text.isEmpty ? '101' : _group.text;
              st.runOnSelection(
                  (r) => LogEntry(
                      '', 'echo $g > /var/simbox/sim/settings/${r.imsi}.group', ['group -> $g']),
                  toastText: 'Группа $g');
            }),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text('План', style: T.body),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _plan,
                isDense: true,
                style: T.body,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(T.radiusCtl),
                    borderSide: const BorderSide(color: T.border),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(T.radiusCtl),
                    borderSide: const BorderSide(color: T.border),
                  ),
                ),
                items: [
                  for (final p in naborNames) DropdownMenuItem(value: p, child: Text(p)),
                ],
                onChanged: (v) => setState(() => _plan = v ?? _plan),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: AdmButton('без копирования',
                    onPressed: () => st.runOnSelection(
                        (r) => LogEntry('', '/usr/simbox/actions/set_plan_set.sh ${r.imsi} $_plan',
                            ['plan -> $_plan']),
                        toastText: 'План установлен'))),
            const SizedBox(width: 8),
            Expanded(
                child: AdmButton('с копированием',
                    onPressed: () => st.runOnSelection(
                        (r) => LogEntry('', '/usr/simbox/actions/set_plan_copy.sh ${r.imsi} $_plan',
                            ['plan -> $_plan', 'параметры скопированы']),
                        toastText: 'План + параметры'))),
          ]),
          const SizedBox(height: 10),
          AdmButton('Восстановить параметры плана',
              expand: true,
              onPressed: () => st.runOnSelection(
                  (r) => LogEntry('', '/usr/simbox/actions/set_plan.sh ${r.imsi}',
                      const ['параметры плана восстановлены']),
                  toastText: 'Параметры восстановлены')),
          const SizedBox(height: 8),
          AdmButton('Снять флажки автоблокировки',
              icon: 'high_datt.png',
              expand: true,
              onPressed: () => st.runOnSelection(
                  (r) => LogEntry('', '/usr/simbox/actions/set_autoblock_null.sh ${r.imsi}',
                      const ['DATT=0', 'ACDL flag cleared']),
                  toastText: 'Флажки сняты',
                  icon: 'high_datt.png')),
        ]),
      );

  Widget _exports(AppState st) => Panel(
        title: 'Экспорт / Импорт',
        icon: 'sms_out.png',
        width: 300,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AdmButton('Export dongles',
              expand: true,
              onPressed: () => st.push('/usr/simbox/www/simbox/export.php?what=dongles',
                  [for (final s in sims) '${s.dongle};${s.imsi}'])),
          const SizedBox(height: 8),
          AdmButton('Export numbers',
              expand: true,
              onPressed: () => st.push('/usr/simbox/www/simbox/numbers.php',
                  [for (final s in sims) s.number])),
          const SizedBox(height: 8),
          AdmButton('Export masspayment',
              expand: true,
              onPressed: () => st.push('/usr/simbox/www/simbox/export.php?what=masspayment',
                  const ['9219981122;10;3;WMR;1', '9037761234;2;10;WMR;2'],
                  'НЕ ОПРЕДЕЛЕН;0;0;WMR;3')),
        ]),
      );
}

/// Title + row count + selection chip + filter + refresh.
class TableHeaderBar extends StatelessWidget {
  final String title;
  final int count;
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final List<ActionGroup> groups;

  const TableHeaderBar({
    super.key,
    required this.title,
    required this.count,
    required this.search,
    required this.onSearch,
    this.groups = const [],
  });

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: T.screenTitle),
            const SizedBox(width: 14),
            Text('Всего: $count', style: T.caption),
          ]),
          if (groups.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final g in groups)
                  ActionGroupPill(
                    group: g,
                    open: st.activeGroup == g.key,
                    onTap: () => st.toggleGroup(g.key),
                  ),
              ],
            ),
          if (st.selected.isNotEmpty)
            InkWell(
              onTap: st.clearSelection,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: T.rowSel, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Выбрано: ${st.selected.length}',
                      style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: T.brandDeep)),
                  const SizedBox(width: 6),
                  const Icon(Icons.close, size: 13, color: T.fgMuted),
                ]),
              ),
            ),
        ]),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 250,
        child: TextField(
          controller: search,
          onChanged: onSearch,
          style: const TextStyle(fontFamily: 'SF Pro Text', fontSize: 12),
          decoration: InputDecoration(
            hintText: 'фильтр: номер, план, dongle',
            hintStyle: T.caption,
            isDense: true,
            filled: true,
            fillColor: T.surface,
            prefixIcon: const Icon(Icons.search, size: 16, color: T.fgMuted),
            prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(T.radiusCtl),
              borderSide: const BorderSide(color: T.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(T.radiusCtl),
              borderSide: const BorderSide(color: T.brandDeep, width: 1.6),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      AdmButton('Обновить',
          primary: true,
          onPressed: () => st.showToast('Данные обновлены', 'conn.png')),
    ]);
  }
}
