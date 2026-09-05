import 'models.dart';
import 'terminology.dart';

/// Folder = semantic axis, filename = raw protocol value.
/// Every mapping keeps the raw code in the tooltip.
class Ico {
  static IcoRef _termRef(String file, String termId, String raw) {
    final term = termById(termId);
    return IcoRef(
        file, '$raw — ${resolveLocalized(term.tooltip, locale: 'ru')}');
  }

  static const _naprMap = <String, List<String>>{
    'NS': ['megafon_spb', 'МегаФон СПб'],
    'NM': ['megafon_msk', 'МегаФон Мск'],
    'NZ': ['megafon_sz', 'МегаФон СЗ'],
    'NR': ['megafon_ru', 'МегаФон РФ'],
    'NU': ['megafon_ural', 'МегаФон Урал'],
    'NC': ['megafon_chel', 'МегаФон Челябинск'],
    'BS': ['beeline_spb', 'Билайн СПб'],
    'BM': ['beeline_msk', 'Билайн Мск'],
    'BR': ['beeline_ru', 'Билайн РФ'],
    'SS': ['mts_spb', 'МТС СПб'],
    'SM': ['mts_msk', 'МТС Мск'],
    'SR': ['mts_ru', 'МТС РФ'],
    'SB': ['mts_by', 'МТС BY'],
    'SU': ['mts_u', 'МТС UA'],
    'TS': ['tele2_spb', 'Tele2 СПб'],
    'TR': ['tele2_ru', 'Tele2 РФ'],
    'PS': ['proper_spb', 'Proper СПб'],
    'PM': ['proper_msk', 'Proper Мск'],
    'PB': ['proper_minsk', 'Proper Минск'],
    'LB': ['life_by', 'life:) BY'],
    'VB': ['velcom_by', 'Velcom BY'],
    'KU': ['kievstar', 'Kyivstar UA'],
    'EF': ['elisa', 'Elisa FI'],
    'DF': ['dna', 'DNA FI'],
    'SF': ['sonera', 'Sonera FI'],
    'HZ': ['hz', 'не определено'],
  };

  static IcoRef napr(String code) {
    final m = _naprMap[code] ?? _naprMap['HZ']!;
    return IcoRef('napravleine/${m[0]}.png', '$code — ${m[1]}');
  }

  /// Group code drives the row icon; the number stays visible next to it.
  static List<IcoRef> group(int group, int pause) {
    if (group >= 100 && group <= 299) {
      if (pause == 1) {
        return const [
          IcoRef('pause2.png', 'пауза'),
          IcoRef('day_work.png', 'рабочий день')
        ];
      }
      if (pause == 2) {
        return const [
          IcoRef('pause2.png', 'пауза'),
          IcoRef('day_holiday.png', 'выходной')
        ];
      }
      if (pause == 11) {
        return const [
          IcoRef('wake.png', 'просыпается'),
          IcoRef('day_work.png', 'рабочий день')
        ];
      }
      if (pause == 12) {
        return const [
          IcoRef('wake.png', 'просыпается'),
          IcoRef('day_holiday.png', 'выходной')
        ];
      }
      if (pause == 21) {
        return const [
          IcoRef('sleep.png', 'спит'),
          IcoRef('day_work.png', 'рабочий день')
        ];
      }
      if (pause == 22) {
        return const [
          IcoRef('sleep.png', 'спит'),
          IcoRef('day_holiday.png', 'выходной')
        ];
      }
      return const [IcoRef('play.png', 'в работе')];
    }
    if (group == 333) {
      return const [IcoRef('high_datt.png', 'автоблок: высокий DATT')];
    }
    if (group == 334) {
      return const [IcoRef('low_acdl.png', 'автоблок: низкий ACDL')];
    }
    if (group == 335) {
      return const [IcoRef('blocked_balance.png', 'блок по балансу')];
    }
    if (group == 336) {
      return const [IcoRef('simblocked.png', 'симка заблокирована')];
    }
    if (group >= 300 && group <= 399) {
      return const [IcoRef('stop.png', 'другая стоп/сервисная группа 3xx')];
    }
    if (group >= 400 && group <= 499) {
      return const [IcoRef('low_balance.png', 'низкий баланс')];
    }
    if (group >= 500) return const [IcoRef('blocked.png', 'заблокирована')];
    return const [];
  }

