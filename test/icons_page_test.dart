import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/data/icons_catalog.dart';
import 'package:simbox_adminka/design/tokens.dart';
import 'package:simbox_adminka/pages/icons_page.dart';

void main() {
  testWidgets('Icons page preserves existing wrap and 190px tile geometry',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(),
      home: const Scaffold(body: IconsPage()),
    ));

    expect(find.text('Легенда иконок GostSimBox'), findsOneWidget);
    expect(find.byType(Wrap), findsNWidgets(iconCatalog.length));
    final tiles = tester.widgetList<SizedBox>(find.byType(SizedBox));
    expect(tiles.where((box) => box.width == 190).length, 164);
    expect(find.text('Внутренний звонок между SIM'), findsOneWidget);
    expect(find.text('мультисим'), findsNothing);
    expect(find.byType(SearchBar), findsNothing);
  });
}
