import 'models.dart';

class ResponsePreview {
  final bool matched;
  final String? matchedText;
  final Map<ResponseField, String> values;
  final SemanticOutcome? outcome;
  final String? error;

  const ResponsePreview(
      {required this.matched,
      this.matchedText,
      this.values = const {},
      this.outcome,
      this.error});
}

ResponsePreview previewResponse(ResponseRule rule, String sample) {
  try {
    final matcher = rule.matcher;
    final haystack = matcher.caseSensitive ? sample : sample.toLowerCase();
    final needle =
        matcher.caseSensitive ? matcher.pattern : matcher.pattern.toLowerCase();
    RegExpMatch? regexMatch;
    String? matchedText;

    switch (matcher.mode) {
      case MatchMode.contains:
        final index = haystack.indexOf(needle);
        if (index < 0) return const ResponsePreview(matched: false);
        matchedText = sample.substring(index, index + matcher.pattern.length);
      case MatchMode.startsWith:
        if (!haystack.startsWith(needle)) {
          return const ResponsePreview(matched: false);
        }
        matchedText = sample.substring(0, matcher.pattern.length);
      case MatchMode.regularExpression:
        final expression =
            RegExp(matcher.pattern, caseSensitive: matcher.caseSensitive);
        regexMatch = expression.firstMatch(sample);
        if (regexMatch == null) return const ResponsePreview(matched: false);
        matchedText = regexMatch.group(0);
    }

    final values = <ResponseField, String>{};
    for (final effect in rule.effects) {
      String? raw;
      switch (effect.source) {
        case ValueSource.fullMatch:
          raw = matchedText;
        case ValueSource.fixedValue:
          raw = effect.fixedValue;
        case ValueSource.capture:
          if (regexMatch == null) {
            return ResponsePreview(
                matched: true,
                matchedText: matchedText,
                error:
                    'Группы захвата доступны только для регулярного выражения.');
          }
          final capture = effect.captureNameOrIndex!;
          final index = int.tryParse(capture);
          raw = index == null
              ? regexMatch.namedGroup(capture)
              : regexMatch.group(index);
      }
      if (raw == null) {
        return ResponsePreview(
            matched: true,
            matchedText: matchedText,
            error: 'Не удалось извлечь ${effect.field.label.toLowerCase()}.');
      }
      var value = raw;
      for (final normalizer in effect.normalizers) {
        value = _normalize(value, normalizer);
      }
      values[effect.field] = value;
    }
    return ResponsePreview(
        matched: true,
        matchedText: matchedText,
        values: values,
        outcome: rule.outcome);
  } on FormatException catch (error) {
    return ResponsePreview(matched: false, error: error.message);
  } on RangeError {
    return const ResponsePreview(
        matched: true, error: 'В выражении нет указанной группы захвата.');
  } on ArgumentError {
    return const ResponsePreview(
        matched: true, error: 'В выражении нет указанной именованной группы.');
  }
}

String _normalize(String input, Normalizer normalizer) {
  switch (normalizer) {
    case Normalizer.trim:
      return input.trim();
    case Normalizer.plainText:
      return input;
    case Normalizer.decimalNumber:
      final value = double.tryParse(input.trim().replaceAll(',', '.'));
      if (value == null) {
        throw const FormatException('Значение не является десятичным числом.');
      }
      return value.toString();
    case Normalizer.integerNumber:
      final value = int.tryParse(input.replaceAll(RegExp(r'[^0-9-]'), ''));
      if (value == null) {
        throw const FormatException('Значение не является целым числом.');
      }
      return value.toString();
    case Normalizer.digitsOnly:
      final value = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (value.isEmpty) throw const FormatException('В значении нет цифр.');
      return value;
    case Normalizer.phoneWithCountryCode:
      final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length == 10) return '7$digits';
      if (digits.length < 7 || digits.length > 15) {
        throw const FormatException('Некорректная длина номера телефона.');
      }
      return digits;
    case Normalizer.dateTime:
      final value = DateTime.tryParse(input.trim());
      if (value == null) {
        throw const FormatException('Не удалось распознать дату.');
      }
      return value.toIso8601String();
  }
}
