import 'package:flutter_test/flutter_test.dart';
import 'package:simbox_adminka/data/glossary_catalog.dart';
import 'package:simbox_adminka/data/icons_catalog.dart';
import 'package:simbox_adminka/data/terminology.dart';

void main() {
  test('localization supports all configured locales with English fallback',
      () {
    for (final locale in supportedLocales) {
      expect(
          resolveLocalized(terminology['qos.goo']!.shortLabel, locale: locale),
          isNotEmpty);
    }
    expect(
        resolveLocalized(const {'en': 'fallback'}, locale: 'th'), 'fallback');
  });

  test('GOO formulas and inclusive thresholds remain exact', () {
    expect(terminology['metric.acd']!.formula,
        'ACD = total_billsec / total_answered');
    expect(terminology['metric.asr']!.formula,
        'ASR = total_answered / total_calls * 100');
    expect(terminology['qos.goo']!.formula,
        contains('GOO = ACD >= 300 && ASR >= 80'));
  });

  test('every audited legend and glossary ID resolves', () {
    for (final item in iconCatalog.expand((group) => group.items)) {
      expect(termById(item.termId, fallbackLabel: item.legacyLabel).id,
          item.termId);
    }
    final glossaryIds =
        glossaryCatalog.expand((group) => group.termIds).toList();
    expect(glossaryIds.toSet().length, glossaryIds.length);
    for (final id in glossaryIds) {
      expect(terminology.containsKey(id), isTrue, reason: id);
    }
  });

  test('unresolved legacy codes stay explicitly unresolved', () {
    for (final id in ['qos.ne0', 'qos.nem', 'captcha.pal', 'im.ima']) {
      expect(terminology[id]!.confidence, TermConfidence.unresolved);
    }
  });
}
