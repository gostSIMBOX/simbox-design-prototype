import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/features/command_sets/controller.dart';
import 'package:simbox_adminka/features/command_sets/models.dart';
import 'package:simbox_adminka/features/command_sets/repository.dart';
import 'package:simbox_adminka/features/command_sets/response_preview.dart';
import 'package:simbox_adminka/features/command_sets/seed.dart';

void main() {
  late CommandSetController controller;

  setUp(() {
    controller =
        CommandSetController(InMemoryCommandSetRepository(commandSetSeed))
          ..load();
  });

  test('selection opens Commands and dirty draft blocks silent selection loss',
      () {
    expect(controller.section, CommandSetSection.commands);
    controller.requestSelectSet('megafon_spb');
    controller.updateMetadata(
        name: 'Изменённый набор',
        operatorName: 'MegaFon',
        countryCode: 'RU',
        countryName: 'Россия',
        region: 'Санкт-Петербург');
    expect(controller.isDirty, isTrue);
    expect(controller.requestSelectSet('tele2_spb'), isFalse);
    expect(controller.selectedId, 'megafon_spb');
    controller.discardAndContinue();
    expect(controller.selectedId, 'tele2_spb');
    expect(controller.section, CommandSetSection.commands);
  });

  test('clone is independent and referenced delete is blocked', () {
    final result = controller.cloneSet('megafon_spb',
        id: 'megafon_nw',
        name: 'MegaFon · Северо-Запад',
        operator: 'MegaFon',
        countryCode: 'RU',
        countryName: 'Россия',
        region: 'Северо-Запад');
    expect(result.isValid, isTrue);
    expect(controller.records.last.id, 'megafon_nw');
    expect(controller.records.last.commands, isNotEmpty);
    expect(controller.inspectDelete('beeline_spb').allowed, isFalse);
    expect(controller.inspectDelete('megafon_nw').allowed, isTrue);
  });

  test('response preview can return more than one measured allowance', () {
    controller.requestSelectSet('tele2_spb');
    final set = controller.selected!;
    final rule = ResponseRule(
      id: 'allowances',
      name: 'Пакеты',
      priority: set.responseRules.length,
      channel: ResponseChannel.ussd,
      matcher: const ResponseMatcher(
          mode: MatchMode.regularExpression,
          pattern: r'([0-9]+) мин.*?([0-9]+) SMS'),
      effects: const [
        ResponseEffect(
            field: ResponseField.remainingMinutes,
            source: ValueSource.capture,
            captureNameOrIndex: '1',
            normalizers: [Normalizer.integerNumber]),
        ResponseEffect(
            field: ResponseField.remainingSms,
            source: ValueSource.capture,
            captureNameOrIndex: '2',
            normalizers: [Normalizer.integerNumber]),
      ],
    );
    controller.updateRule(rule);
    final preview =
        controller.testRule('allowances', 'Осталось 320 мин и 45 SMS');
    expect(preview.values[ResponseField.remainingMinutes], '320');
    expect(preview.values[ResponseField.remainingSms], '45');
  });

  test('response preview distinguishes no match from conversion failure', () {
    const rule = ResponseRule(
      id: 'balance_preview',
      name: 'Баланс',
      priority: 0,
      channel: ResponseChannel.ussd,
      matcher: ResponseMatcher(mode: MatchMode.startsWith, pattern: 'Баланс: '),
      effects: [
        ResponseEffect(
            field: ResponseField.balance,
            source: ValueSource.fullMatch,
            normalizers: [Normalizer.decimalNumber]),
      ],
    );
    expect(previewResponse(rule, 'Остаток: 15').matched, isFalse);
    final invalid = previewResponse(rule, 'Баланс: неизвестен');
    expect(invalid.error, contains('десятичным числом'));
  });

  test('invalid capture returns an actionable preview error', () {
    const rule = ResponseRule(
      id: 'missing_capture',
      name: 'Номер',
      priority: 0,
      channel: ResponseChannel.sms,
      matcher: ResponseMatcher(
          mode: MatchMode.regularExpression, pattern: r'номер: ([0-9]+)'),
      effects: [
        ResponseEffect(
            field: ResponseField.phoneNumber,
            source: ValueSource.capture,
            captureNameOrIndex: '2'),
      ],
    );
    final preview = previewResponse(rule, 'номер: 79123456789');
    expect(preview.matched, isTrue);
    expect(preview.error, contains('группы захвата'));
  });
}
