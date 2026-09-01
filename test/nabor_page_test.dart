import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/design/tokens.dart';
import 'package:simbox_adminka/features/command_sets/models.dart';
import 'package:simbox_adminka/pages/nabor_page.dart';
import 'package:simbox_adminka/state/app_state.dart';

void main() {
  testWidgets('workspace has two sections and no Overview or migration status',
      (tester) async {
    final state = AppState();
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
          theme: buildTheme(), home: const Scaffold(body: NaborPage())),
    ));
    await tester.pump();

    expect(find.textContaining('Команды'), findsWidgets);
    expect(find.textContaining('Правила ответов'), findsOneWidget);
    expect(find.text('Overview'), findsNothing);
    expect(find.textContaining('Migrated'), findsNothing);
    expect(find.textContaining('миграц', findRichText: true), findsNothing);
    expect(find.textContaining('MegaFon · Москва'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });

  testWidgets('narrow workspace replaces registry pane with compact selector',
      (tester) async {
    final state = AppState();
    tester.view.physicalSize = const Size(760, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
          theme: buildTheme(), home: const Scaffold(body: NaborPage())),
    ));
    await tester.pump();
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });

  testWidgets('response rules remain usable below 560px', (tester) async {
    final state = AppState();
    state.commandSets.requestSelectSet('tele2_spb');
    state.commandSets.selectSection(CommandSetSection.responseRules);
    tester.view.physicalSize = const Size(500, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
          theme: buildTheme(), home: const Scaffold(body: NaborPage())),
    ));
    await tester.pump();
    expect(find.textContaining('Баланс'), findsWidgets);
    await tester.tap(find.text('Баланс').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });

  testWidgets('USSD Start Reply editor remains usable below 560px',
      (tester) async {
    final state = AppState();
    state.commandSets.requestSelectSet('megafon_spb');
    state.commandSets.selectCommand('activate_work');
    tester.view.physicalSize = const Size(500, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
          theme: buildTheme(), home: const Scaffold(body: NaborPage())),
    ));
    await tester.pump();
    final operation = find.text('USSD-диалог').first;
    await tester.ensureVisible(operation);
    await tester.pumpAndSettle();
    await tester.tap(operation);
    await tester.pumpAndSettle();
    expect(find.text('Fallback, сек'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}
