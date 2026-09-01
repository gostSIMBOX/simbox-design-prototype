bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

enum CommandSetKind { systemFallback, operator }

enum CommandSetSection { commands, responseRules }

enum CommandPurpose {
  activateSim,
  activateWork,
  getBalance,
  getNumber,
  getTariff,
  getMinutes,
  getOptions,
  getPromisePayment,
  initializeTariff,
  sendMay,
  sendMon,
  enterPin,
  disableService,
  operatorService,
}

extension CommandPurposeLabel on CommandPurpose {
  String get label => switch (this) {
        CommandPurpose.activateSim => 'Активировать SIM',
        CommandPurpose.activateWork => 'Активировать работу',
        CommandPurpose.getBalance => 'Получить баланс',
        CommandPurpose.getNumber => 'Получить номер',
        CommandPurpose.getTariff => 'Получить тариф',
        CommandPurpose.getMinutes => 'Получить остаток минут',
        CommandPurpose.getOptions => 'Получить опции',
        CommandPurpose.getPromisePayment => 'Получить доверительный платёж',
        CommandPurpose.initializeTariff => 'Инициализировать тариф',
        CommandPurpose.sendMay => 'Запрос MAY',
        CommandPurpose.sendMon => 'Запрос MON',
        CommandPurpose.enterPin => 'Ввести PIN SIM',
        CommandPurpose.disableService => 'Отключить услугу',
        CommandPurpose.operatorService => 'Команда оператора',
      };
}

enum ParameterType { phoneNumber, pin, text, integer, decimal }

class CommandParameter {
  final String key;
  final String label;
  final ParameterType type;
  final bool required;
  final bool secret;

  const CommandParameter({
    required this.key,
    required this.label,
    required this.type,
    this.required = true,
    this.secret = false,
  });

  @override
  bool operator ==(Object other) =>
      other is CommandParameter &&
      key == other.key &&
      label == other.label &&
      type == other.type &&
      required == other.required &&
      secret == other.secret;

  @override
  int get hashCode => Object.hash(key, label, type, required, secret);
}

sealed class CommandOperation {
  final String id;
  const CommandOperation(this.id);
  String get typeLabel;
  CommandOperation copyWithId(String id);
}

class UssdStart {
  final String payloadTemplate;
  final String queueClass;
  const UssdStart(this.payloadTemplate, {this.queueClass = 'LOC'});

  UssdStart copyWith({String? payloadTemplate, String? queueClass}) =>
      UssdStart(
        payloadTemplate ?? this.payloadTemplate,
        queueClass: queueClass ?? this.queueClass,
      );

  @override
  bool operator ==(Object other) =>
      other is UssdStart &&
      payloadTemplate == other.payloadTemplate &&
      queueClass == other.queueClass;
  @override
  int get hashCode => Object.hash(payloadTemplate, queueClass);
}

class UssdReply {
  final String id;
  final String payloadTemplate;
  final int? fallbackAfterSeconds;
  const UssdReply(this.id, this.payloadTemplate, {this.fallbackAfterSeconds});

  UssdReply copyWith(
          {String? id,
          String? payloadTemplate,
          int? fallbackAfterSeconds,
          bool clearFallback = false}) =>
      UssdReply(
        id ?? this.id,
        payloadTemplate ?? this.payloadTemplate,
        fallbackAfterSeconds: clearFallback
            ? null
            : fallbackAfterSeconds ?? this.fallbackAfterSeconds,
      );

  @override
  bool operator ==(Object other) =>
      other is UssdReply &&
      id == other.id &&
      payloadTemplate == other.payloadTemplate &&
      fallbackAfterSeconds == other.fallbackAfterSeconds;
  @override
  int get hashCode => Object.hash(id, payloadTemplate, fallbackAfterSeconds);
}

class UssdDialogOperation extends CommandOperation {
  final UssdStart start;
  final List<UssdReply> replies;
  const UssdDialogOperation(super.id,
      {required this.start, this.replies = const []});

  @override
  String get typeLabel => 'USSD-диалог';

  UssdDialogOperation copyWith(
          {String? id, UssdStart? start, List<UssdReply>? replies}) =>
      UssdDialogOperation(id ?? this.id,
          start: start ?? this.start, replies: replies ?? this.replies);

