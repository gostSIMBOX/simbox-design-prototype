import 'dart:convert';
import 'dart:io';
import 'package:simbox_adminka/features/command_sets/seed.dart';

enum AuditDisposition {
  structuredCommand,
  structuredRule,
  planPolicy,
  simRuntime,
  scheduler,
  metadata,
  evidenceOnly
}

class AuditEntry {
  final String path;
  final AuditDisposition disposition;
  final String? targetId;
  const AuditEntry(this.path, this.disposition, [this.targetId]);
}

const inactiveCommands = <String>{
  'beeline_spb/commands/123',
  'life/commands/send_mon.sh',
  'tele2_spb/commands/activate_work_old.sh',
  'tele2_spb/commands/send_may.sh',
  'tele2_spb/commands/send_mon.sh',
  'velcom/commands/activate_work_fork.sh',
  'velcom/commands/activate_sim.sh',
  'velcom/commands/get_number_fork.sh',
  'velcom/commands/send_mon.sh',
  'megafon_spb/commands/get_tarif.sh',
};

const expectedLegacyTreeSha256 =
    'a1ca354c2e37ae85d0718323c81685f2914c755e93138caa0018b990079a3866';

AuditEntry classify(String path) {
  if (path == 'nabor.list') return AuditEntry(path, AuditDisposition.metadata);
  if (path.contains('/old/')) {
    return AuditEntry(path, AuditDisposition.evidenceOnly);
  }
  final parts = path.split('/');
  if (parts.length < 2) return AuditEntry(path, AuditDisposition.evidenceOnly);
  final setId = parts.first;
  final file = parts.last;
  if (file == 'config.sh') return AuditEntry(path, AuditDisposition.planPolicy);
  if (parts.length == 2) return AuditEntry(path, AuditDisposition.evidenceOnly);

  if (parts[1] == 'commands') {
    if (file.startsWith('setdaylimit') || file == 'setlimit_newday.php') {
      return AuditEntry(path, AuditDisposition.scheduler);
    }
    if (inactiveCommands.contains(path)) {
      return AuditEntry(path, AuditDisposition.evidenceOnly);
    }
    if (path == 'kievstar/commands/activate_sim_fork') {
      return AuditEntry(
          path, AuditDisposition.structuredCommand, '$setId/activate_sim');
    }
    final stem = file.replaceAll(RegExp(r'\.(sh|php)$'), '');
    final target = switch (stem) {
      'get_dover' => 'get_promise_payment',
      'get_tarif' => 'get_tariff',
      'inittarif' => 'initialize_tariff',
      'getbalance' => 'get_balance',
      'getnumber' => 'get_number',
      'disable209' => 'disable_service_209',
      _ => stem,
    };
    return AuditEntry(
        path, AuditDisposition.structuredCommand, '$setId/$target');
  }

  if (parts[1] == 'parse') {
    if (file == 'all.sh' ||
        file == 'all.php' ||
        file == '1.php' ||
        file == 'test.php') {
      return AuditEntry(path, AuditDisposition.evidenceOnly);
    }
    final lower = file.toLowerCase();
    final suffix = lower.contains('balance')
        ? 'balance'
        : lower.contains('number')
            ? 'number'
            : lower.contains('tarif')
                ? 'tariff'
                : lower.contains('minute')
                    ? 'minutes'
                    : lower.contains('option')
                        ? 'options'
                        : lower.contains('dover')
                            ? 'promise'
                            : lower.contains('blocked')
                                ? 'blocked'
                                : lower.contains('low')
                                    ? 'low_balance'
                                    : null;
    return suffix == null
        ? AuditEntry(path, AuditDisposition.evidenceOnly)
        : AuditEntry(path, AuditDisposition.structuredRule, '${setId}_$suffix');
  }
  return AuditEntry(path, AuditDisposition.evidenceOnly);
}

Future<String> legacyTreeSha256(Directory source, List<String> paths) async {
  final inventory = StringBuffer();
  for (final path in paths) {
    final result = Process.runSync('shasum',
        ['-a', '256', '${source.path}${Platform.pathSeparator}$path']);
    if (result.exitCode != 0) {
      throw StateError('Unable to hash $path: ${result.stderr}');
    }
    final digest = result.stdout.toString().trim().split(RegExp(r'\s+')).first;
    inventory.writeln('$digest  $path');
  }
  final aggregate = await Process.start('shasum', ['-a', '256']);
  aggregate.stdin.write(inventory.toString());
  await aggregate.stdin.close();
  final stdoutText = await utf8.decoder.bind(aggregate.stdout).join();
  final stderrText = await utf8.decoder.bind(aggregate.stderr).join();
  final processExitCode = await aggregate.exitCode;
  if (processExitCode != 0) {
    throw StateError('Unable to hash legacy inventory: $stderrText');
  }
  return stdoutText.trim().split(RegExp(r'\s+')).first;
}

Future<void> main() async {
  final source = Directory('../../legacy/simbox-desktop-v2014/nabor');
  if (!source.existsSync()) {
    stderr.writeln('Legacy nabor tree not found: ${source.absolute.path}');
    exitCode = 2;
    return;
  }
  final files = source
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .map((file) => file.path.substring(source.path.length + 1))
      .toList()
    ..sort();
  final entries = files.map(classify).toList();
  final failures = <String>[];
  if (files.length != 204) {
    failures.add('Expected 204 legacy files, found ${files.length}.');
  }
  if (entries.map((item) => item.path).toSet().length != files.length) {
    failures.add('A legacy path was classified more than once.');
  }
  final treeSha256 = await legacyTreeSha256(source, files);
  if (treeSha256 != expectedLegacyTreeSha256) {
    failures.add('Legacy path/content inventory changed: $treeSha256.');
  }
  final sets = {for (final set in commandSetSeed) set.id: set};
  for (final entry in entries) {
    final target = entry.targetId;
    if (target == null) continue;
    if (entry.disposition == AuditDisposition.structuredCommand) {
      final split = target.split('/');
      final set = sets[split.first];
      if (set == null || !set.commands.any((item) => item.id == split.last)) {
        failures.add('${entry.path} points to missing command $target.');
      }
    }
    if (entry.disposition == AuditDisposition.structuredRule &&
        !commandSetSeed
            .expand((set) => set.responseRules)
            .any((item) => item.id == target)) {
      failures.add('${entry.path} points to missing response rule $target.');
    }
  }
  if (failures.isNotEmpty) {
    stderr.writeln(failures.join('\n'));
    exitCode = 1;
    return;
  }
  final counts = <AuditDisposition, int>{};
  for (final entry in entries) {
    counts.update(entry.disposition, (value) => value + 1, ifAbsent: () => 1);
  }
  stdout.writeln(
      'Verified ${entries.length} legacy files and ${commandSetSeed.length} structured sets.');
  stdout.writeln('legacyTreeSha256: $treeSha256');
  for (final disposition in AuditDisposition.values) {
    stdout.writeln('${disposition.name}: ${counts[disposition] ?? 0}');
  }
}
