import 'theme.dart';

class NavItem {
  const NavItem(this.key, this.label, this.icon);
  final String key, label, icon;
}

const navItems = <NavItem>[
  NavItem('sim', 'Симки', 'free.png'),
  NavItem('dongle', 'Свистки (nm)', 'dongle1550.ico'),
  NavItem('diagmode', 'Свистки (um)', 'diagmode/diagmode_update.png'),
  NavItem('hubs', 'Хабы', 'usb/hub_16.ico'),
  NavItem('nabor', 'Наборы команд', 'ussdsms.png'),
  NavItem('plan', 'Планы', 'clock.png'),
  NavItem('proc', 'Процессы', 'conn.png'),
  NavItem('bablo', 'Биллинг', 'may.ico'),
  NavItem('upgrade', 'Обновление', 'power.png'),
  NavItem('debug', 'Debug', 'logussd.png'),
  NavItem('icons', 'Иконки', 'qos/ivip.png'),
];

class ActionDef {
  const ActionDef(this.label, this.cmd, this.icon);
  final String label, cmd, icon;
}

class ActionGroup {
  const ActionGroup(this.title, this.icon, this.items);
  final String title, icon;
  final List<ActionDef> items;
}

const actionGroups = <ActionGroup>[
  ActionGroup('Питание', 'power.png', [
    ActionDef('Включить', 'AT+CFUN=1', 'p-on.png'),
    ActionDef('Выключить', 'AT+CFUN=0', 'p-off.png'),
    ActionDef('Перезапуск', 'AT+CFUN=1,1', 'wake.png'),
    ActionDef('Сон', 'AT+CFUN=4', 'sleep.png'),
  ]),
  ActionGroup('Трафик', 'state_out.png', [
    ActionDef('Разрешить исх.', 'set out=1', 'state_out.png'),
    ActionDef('Запретить исх.', 'set out=0', 'stop.png'),
    ActionDef('Разрешить вх.', 'set in=1', 'state_in.png'),
    ActionDef('Пауза', 'set pause=1', 'pause2.png'),
  ]),
  ActionGroup('Баланс и SMS', 'may.ico', [
    ActionDef('Запросить баланс', 'AT+CUSD=1,"*100#"', 'may.ico'),
    ActionDef('Отправить SMS', 'AT+CMGS', 'sms_out.png'),
    ActionDef('Прочитать SMS', 'AT+CMGL', 'sms_in.png'),
    ActionDef('USSD-набор', 'ussd run', 'ussdsms.png'),
  ]),
  ActionGroup('План', 'clock.png', [
    ActionDef('Восстановить параметры плана', 'plan restore', 'clock.png'),
    ActionDef('Сбросить счётчики', 'counters reset', 'rand.ico'),
    ActionDef('Обновить прошивку', 'fw upgrade', 'power.png'),
  ]),
];

class ColDef {
  const ColDef(this.key, this.width, this.label,
      {this.sub = '', this.icon = '', this.tooltip = ''});
  final String key, label, sub, icon, tooltip;
  final double width;
}

const simColumns = <ColDef>[
  ColDef('group', 62, 'group'),
  ColDef('cap', 30, '', icon: 'qos/capok.png', tooltip: 'капча'),
  ColDef('im', 30, '', icon: 'im/imb.png', tooltip: 'мульти-сим'),
  ColDef('spec', 30, '', icon: 'spec/pre.png', tooltip: 'спец-режим'),
  ColDef('io', 54, 'state'),
  ColDef('napr', 38, 'напр'),
  ColDef('plan', 118, 'план', sub: 'набор / тариф'),
  ColDef('number', 96, 'number'),
  ColDef('oper', 92, 'operator', sub: 'sim'),
  ColDef('bal', 118, 'balance', sub: 'bal_diff'),
  ColDef('model', 48, 'dongle'),
  ColDef('simst', 44, 'st', tooltip: 'simst / srvst'),
  ColDef('dongle', 68, 'dev'),
  ColDef('tot', 92, 'tot', sub: 'IMB/C · IMN/D/E'),
  ColDef('ao', 44, 'a-o', sub: 'a-i'),
  ColDef('mo', 44, 'm-o', sub: 'm-i'),
  ColDef('acdo', 46, 'ACD-o'),
  ColDef('datt', 46, 'DATT'),
];

