/// Domain + view models for the dense operations table.

class Sim {
  final int id;
  final int group;
  final int pause;
  final String cap, im, spec, io, qos, napr;
  final String plan, nabor, tarif;
  final String number, oper, sim;
  final double bal;
  final String balAge, op, balDiff;
  final bool balWarn;
  final String model;
  final int cfun, simst, srvst;
  final String dongle, dev;
  final int tot;
  final String totSub;
  final int ao, ai, mo, mi;
  final double acdo, acdi, acdl;
  final bool acdlBad;
  final int datt;
  final bool dattBad;
  final int iatt, satt;
  final double asrl;
  final String may, mon;
  final double pdd0, pdd1;
  final int pri;
  final String lac, cell, imei, imsi;
  final bool imeiWarn;
  final List<String> dates;

  // --- pro (sim.php col 3): raw, bare-labeled — mismatch mechanism is
  // confirmed by code, the value's own business meaning is not (see
  // 02-visual.md Open Q1).
  final String pro;
  final bool proWarn;

  // --- spec cluster (col 6): legacy stacks up to 5 icons in one cell —
  // vip/pre/pos/fas alongside the existing `spec` code icon.
  final int vip; // 0 (none) / 11 / 12 / >0 generic
  final bool pre, pos, fas;

  // --- state / live call (col 7): io/qos already exist above.
  final String liveState; // '' | 'dialing' | 'ring' | 'active' | 'cooldown'
  final int elapsedSec; // meaningful only when liveState is dialing/ring/active
  final int cooldownMax; // diff_min ceiling, meaningful only when liveState=='cooldown'
  final String emType; // raw, default '0' — shown as-is, never interpreted
  final String numberb; // busy-state B number; may carry raw '#SOU<15-digit-imsi>' suffix
  final String numbera; // busy-state A number; overridden when numberb carries the SOU suffix

  // --- MAY/MON/MSM + SMS quota (col 25): may/mon already exist above.
  final String msm;
  final int smsSent, smsSoft, smsHard;

  // --- PDDAS (col 27, mock value only — see 02-visual.md Open Q6)
  final double pddas;

  // --- LIMIT0..LIMIT5 (cols 31-36): six separate columns, replaces the
  // earlier lim0/lim1 fields (mirrors the existing `dates` List precedent).
  final List<String> limits; // length 6, each "value/max"
  final List<bool> limitPalevo; // length 6, parallel index

  // --- dongle hub-port sub-line (col 14, dongle0* rows only)
  final String dongleA;

  const Sim({
    required this.id,
    required this.group,
    this.pause = 0,
    required this.cap,
    required this.im,
    required this.spec,
    this.io = '',
    required this.qos,
    required this.napr,
    required this.plan,
    required this.nabor,
    this.tarif = '',
    required this.number,
    required this.oper,
    required this.sim,
    required this.bal,
    required this.balAge,
    this.op = '',
    this.balDiff = '',
    this.balWarn = false,
    required this.model,
    required this.cfun,
    required this.simst,
    required this.srvst,
    required this.dongle,
    required this.dev,
    required this.tot,
    required this.totSub,
    required this.ao,
    required this.ai,
    required this.mo,
    required this.mi,
    required this.acdo,
    required this.acdi,
    required this.acdl,
    this.acdlBad = false,
    required this.datt,
    this.dattBad = false,
    required this.iatt,
    required this.satt,
    required this.asrl,
    required this.may,
    required this.mon,
    required this.pdd0,
    required this.pdd1,
    required this.pri,
    required this.lac,
    required this.cell,
    required this.imei,
    this.imeiWarn = false,
    required this.imsi,
    required this.dates,
    this.pro = '',
    this.proWarn = false,
    this.vip = 0,
    this.pre = false,
    this.pos = false,
    this.fas = false,
    this.liveState = '',
    this.elapsedSec = 0,
    this.cooldownMax = 0,
    this.emType = '0',
    this.numberb = '',
    this.numbera = '',
    this.msm = '0/0',
    this.smsSent = 0,
    this.smsSoft = 0,
    this.smsHard = 0,
    this.pddas = 0,
    this.limits = const ['', '', '', '', '', ''],
    this.limitPalevo = const [false, false, false, false, false, false],
    this.dongleA = '',
  });

  Object? field(String k) => switch (k) {
        'group' => group,
        'plan' => plan,
        'number' => number,
        'oper' => oper,
        'bal' => bal,
        'dongle' => dongle,
        'tot' => tot,
        'ao' => ao,
        'mo' => mo,
        'acdo' => acdo,
        'acdi' => acdi,
        'acdl' => acdl,
        'datt' => datt,
        'iatt' => iatt,
        'satt' => satt,
        'asrl' => asrl,
        'pri' => pri,
        'imei' => imei,
        'imsi' => imsi,
        _ => null,
      };

  String get haystack =>
      '$group $plan $nabor $tarif $number $oper $sim $model $dongle $imei $imsi $napr $qos'
          .toLowerCase();
}

