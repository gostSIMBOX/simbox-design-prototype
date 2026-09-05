import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/design/tokens.dart';
import 'package:simbox_adminka/pages/glossary_page.dart';

void main() {
  for (final size in [const Size(1200, 900), const Size(480, 800)]) {
    testWidgets('Glossary is readable at ${size.width}px', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(body: GlossaryPage()),
      ));

      expect(find.text('Глоссарий GostSimBox'), findsOneWidget);
      expect(find.text('Средняя длительность соединения'), findsOneWidget);
      expect(find.textContaining('ACD = total_billsec'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
