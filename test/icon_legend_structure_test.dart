import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/data/icons_catalog.dart';

int _fnv1a32(String value) {
  var hash = 2166136261;
  for (final byte in value.codeUnits) {
    hash = ((hash ^ byte) * 16777619) & 0xffffffff;
  }
  return hash;
}

void main() {
  test('legacy icon legend keeps its complete ordered structure', () {
    expect(iconCatalog.length, 10);
    expect(iconCatalog.map((group) => group.items.length),
        [12, 13, 13, 19, 13, 16, 18, 6, 26, 28]);
    expect(
      iconCatalog.map((group) => (group.title, group.path)),
      const [
        ('Группа и расписание', 'imgs/ · group + pause'),
        ('Состояние звонка', 'imgs/state/'),
        ('Передатчик · SIM · сеть', 'imgs/state/cfun · simst · srvst'),
        ('Классификация и история (qos)', 'imgs/qos/'),
        ('Спец-режимы (spec)', 'imgs/spec/'),
        ('Связь SIM с номером и распознавание', 'imgs/im · imgs/recog_types'),
        ('Сигнал, модемы и USB', 'imgs/rssi · usb · tree'),
        ('Перепрошивка (diagmode)', 'imgs/diagmode/'),
        ('SMS, USSD и прочее', 'imgs/'),
        ('Направления', 'imgs/napravleine/'),
      ],
    );

    final assetAndCode = iconCatalog
        .expand((group) => group.items)
        .map((item) => '${item.file}|${item.code}')
        .join('\n');
    expect(_fnv1a32(assetAndCode), 3847223024);
  });
}