class Dongle {
  final int id;
  final String model;
  final int cfun;
  final String name, lock, state;
  final int e0, e1, e2;
  final String m, ch;
  final int rssi;
  final String dbm;
  final int snr;
  final String oper,
      operSub,
      cell,
      lac,
      iccid,
      serial,
      imei,
      fw,
      mdl,
      audio,
      data,
      dev;

  const Dongle({
    required this.id,
    required this.model,
    required this.cfun,
    required this.name,
    this.lock = '',
    required this.state,
    required this.e0,
    required this.e1,
    required this.e2,
    required this.m,
    required this.ch,
    required this.rssi,
    required this.dbm,
    required this.snr,
    required this.oper,
    required this.operSub,
    required this.cell,
    required this.lac,
    required this.iccid,
    required this.serial,
    required this.imei,
    required this.fw,
    required this.mdl,
    required this.audio,
    required this.data,
    required this.dev,
  });

  Object? field(String k) => switch (k) {
        'name' => name,
        'state' => state,
        'e0' => e0,
        'e1' => e1,
        'e2' => e2,
        'rssi' => rssi,
        'snr' => snr,
        'oper' => oper,
        'imei' => imei,
        _ => null,
      };

  String get haystack =>
      '$name $model $state $oper $imei $iccid $serial $dev'.toLowerCase();
}

class UmDevice {
  final int id;
  final String device, model, port;
  final int pct;
  const UmDevice(
      {required this.id,
      required this.device,
      required this.model,
      required this.port,
      required this.pct});
}

class HubNode {
  final int id;
  final List<IcoRef> icons;
  final String device, port;
  const HubNode(
      {required this.id,
      required this.icons,
      required this.device,
      required this.port});
}

/// A physical SIM-card-reader device (`readers.php`), distinct from `HubNode`'s USB-hub
/// topology. Card-keyed fields (iccid/imsi/ki/progress/stateFault) are blank when no card
/// is currently seated in the reader.
class Reader {
  final int id;
  final String model,
      device,
      lock,
      state,
      stateFault,
      spn,
      iccid,
      pin,
      imsi,
      ki,
      dataport;
  final int progressDone, progressTotal;

  const Reader({
    required this.id,
    required this.model,
    required this.device,
    required this.lock,
    required this.state,
    this.stateFault = '',
    required this.spn,
    required this.iccid,
    required this.pin,
    required this.imsi,
    required this.ki,
    this.progressDone = 0,
    this.progressTotal = 0,
    required this.dataport,
  });

  bool get hasCard => iccid.isNotEmpty;
  String get progressDisplay =>
      progressDone > 0 ? '$progressDone/$progressTotal' : '';

  /// Search haystack for the toolbar's filter box (mirrors Dongle.haystack/Sim.haystack).
  String get haystack =>
      '$device $state $spn $iccid $imsi $dataport'.toLowerCase();

  Object? field(String k) => switch (k) {
        'model' => model,
        'device' => device,
        'lock' => lock,
        'state' => state,
        'spn' => spn,
        'iccid' => iccid,
        'pin' => pin,
        'imsi' => imsi,
        'ki' => ki,
        'progress' => progressDone,
        'dataport' => dataport,
        _ => null,
      };
}

/// A 16px glyph reference: asset path (without the `assets/imgs/` prefix) + tooltip.
class IcoRef {
  final String path;
  final String title;
  const IcoRef(this.path, this.title);
}

/// Hover-log link, the Flutter counterpart of `showlog_cut.php`.
class LogLink {
  final String label, title;
  final List<String> lines;
  const LogLink(this.label, this.title, this.lines);
}

/// A stacked cell, ranked by ink: primary → secondary → tertiary → alarm.
class Cell {
  final String note, text, mono, warn, sub, sub2;
  final List<IcoRef> icons;
  final List<LogLink> links;

  /// When true, `text` renders in the brand-accent color instead of the plain
  /// cell color — this table's one "current value differs from a pending
  /// setting" cue (currently only the `pro` column). Kept as a bool rather than
  /// a `Color` field so this data-only file stays free of a Flutter import.
  final bool pending;

  const Cell({
    this.note = '',
    this.text = '',
    this.mono = '',
    this.warn = '',
    this.sub = '',
    this.sub2 = '',
    this.icons = const [],
    this.links = const [],
    this.pending = false,
  });
}

class ColDef<TRow> {
  final String key;
  final double w;
  final String label, sub;
  final String? icon, title;
  final Cell Function(TRow) build;
  const ColDef({
    required this.key,
    required this.w,
    this.label = '',
    this.sub = '',
    this.icon,
    this.title,
    required this.build,
  });
}

class LogEntry {
  final String time, cmd, warn;
  final List<String> lines;
  const LogEntry(this.time, this.cmd, this.lines, [this.warn = '']);
}

class BillRow {
  final String date, code, name, minutes, money;
  const BillRow(this.date, this.code, this.name, this.minutes, this.money);
}

class ActionDef {
  final String label, cmd, icon;
  final List<String> output;
  const ActionDef(this.label, this.cmd, this.icon, this.output);
}
