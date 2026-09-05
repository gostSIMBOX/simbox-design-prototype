import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/design/tokens.dart';
import 'package:simbox_adminka/pages/glossary_page.dart';
import 'package:simbox_adminka/pages/icons_page.dart';

void main() {
  Future<void> render(
    WidgetTester tester,
    Widget page,
    Size size,
    String golden,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(),
      home: Scaffold(body: page),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(Scaffold), matchesGoldenFile(golden));
  }

  testWidgets('wide icon legend visual', (tester) async {
    await render(tester, const IconsPage(), const Size(1400, 900),
        'goldens/icon_legend_wide.png');
  });

  testWidgets('narrow glossary visual', (tester) async {
    await render(tester, const GlossaryPage(), const Size(480, 900),
        'goldens/glossary_narrow.png');
  });
}
