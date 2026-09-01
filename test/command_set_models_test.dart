import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/features/command_sets/models.dart';
import 'package:simbox_adminka/features/command_sets/seed.dart';
import 'package:simbox_adminka/features/command_sets/validation.dart';

void main() {
  test('structured seed contains the exact legacy registry order', () {
    expect(commandSetSeed.map((set) => set.id), const [
      'default',
      'megafon_msk',
      'megafon_spb',
      'beeline_spb',
      'mts_spb',
      'tele2_spb',
      'rostel_spb',
      'kievstar',
      'velcom',
      'life',
    ]);
    expect(commandSetSeed.where((set) => set.isSystem).single.id, 'default');
    expect(commandSetSeed.any((set) => set.id == 'megafon_mks'), isFalse);
  });

  test('every structured seed set is valid', () {
    for (final set in commandSetSeed) {
      final result = validateCommandSet(set);
      expect(result.issues.map((issue) => '${issue.path}: ${issue.message}'),
          isEmpty,
          reason: set.id);
    }
  });

  test('USSD reply fallback belongs to the transition', () {
    final set = commandSetSeed.singleWhere((item) => item.id == 'megafon_spb');
    final command =
        set.commands.singleWhere((item) => item.id == 'activate_work');
    final dialog = command.operations.single as UssdDialogOperation;
    expect(dialog.start.payloadTemplate, '*105*0082#');
    expect(dialog.replies.single.payloadTemplate, '1');
    expect(dialog.replies.single.fallbackAfterSeconds, 7);
  });

  test('PIN is a secret command parameter rather than set metadata', () {
    final set = commandSetSeed.singleWhere((item) => item.id == 'tele2_spb');
    final command = set.commands.singleWhere((item) => item.id == 'enter_pin');
    final parameter = command.parameters.single;
    expect(parameter.type, ParameterType.pin);
    expect(parameter.secret, isTrue);
    expect((command.operations.single as SendAtOperation).commandTemplate,
        contains('{{pin}}'));
  });
}
