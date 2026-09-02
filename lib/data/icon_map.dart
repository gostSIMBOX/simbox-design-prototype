import 'models.dart';

/// Folder = semantic axis, filename = raw protocol value.
/// Every mapping keeps the raw code in the tooltip.
class Ico {
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
        return const [IcoRef('pause2.png', 'пауза'), IcoRef('day_work.png', 'рабочий день')];
      }
      if (pause == 11) {
        return const [IcoRef('wake.png', 'просыпается'), IcoRef('day_work.png', 'рабочий день')];
      }
      if (pause == 21) {
        return const [IcoRef('sleep.png', 'спит'), IcoRef('day_work.png', 'рабочий день')];
      }
      return const [IcoRef('play.png', 'в работе')];
    }
    if (group == 333) return const [IcoRef('high_datt.png', 'автоблок: высокий DATT')];
    if (group == 334) return const [IcoRef('low_acdl.png', 'автоблок: низкий ACDL')];
    if (group == 335) return const [IcoRef('blocked_balance.png', 'блок по балансу')];
    if (group == 336) return const [IcoRef('simblocked.png', 'симка заблокирована')];
    if (group >= 300 && group <= 399) return const [IcoRef('low_acdl.png', 'низкий ACDL')];
    if (group >= 400 && group <= 499) return const [IcoRef('low_balance.png', 'низкий баланс')];
    if (group >= 500) return const [IcoRef('blocked.png', 'заблокирована')];
    return const [];
  }

  static const _qosMap = <String, List<String>>{
    'VIP': ['qos/ivip.png', 'достоверные источники'],
    'GOO': ['qos/igoo.png', 'белый список'],
    'NOR': ['qos/inor.png', 'нормальные'],
    'BAD': ['qos/ibad.png', 'чёрный список'],
    'NEW': ['qos/inew.png', 'новый номер'],
    'NOS': ['qos/inos.png', 'нет ответа сервера'],
    'ROB': ['qos/irob.png', 'робот'],
    'BLO': ['qos/iblo.png', 'блокировка'],
    'FAST': ['qos/fast.png', 'быстрый'],
    'VERY': ['qos/very.png', 'очень быстрый'],
    'SLOW': ['qos/slow.png', 'медленный'],
    'NEVER': ['qos/never.png', 'никогда'],
  };

  static IcoRef? qos(String q, String io) {
    if (q == 'SOU') {
      return IcoRef('state/state_sout_${io == 'I' ? 'in' : 'out'}.png', 'SOU — свой себе');
    }
    final m = _qosMap[q];
    return m == null ? null : IcoRef(m[0], '$q — ${m[1]}');
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
  };

  static IcoRef? spec(String s) {
    final m = _specMap[s];
    return m == null ? null : IcoRef(m[0], '$s — ${m[1]}');
  }

  static IcoRef? im(String v) {
    const m = {'A': 'ima', 'B': 'imb', 'C': 'imc', 'D': 'imd', 'E': 'ime', 'N': 'imn'};
    final f = m[v];
    return f == null ? null : IcoRef('im/$f.png', 'мульти-сим $v');
  }

  static IcoRef? io(String v) => switch (v) {
        'O' => const IcoRef('state_out.png', 'исходящий'),
        'I' => const IcoRef('state_in.png', 'входящий'),
        'W' => const IcoRef('state_wait.png', 'ожидание'),
        _ => null,
      };

  static IcoRef cfun(int c) => switch (c) {
        1 => const IcoRef('p-on.png', 'cfun=1 — передатчик включён'),
        5 => const IcoRef('p-off.png', 'cfun=5 — передатчик выключен'),
        4 => const IcoRef('state/cfun/4.png', 'cfun=4 — только приём'),
        6 => const IcoRef('state/cfun/6.png', 'cfun=6 — перезагрузка'),
        _ => const IcoRef('state/-1.png', 'cfun неизвестен'),
      };

  static IcoRef simst(int v) => switch (v) {
        0 => const IcoRef('state/simst/0.png', 'simst=0 — SIM не готова'),
        1 => const IcoRef('state/simst/1.png', 'simst=1 — SIM готова'),
        4 => const IcoRef('state/simst/4.png', 'simst=4 — SIM занята'),
        16 => const IcoRef('state/simst/16.png', 'simst=16 — нужен PIN'),
        255 => const IcoRef('state/simst/255.png', 'simst=255 — нет SIM'),
        _ => const IcoRef('state/-1.png', 'simst неизвестен'),
      };

  static IcoRef srvst(int v) => switch (v) {
        0 => const IcoRef('state/srvst/0.png', 'srvst=0 — нет сети'),
        1 => const IcoRef('state/srvst/1.png', 'srvst=1 — в сети'),
        2 => const IcoRef('state/srvst/2.png', 'srvst=2 — поиск сети'),
        _ => const IcoRef('state/-1.png', 'srvst неизвестен'),
      };

  static IcoRef captcha(String c) {
    const m = {
      'capok': 'капча пройдена',
      'capnew': 'новая капча',
      'capfail': 'капча не пройдена'
    };
    return IcoRef('qos/$c.png', '$c — ${m[c] ?? c}');
  }

  static IcoRef rssi(int level) => IcoRef('rssi/rssi-$level.png', 'уровень сигнала $level/4');

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