  static const _qosMap = <String, List<String>>{
    'VIP': ['qos/ivip.png', 'qos.vip'],
    'GOO': ['qos/igoo.png', 'qos.goo'],
    'NOR': ['qos/inor.png', 'qos.nor'],
    'BAD': ['qos/ibad.png', 'qos.bad'],
    'NEW': ['qos/inew.png', 'qos.new'],
    'NOS': ['qos/inos.png', 'qos.nos'],
    'ROB': ['qos/irob.png', 'qos.rob'],
    'BLO': ['qos/iblo.png', 'qos.blo'],
    'NE0': ['qos/ine0.png', 'qos.ne0'],
    'NEC': ['qos/inec.png', 'qos.nec'],
    'NEM': ['qos/inem.png', 'qos.nem'],
    'FAST': ['qos/fast.png', 'incoming.recency.fast'],
    'VERY': ['qos/very.png', 'incoming.recency.very'],
    'SLOW': ['qos/slow.png', 'incoming.recency.slow'],
    'NEVER': ['qos/never.png', 'incoming.recency.never'],
    'SPAM': ['spam.png', 'qos.spam'],
    'IMO': ['imode.png', 'qos.imo'],
    // Legacy has no distinct SYS icon — numeric 0 always renders inos.png
    // regardless of NOS/SYS (modules/html.php:334); reusing that exact asset
    // is the confirmed legacy behavior, not a placeholder.
    'SYS': ['qos/inos.png', 'qos.sys'],
  };

  static IcoRef? qos(String q, String io) {
    if (q == 'SOU') {
      final incoming = io == 'I';
      return _termRef(
        'state/state_sout_${incoming ? 'in' : 'out'}.png',
        incoming ? 'call.sou.in' : 'call.sou.out',
        'SOU',
      );
    }
    final m = _qosMap[q];
    return m == null ? null : _termRef(m[0], m[1], q);
  }

  static const _specMap = <String, List<String>>{
    'PRE': ['spec/pre.png', 'предоплата'],
    'POS': ['spec/pos.png', 'постоплата'],
    'MAY': ['spec/may.png', 'MAY'],
    'LOC': ['spec/local.png', 'локальный'],
    'LO2': ['spec/local2.png', 'локальный 2'],
    'FOR': ['spec/forwarding.png', 'форвардинг'],
    'WAI': ['spec/in_wait.png', 'ожидание входящего'],
    'SPE': ['spec/in_sound.png', 'разговор'],
    'CAROUSEL': ['spec/carousel.png', 'карусель'],
    'MAG': ['spec/mag.png', 'магазин'],
    'NAV': ['spec/nav.png', 'навигация'],
    'MON': ['spec/mon.png', 'MON · специальный режим'],
    'NOTVIP': ['spec/notvip.png', 'политика «не VIP»'],
  };

  static IcoRef? spec(String s) {
    final m = _specMap[s];
    return m == null ? null : IcoRef(m[0], '$s — ${m[1]}');
  }

  static IcoRef? fas(bool v) => v ? const IcoRef('fas.png', 'fas') : null;

  /// SIM-level VIP capability tier (`sim.php`'s `$vip`), distinct from the
  /// call-level `qos.vip` classification — confirmed different assets
  /// (`ivip.png` vs `qos/ivip.png`). Labeled by raw value only; the tier
  /// distinction's business meaning is undocumented (see 02-visual.md Open Q2).
  static IcoRef? vip(int v) => switch (v) {
        11 => const IcoRef('ivip1.png', 'vip=11'),
        12 => const IcoRef('ivip2.png', 'vip=12'),
        > 0 => const IcoRef('ivip.png', 'vip>0'),
        _ => null,
      };

  static IcoRef pre(bool v) => _termRef('spec/pre.png', 'special.pre', v ? 'PRE' : '');
  static IcoRef pos(bool v) => _termRef('spec/pos.png', 'special.pos', v ? 'POS' : '');