  @override
  CommandOperation copyWithId(String id) => copyWith(id: id);

  @override
  bool operator ==(Object other) =>
      other is UssdDialogOperation &&
      id == other.id &&
      start == other.start &&
      _listEquals(replies, other.replies);
  @override
  int get hashCode => Object.hash(id, start, Object.hashAll(replies));
}

class SendSmsOperation extends CommandOperation {
  final String destinationTemplate;
  final String messageTemplate;
  final String queueClass;
  const SendSmsOperation(super.id,
      {required this.destinationTemplate,
      required this.messageTemplate,
      this.queueClass = 'LOC'});

  @override
  String get typeLabel => 'SMS';
  SendSmsOperation copyWith(
          {String? id,
          String? destinationTemplate,
          String? messageTemplate,
          String? queueClass}) =>
      SendSmsOperation(id ?? this.id,
          destinationTemplate: destinationTemplate ?? this.destinationTemplate,
          messageTemplate: messageTemplate ?? this.messageTemplate,
          queueClass: queueClass ?? this.queueClass);
  @override
  CommandOperation copyWithId(String id) => copyWith(id: id);
  @override
  bool operator ==(Object other) =>
      other is SendSmsOperation &&
      id == other.id &&
      destinationTemplate == other.destinationTemplate &&
      messageTemplate == other.messageTemplate &&
      queueClass == other.queueClass;
  @override
  int get hashCode =>
      Object.hash(id, destinationTemplate, messageTemplate, queueClass);
}

class PlaceCallOperation extends CommandOperation {
  final String numberTemplate;
  final String callProfile;
  const PlaceCallOperation(super.id,
      {required this.numberTemplate, this.callProfile = 'default'});
  @override
  String get typeLabel => 'Звонок';
  PlaceCallOperation copyWith(
          {String? id, String? numberTemplate, String? callProfile}) =>
      PlaceCallOperation(id ?? this.id,
          numberTemplate: numberTemplate ?? this.numberTemplate,
          callProfile: callProfile ?? this.callProfile);
  @override
  CommandOperation copyWithId(String id) => copyWith(id: id);
  @override
  bool operator ==(Object other) =>
      other is PlaceCallOperation &&
      id == other.id &&
      numberTemplate == other.numberTemplate &&
      callProfile == other.callProfile;
  @override
  int get hashCode => Object.hash(id, numberTemplate, callProfile);
}

class SendAtOperation extends CommandOperation {
  final String commandTemplate;
  const SendAtOperation(super.id, {required this.commandTemplate});
  @override
  String get typeLabel => 'AT-команда';
  SendAtOperation copyWith({String? id, String? commandTemplate}) =>
      SendAtOperation(id ?? this.id,
          commandTemplate: commandTemplate ?? this.commandTemplate);
  @override
  CommandOperation copyWithId(String id) => copyWith(id: id);
  @override
  bool operator ==(Object other) =>
      other is SendAtOperation &&
      id == other.id &&
      commandTemplate == other.commandTemplate;
  @override
  int get hashCode => Object.hash(id, commandTemplate);
}

class OperatorCommand {
  final String id;
  final CommandPurpose purpose;
  final String name;
  final String? description;
  final bool enabled;
  final List<CommandParameter> parameters;
  final List<CommandOperation> operations;

  const OperatorCommand({
    required this.id,
    required this.purpose,
    required this.name,
    this.description,
    this.enabled = true,
    this.parameters = const [],
    this.operations = const [],
  });

  OperatorCommand copyWith({
    String? id,
    CommandPurpose? purpose,
    String? name,
    String? description,
    bool? enabled,
    List<CommandParameter>? parameters,
    List<CommandOperation>? operations,
  }) =>
      OperatorCommand(
        id: id ?? this.id,
        purpose: purpose ?? this.purpose,
        name: name ?? this.name,
        description: description ?? this.description,
        enabled: enabled ?? this.enabled,
        parameters: parameters ?? this.parameters,
        operations: operations ?? this.operations,
      );

