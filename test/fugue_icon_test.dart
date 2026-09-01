import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/widgets/fugue_icon.dart';

const names = <String>[
  'application-list.png',
  'application-form.png',
  'application--pencil.png',
  'application--plus.png',
  'application--minus.png',
  'applications-stack.png',
  'ui-menu.png',
  'application-task.png',
  'funnel--pencil.png',
  'funnel--plus.png',
  'mobile-phone--arrow.png',
  'mail.png',
  'telephone.png',
  'terminal.png',
  'regular-expression.png',
  'beaker.png',
  'arrow-move.png',
  'disk.png',
  'cross.png',
  'lock.png',
  'magnifier.png',
  'document-copy.png',
  'exclamation.png',
  'tick.png',
  'information.png',
];

int _pngDimension(File file, int offset) {
  final bytes = file.readAsBytesSync();
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}

void main() {
  test('every Fugue glyph has an exact 16px/32px density pair', () {
    for (final name in names) {
      final one = File('assets/fugue/$name');
      final two = File('assets/fugue/2.0x/$name');
      expect(one.existsSync(), isTrue, reason: '$name 1x');
      expect(two.existsSync(), isTrue, reason: '$name 2x');
      expect((_pngDimension(one, 16), _pngDimension(one, 20)), (16, 16));
      expect((_pngDimension(two, 16), _pngDimension(two, 20)), (32, 32));
    }
  });

  testWidgets('FugueIcon keeps a 16 logical pixel box', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: FugueIcon('application-list.png')),
    ));
    expect(tester.getSize(find.byType(Image)), const Size(16, 16));
  });
}
