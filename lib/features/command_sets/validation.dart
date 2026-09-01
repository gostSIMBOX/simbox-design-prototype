import 'models.dart';

class FieldIssue {
  final String path;
  final String message;
  const FieldIssue(this.path, this.message);
}

class ValidationResult {
  final List<FieldIssue> issues;
  const ValidationResult(this.issues);
  bool get isValid => issues.isEmpty;
  String? at(String path) {
    for (final issue in issues) {
      if (issue.path == path) return issue.message;
    }
    return null;
  }
}

final _safeId = RegExp(r'^[a-z0-9]+(?:_[a-z0-9]+)*$');
final _templateRef = RegExp(r'\{\{([a-z][a-zA-Z0-9_]*)\}\}');

ValidationResult validateCommandSet(CommandSet value,
    {Iterable<String> otherIds = const []}) {
  final issues = <FieldIssue>[];
  if (value.id.isEmpty || value.id.length > 64 || !_safeId.hasMatch(value.id)) {
    issues.add(const FieldIssue(
        'metadata.id', 'Используйте строчные латинские буквы, цифры и _.'));
  }
  if (otherIds.contains(value.id)) {
    issues.add(const FieldIssue('metadata.id', 'Такой ID уже используется.'));
  }
  if (value.name.trim().isEmpty || value.name.length > 100) {
    issues.add(
        const FieldIssue('metadata.name', 'Укажите название до 100 символов.'));
  }
  if (value.operatorName.trim().isEmpty || value.operatorName.length > 80) {
    issues.add(const FieldIssue(
        'metadata.operator', 'Укажите оператора до 80 символов.'));
  }
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(value.countryCode)) {
    issues.add(const FieldIssue(
        'metadata.country', 'Укажите двухбуквенный код страны.'));
  }
  if (value.countryName.trim().isEmpty) {
    issues.add(const FieldIssue('metadata.country', 'Укажите страну.'));
  }
  if ((value.region?.length ?? 0) > 80) {
    issues.add(const FieldIssue(
        'metadata.region', 'Регион должен быть короче 80 символов.'));
  }

  final commandIds = <String>{};
  for (final command in value.commands) {
    final base = 'commands.${command.id}';
    if (!commandIds.add(command.id) || !_safeId.hasMatch(command.id)) {
      issues.add(FieldIssue(
          '$base.id', 'ID команды должен быть уникальным и безопасным.'));
    }
    if (command.name.trim().isEmpty) {
      issues.add(FieldIssue('$base.name', 'Укажите название команды.'));
    }
    if (command.operations.isEmpty) {
      issues.add(
          FieldIssue('$base.operations', 'Добавьте хотя бы одно действие.'));
    }
    final parameterKeys = command.parameters.map((p) => p.key).toSet();
    final operationIds = <String>{};
    for (final operation in command.operations) {
      final opPath = '$base.operations.${operation.id}';
      if (!operationIds.add(operation.id) || !_safeId.hasMatch(operation.id)) {
        issues.add(
            FieldIssue('$opPath.id', 'ID действия должен быть уникальным.'));
      }
      if (operation is UssdDialogOperation) {
        _validateTemplate(operation.start.payloadTemplate, parameterKeys,
            '$opPath.start.payload', issues,
            emptyMessage: 'Укажите стартовый USSD-код.');
        final replyIds = <String>{};
        for (final reply in operation.replies) {
          final replyPath = '$opPath.replies.${reply.id}';
          if (!replyIds.add(reply.id)) {
            issues.add(FieldIssue(
                '$replyPath.id', 'ID ответа должен быть уникальным.'));
          }
          _validateTemplate(reply.payloadTemplate, parameterKeys,
              '$replyPath.payload', issues,
              emptyMessage: 'Укажите USSD-ответ.');
          final fallback = reply.fallbackAfterSeconds;
          if (fallback != null && (fallback < 1 || fallback > 300)) {
            issues.add(FieldIssue(
                '$replyPath.fallback', 'Допустимо от 1 до 300 секунд.'));
          }
        }
      } else if (operation is SendSmsOperation) {
        _validateTemplate(operation.destinationTemplate, parameterKeys,
            '$opPath.destination', issues,
            emptyMessage: 'Укажите получателя SMS.');
        _validateTemplate(
            operation.messageTemplate, parameterKeys, '$opPath.message', issues,
            emptyMessage: 'Укажите текст SMS.');
      } else if (operation is PlaceCallOperation) {
        _validateTemplate(
            operation.numberTemplate, parameterKeys, '$opPath.number', issues,
            emptyMessage: 'Укажите номер телефона.');
      } else if (operation is SendAtOperation) {
        _validateTemplate(
            operation.commandTemplate, parameterKeys, '$opPath.command', issues,
            emptyMessage: 'Укажите AT-команду.');
      }
    }
  }

  final ruleIds = <String>{};
  for (final rule in value.responseRules) {
    final base = 'rules.${rule.id}';
    if (!ruleIds.add(rule.id) || !_safeId.hasMatch(rule.id)) {
      issues.add(FieldIssue(
          '$base.id', 'ID правила должен быть уникальным и безопасным.'));
    }
    if (rule.name.trim().isEmpty) {
      issues.add(FieldIssue('$base.name', 'Укажите название правила.'));
    }
    if (rule.matcher.pattern.isEmpty) {
      issues
          .add(FieldIssue('$base.pattern', 'Укажите текст или шаблон ответа.'));
    }
    if (rule.matcher.mode == MatchMode.regularExpression &&
        rule.matcher.pattern.isNotEmpty) {
      try {
        RegExp(rule.matcher.pattern, caseSensitive: rule.matcher.caseSensitive);
      } on FormatException {
        issues.add(
            FieldIssue('$base.pattern', 'Некорректное регулярное выражение.'));
      }
    }
    if (rule.effects.isEmpty && rule.outcome == null) {
      issues.add(FieldIssue(
          '$base.effects', 'Добавьте сохраняемое значение или результат.'));
    }
    final destinations = <ResponseField>{};
    for (var i = 0; i < rule.effects.length; i++) {
      final effect = rule.effects[i];
      final effectPath = '$base.effects.$i';
      if (!destinations.add(effect.field)) {
        issues.add(FieldIssue(
            '$effectPath.field', 'Поле уже заполняется этим правилом.'));
      }
      if (effect.source == ValueSource.fixedValue &&
          (effect.fixedValue?.isEmpty ?? true)) {
        issues.add(
            FieldIssue('$effectPath.value', 'Укажите фиксированное значение.'));
      }
      if (effect.source == ValueSource.capture) {
        final capture = effect.captureNameOrIndex;
        if (capture == null || capture.isEmpty) {
          issues.add(
              FieldIssue('$effectPath.capture', 'Укажите группу захвата.'));
        } else if (!RegExp(r'^(?:[1-9][0-9]*|[A-Za-z_][A-Za-z0-9_]*)$')
            .hasMatch(capture)) {
          issues.add(FieldIssue(
              '$effectPath.capture', 'Укажите номер или имя группы захвата.'));
        }
      }
    }
  }
  return ValidationResult(issues);
}

void _validateTemplate(
    String value, Set<String> parameters, String path, List<FieldIssue> issues,
    {required String emptyMessage}) {
  if (value.trim().isEmpty) {
    issues.add(FieldIssue(path, emptyMessage));
    return;
  }
  for (final match in _templateRef.allMatches(value)) {
    final key = match.group(1)!;
    if (!parameters.contains(key)) {
      issues.add(FieldIssue(path, 'Параметр {{$key}} не объявлен.'));
    }
  }
  final withoutValidRefs = value.replaceAll(_templateRef, '');
  if (withoutValidRefs.contains('{{') || withoutValidRefs.contains('}}')) {
    issues.add(FieldIssue(path, 'Проверьте синтаксис {{параметра}}.'));
  }
}