  @override
  bool operator ==(Object other) =>
      other is OperatorCommand &&
      id == other.id &&
      purpose == other.purpose &&
      name == other.name &&
      description == other.description &&
      enabled == other.enabled &&
      _listEquals(parameters, other.parameters) &&
      _listEquals(operations, other.operations);
  @override
  int get hashCode => Object.hash(id, purpose, name, description, enabled,
      Object.hashAll(parameters), Object.hashAll(operations));
}

enum ResponseChannel { ussd, sms, callResult }

enum MatchMode { contains, startsWith, regularExpression }

enum ValueSource { fullMatch, capture, fixedValue }

enum Normalizer {
  trim,
  decimalNumber,
  integerNumber,
  digitsOnly,
  phoneWithCountryCode,
  dateTime,
  plainText
}

enum ResponseField {
  balance,
  phoneNumber,
  tariff,
  remainingMinutes,
  remainingSms,
  options,
  promisePaymentAmount,
  promisePaymentState,
  promisePaymentDate,
}

enum SemanticOutcome {
  reservePreparation,
  reserveReady,
  workPreparation,
  workReady,
  workNeedsIncoming,
  stopped,
  lowBalance,
  blocked,
}

extension ResponseLabels on ResponseField {
  String get label => switch (this) {
        ResponseField.balance => 'Баланс',
        ResponseField.phoneNumber => 'Номер телефона',
        ResponseField.tariff => 'Тариф',
        ResponseField.remainingMinutes => 'Остаток минут',
        ResponseField.remainingSms => 'Остаток SMS',
        ResponseField.options => 'Опции',
        ResponseField.promisePaymentAmount => 'Сумма доверительного платежа',
        ResponseField.promisePaymentState => 'Статус доверительного платежа',
        ResponseField.promisePaymentDate => 'Дата доверительного платежа',
      };
}

extension SemanticOutcomeLabel on SemanticOutcome {
  String get label => switch (this) {
        SemanticOutcome.reservePreparation => 'Подготовка резерва',
        SemanticOutcome.reserveReady => 'Резерв готов',
        SemanticOutcome.workPreparation => 'Подготовка к работе',
        SemanticOutcome.workReady => 'Готова к работе',
        SemanticOutcome.workNeedsIncoming => 'Нужен входящий',
        SemanticOutcome.stopped => 'Остановлена',
        SemanticOutcome.lowBalance => 'Низкий баланс',
        SemanticOutcome.blocked => 'Заблокирована',
      };
}

class ResponseMatcher {
  final MatchMode mode;
  final String pattern;
  final bool caseSensitive;
  const ResponseMatcher(
      {required this.mode, required this.pattern, this.caseSensitive = false});

  ResponseMatcher copyWith(
          {MatchMode? mode, String? pattern, bool? caseSensitive}) =>
      ResponseMatcher(
          mode: mode ?? this.mode,
          pattern: pattern ?? this.pattern,
          caseSensitive: caseSensitive ?? this.caseSensitive);
  @override
  bool operator ==(Object other) =>
      other is ResponseMatcher &&
      mode == other.mode &&
      pattern == other.pattern &&
      caseSensitive == other.caseSensitive;
  @override
  int get hashCode => Object.hash(mode, pattern, caseSensitive);
}

class ResponseEffect {
  final ResponseField field;
  final ValueSource source;
  final String? captureNameOrIndex;
  final String? fixedValue;
  final List<Normalizer> normalizers;
  const ResponseEffect({
    required this.field,
    required this.source,
    this.captureNameOrIndex,
    this.fixedValue,
    this.normalizers = const [Normalizer.trim],
  });

  ResponseEffect copyWith(
          {ResponseField? field,
          ValueSource? source,
          String? captureNameOrIndex,
          String? fixedValue,
          List<Normalizer>? normalizers}) =>
      ResponseEffect(
          field: field ?? this.field,
          source: source ?? this.source,
          captureNameOrIndex: captureNameOrIndex ?? this.captureNameOrIndex,
          fixedValue: fixedValue ?? this.fixedValue,
          normalizers: normalizers ?? this.normalizers);
  @override
  bool operator ==(Object other) =>
      other is ResponseEffect &&
      field == other.field &&
      source == other.source &&
      captureNameOrIndex == other.captureNameOrIndex &&
      fixedValue == other.fixedValue &&
      _listEquals(normalizers, other.normalizers);
  @override
  int get hashCode => Object.hash(field, source, captureNameOrIndex, fixedValue,
      Object.hashAll(normalizers));
}