class Sim {
  Sim({
    required this.id,
    required this.group,
    required this.cap,
    required this.im,
    required this.spec,
    required this.io,
    required this.qos,
    required this.napr,
    required this.plan,
    required this.nabor,
    required this.tarif,
    required this.number,
    required this.oper,
    required this.sim,
    required this.bal,
    required this.balDiff,
    required this.balAge,
    required this.balWarn,
    required this.model,
    required this.cfun,
    required this.simst,
    required this.srvst,
    required this.dongle,
    required this.tot,
    required this.totSub,
    required this.ao,
    required this.ai,
    required this.mo,
    required this.mi,
    required this.acdo,
    required this.datt,
  });

  final int id, group, ao, ai, mo, mi, tot;
  final String cap, im, spec, io, qos, napr, plan, nabor, tarif, number, oper,
      sim, balDiff, balAge, model, simst, srvst, dongle, totSub;
  final double bal, acdo, datt;
  final bool balWarn;
  int cfun;
}

final List<Sim> simRows = List.generate(24, (i) {
  final groups = [0, 0, 333, 334, 335, 336, 400, 500];
  final g = groups[i % groups.length];
  final opers = ['Beeline', 'MegaFon', 'MTS', 'Tele2'];
  final naprs = [
    'napravleine/beeline_spb.ico',
    'napravleine/megafon_spb.ico',
    'napravleine/mts_spb.ico',
    'napravleine/tele2_spb.ico'
  ];
  final bal = 320.0 - i * 11.7;
  return Sim(
    id: 100 + i,
    group: g,
    cap: i % 5 == 0 ? 'bad' : 'ok',
    im: ['A', 'B', 'C', 'D', 'N'][i % 5],
    spec: i % 4 == 0 ? 'pre' : (i % 7 == 0 ? 'nav' : ''),
    io: i % 3 == 0 ? 'out' : (i % 3 == 1 ? 'in' : 'wait'),
    qos: ['igoo', 'inor', 'ibad', 'ivip'][i % 4],
    napr: naprs[i % 4],
    plan: 'plan_${(i % 6) + 1}',
    nabor: ['default', 'beeline_spb', 'mts_spb', 'tele2_spb'][i % 4],
    tarif: i % 2 == 0 ? 'unlim' : 'min300',
    number: '+7911${(2000000 + i * 1371).toString().padLeft(7, '0')}',
    oper: opers[i % 4],
    sim: '8970${1000000 + i * 7717}',
    bal: bal,
    balDiff: (bal < 60 ? '-' : '+') + (i % 9 + 1).toString() + '.40',
    balAge: '${(i % 50) + 2} мин',
    balWarn: bal < 60,
    model: i % 3 == 0 ? 'E1550' : 'E173',
    cfun: i % 6 == 5 ? 0 : 1,
    simst: i % 8 == 3 ? 'blocked' : 'ready',
    srvst: i % 5 == 2 ? 'searching' : 'registered',
    dongle: '/dev/ttyUSB${i * 2}',
    tot: 120 + i * 7,
    totSub: '${i % 9}/${i % 4} · ${i % 6}/${i % 3}/${i % 2}',
    ao: 40 + i,
    ai: 12 + (i % 7),
    mo: 8 + (i % 5),
    mi: 3 + (i % 4),
    acdo: 60 + (i % 40) * 1.5,
    datt: 5 + (i % 30) * 1.1,
  );
});

String qosIcon(String q) => 'qos/$q.png';
String ioIcon(String io) => 'state_$io.png';
String capIcon(String c) => c == 'ok' ? 'qos/capok.png' : 'qos/capbad.png';
String imIcon(String im) => {
      'A': 'im/ima.png',
      'B': 'im/imb.png',
      'C': 'im/imc.ico',
      'D': 'im/imd.ico',
      'N': 'im/imn.ico',
    }[im]!;
String? specIcon(String s) =>
    s.isEmpty ? null : (s == 'pre' ? 'spec/pre.png' : 'spec/nav.png');
String dongleIcon(String m) => m == 'E1550' ? 'dongle1550.ico' : 'dongle173.ico';
String cfunIcon(int c) => c == 1 ? 'p-on.png' : 'p-off.png';
String? groupIcon(int g) {
  if (g == 333) return 'high_datt.png';
  if (g == 334) return 'low_acdl.png';
  if (g == 335) return 'blocked_balance.ico';
  if (g == 336) return 'simblocked.ico';
  if (g >= 500) return 'blocked.png';
  if (g >= 400) return 'low_balance.png';
  return null;
}
