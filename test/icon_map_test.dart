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
}