class ResponseRule {
  final String id;
  final String name;
  final bool enabled;
  final int priority;
  final ResponseChannel channel;
  final ResponseMatcher matcher;
  final List<ResponseEffect> effects;
  final SemanticOutcome? outcome;
  const ResponseRule(
      {required this.id,
      required this.name,
      this.enabled = true,
      required this.priority,
      required this.channel,
      required this.matcher,
      this.effects = const [],
      this.outcome});

  ResponseRule copyWith(
          {String? id,
          String? name,
          bool? enabled,
          int? priority,
          ResponseChannel? channel,
          ResponseMatcher? matcher,
          List<ResponseEffect>? effects,
          SemanticOutcome? outcome,
          bool clearOutcome = false}) =>
      ResponseRule(
          id: id ?? this.id,
          name: name ?? this.name,
          enabled: enabled ?? this.enabled,
          priority: priority ?? this.priority,
          channel: channel ?? this.channel,
          matcher: matcher ?? this.matcher,
          effects: effects ?? this.effects,
          outcome: clearOutcome ? null : outcome ?? this.outcome);
  @override
  bool operator ==(Object other) =>
      other is ResponseRule &&
      id == other.id &&
      name == other.name &&
      enabled == other.enabled &&
      priority == other.priority &&
      channel == other.channel &&
      matcher == other.matcher &&
      _listEquals(effects, other.effects) &&
      outcome == other.outcome;
  @override
  int get hashCode => Object.hash(id, name, enabled, priority, channel, matcher,
      Object.hashAll(effects), outcome);
}

class CommandSet {
  final String id;
  final String name;
  final String operatorName;
  final String countryCode;
  final String countryName;
  final String? region;
  final CommandSetKind kind;
  final List<OperatorCommand> commands;
  final List<ResponseRule> responseRules;
  final List<String> usedByPlanIds;

  const CommandSet(
      {required this.id,
      required this.name,
      required this.operatorName,
      required this.countryCode,
      required this.countryName,
      this.region,
      this.kind = CommandSetKind.operator,
      this.commands = const [],
      this.responseRules = const [],
      this.usedByPlanIds = const []});

  CommandSet copyWith(
          {String? id,
          String? name,
          String? operatorName,
          String? countryCode,
          String? countryName,
          String? region,
          bool clearRegion = false,
          CommandSetKind? kind,
          List<OperatorCommand>? commands,
          List<ResponseRule>? responseRules,
          List<String>? usedByPlanIds}) =>
      CommandSet(
          id: id ?? this.id,
          name: name ?? this.name,
          operatorName: operatorName ?? this.operatorName,
          countryCode: countryCode ?? this.countryCode,
          countryName: countryName ?? this.countryName,
          region: clearRegion ? null : region ?? this.region,
          kind: kind ?? this.kind,
          commands: commands ?? this.commands,
          responseRules: responseRules ?? this.responseRules,
          usedByPlanIds: usedByPlanIds ?? this.usedByPlanIds);

  bool get isSystem => kind == CommandSetKind.systemFallback;
  @override
  bool operator ==(Object other) =>
      other is CommandSet &&
      id == other.id &&
      name == other.name &&
      operatorName == other.operatorName &&
      countryCode == other.countryCode &&
      countryName == other.countryName &&
      region == other.region &&
      kind == other.kind &&
      _listEquals(commands, other.commands) &&
      _listEquals(responseRules, other.responseRules) &&
      _listEquals(usedByPlanIds, other.usedByPlanIds);
  @override
  int get hashCode => Object.hash(
      id,
      name,
      operatorName,
      countryCode,
      countryName,
      region,
      kind,
      Object.hashAll(commands),
      Object.hashAll(responseRules),
      Object.hashAll(usedByPlanIds));
}

class CommandSetDraft {
  final CommandSet baseline;
  final CommandSet working;
  const CommandSetDraft(this.baseline, this.working);
  bool get isDirty => baseline != working;
  CommandSetDraft update(CommandSet value) => CommandSetDraft(baseline, value);
}