  static IcoRef liveCall(String state) => switch (state) {
        'dialing' => _termRef('state/state_dial.png', 'call.live.dial', 'DIAL'),
        'ring' => _termRef('state/state_ring.png', 'call.live.ring', 'RING'),
        'active' =>
          _termRef('state/state_active.png', 'call.live.active', 'ACTIVE'),
        'cooldown' => _termRef('state_wait.png', 'call.live.wait', 'WAIT'),
        _ => throw ArgumentError('unknown liveState: $state'),
      };

  static IcoRef? im(String v) {
    const m = {
      'A': 'ima',
      'B': 'imb',
      'C': 'imc',
      'D': 'imd',
      'E': 'ime',
      'N': 'imn'
    };
    final f = m[v];
    return f == null
        ? null
        : _termRef('im/$f.png', 'im.im${v.toLowerCase()}', 'IM$v');
  }

  static IcoRef? io(String v) => switch (v) {
        'O' => const IcoRef('state_out.png', 'исходящий'),
        'I' => const IcoRef('state_in.png', 'входящий'),
        'W' => const IcoRef('state_wait.png', 'ожидание'),
        _ => null,
      };

  static IcoRef cfun(int c) => switch (c) {
        1 => _termRef('p-on.png', 'modem.cfun.1', 'CFUN=1'),
        5 => _termRef('p-off.png', 'modem.cfun.5', 'CFUN=5'),
        4 => _termRef('state/cfun/4.png', 'modem.cfun.4', 'CFUN=4'),
        6 => _termRef('state/cfun/6.png', 'modem.cfun.6', 'CFUN=6'),
        _ => const IcoRef('state/-1.png', 'cfun неизвестен'),
      };

  static IcoRef simst(int v) => switch (v) {
        0 => _termRef('state/simst/0.png', 'sim.state.0', 'SIMST=0'),
        1 || 3 => _termRef('state/simst/1.png', 'sim.state.1', 'SIMST=$v'),
        4 => _termRef('state/simst/4.png', 'sim.state.4', 'SIMST=4'),
        16 => _termRef('state/simst/16.png', 'sim.pin_required', 'SIMST=16'),
        255 => _termRef('state/simst/255.png', 'sim.state.255', 'SIMST=255'),
        _ => const IcoRef('state/-1.png', 'simst неизвестен'),
      };

  static IcoRef srvst(int v) => switch (v) {
        0 => _termRef('state/srvst/0.png', 'network.state.0', 'SRVST=0'),
        1 => _termRef('state/srvst/1.png', 'network.state.1', 'SRVST=1'),
        2 => _termRef('state/srvst/2.png', 'network.state.2', 'SRVST=2'),
        112 => _termRef('state/srvst/112.png', 'network.state.no_valid_sim',
            'SRVST=1 + invalid SIM'),
        _ => const IcoRef('state/-1.png', 'srvst неизвестен'),
      };

  static IcoRef captcha(String c) {
    const m = {
      'capok': 'captcha.ok',
      'capnew': 'captcha.new',
      'capfail': 'captcha.fail',
      'ipalevo': 'captcha.pal',
    };
    final id = m[c];
    return id == null
        ? IcoRef('qos/$c.png', '$c — неизвестное значение')
        : _termRef('qos/$c.png', id, c);
  }

  static IcoRef rssi(int level) =>
      IcoRef('rssi/rssi-$level.png', 'уровень сигнала $level/4');

  static IcoRef dongle(String model) => IcoRef(
      switch (model) {
        'E1550' => 'dongle1550.png',
        'E173' => 'dongle173.png',
        _ => 'dongle.png',
      },
      'модем $model');

  /// Reader hardware model icon (`readers.php`'s `$model` code). Unrecognized/absent
  /// models render no icon rather than falling back to a generic glyph, since no such
  /// asset exists for readers.
  static IcoRef? readerModel(String model) => switch (model) {
        '1001' => const IcoRef('pl2303.png', 'PL2303'),
        _ => null,
      };
}
