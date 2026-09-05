import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/data/icon_map.dart';

void main() {
  test('GOO tooltip exposes owner-confirmed formula and thresholds', () {
    final goo = Ico.qos('GOO', 'O')!;
    expect(goo.path, 'qos/igoo.png');
    expect(goo.title, contains('ACD ≥ 300 с'));
    expect(goo.title, contains('ASR ≥ 80%'));
  });

  test('SOU and IM tooltips use relationship semantics', () {
    expect(Ico.qos('SOU', 'I')!.title, contains('принимающая сторона'));
    expect(Ico.qos('SOU', 'O')!.title, contains('инициирующая сторона'));
    expect(Ico.im('B')!.title, contains('первая (основная)'));
    expect(Ico.im('N')!.title, contains('разрешена любая SIM'));
    expect(Ico.im('B')!.title, isNot(contains('мульти-сим')));
  });

  test('modem, SIM and network raw states retain assets and corrected text',
      () {
    expect(Ico.cfun(4).path, 'state/cfun/4.png');
    expect(Ico.cfun(4).title, contains('SIM удалена'));
    expect(Ico.simst(3).path, 'state/simst/1.png');
    expect(Ico.simst(4).title, isNot(contains('занята')));
    expect(Ico.srvst(112).path, 'state/srvst/112.png');
  });

  test('incoming recency tooltip identifies caller plus receiving SIM pair',
      () {
    final fast = Ico.qos('FAST', 'I')!;
    expect(fast.title, contains('этого звонящего номера'));
    expect(fast.title, contains('этой принимающей SIM'));
  });

  test('group() covers all six pause combinations, workday and holiday', () {
    expect(Ico.group(150, 1)[1].path, 'day_work.png');
    expect(Ico.group(150, 2)[1].path, 'day_holiday.png');
    expect(Ico.group(150, 11)[1].path, 'day_work.png');
    expect(Ico.group(150, 12)[1].path, 'day_holiday.png');
    expect(Ico.group(150, 21)[1].path, 'day_work.png');
    expect(Ico.group(150, 22)[1].path, 'day_holiday.png');
  });

  test('vip() returns the exact 3-way legacy branch, raw-value labeled only',
      () {
    expect(Ico.vip(11)!.path, 'ivip1.png');
    expect(Ico.vip(12)!.path, 'ivip2.png');
    expect(Ico.vip(1)!.path, 'ivip.png');
    expect(Ico.vip(0), isNull);
  });

  test('qos() resolves the newly-added SPAM/IMO/SYS values', () {
    expect(Ico.qos('SPAM', 'I')!.path, 'spam.png');
    expect(Ico.qos('IMO', 'O')!.path, 'imode.png');
    // SYS intentionally reuses the NOS asset — legacy has no distinct SYS
    // icon (modules/html.php:334 always renders inos.png for numeric 0).
    expect(Ico.qos('SYS', 'O')!.path, 'qos/inos.png');
  });

  test('fas()/pre()/pos() render only when the underlying flag is set', () {
    expect(Ico.fas(true)!.path, 'fas.png');
    expect(Ico.fas(false), isNull);
    expect(Ico.pre(true).path, 'spec/pre.png');
    expect(Ico.pos(true).path, 'spec/pos.png');
  });

  test('liveCall() resolves all four live-state icons', () {
    expect(Ico.liveCall('dialing').path, 'state/state_dial.png');
    expect(Ico.liveCall('ring').path, 'state/state_ring.png');
    expect(Ico.liveCall('active').path, 'state/state_active.png');
    expect(Ico.liveCall('cooldown').path, 'state_wait.png');
  });
}
