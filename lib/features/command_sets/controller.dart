import 'package:flutter/foundation.dart';
import 'models.dart';
import 'repository.dart';
import 'response_preview.dart';
import 'validation.dart';

enum CommandSetLoadState { loading, ready, error }

class DeleteImpact {
  final bool allowed;
  final String message;
  final List<String> planIds;
  const DeleteImpact(this.allowed, this.message, [this.planIds = const []]);
}

class CommandSetController extends ChangeNotifier {
  final CommandSetRepository repository;
  CommandSetLoadState loadState = CommandSetLoadState.loading;
  String? errorMessage;
  String? selectedId;
  CommandSetSection section = CommandSetSection.commands;
  String setQuery = '';
  String commandQuery = '';
  String ruleQuery = '';
  ResponseChannel? channelFilter;
  CommandSetDraft? draft;
  String? selectedCommandId;
  String? pendingSelectionId;
  int _serial = 0;

  CommandSetController(this.repository);

  void load() {
    loadState = CommandSetLoadState.ready;
    selectedId ??= repository.records.firstOrNull?.id;
    _ensureCommandSelection();
    notifyListeners();
  }

  List<CommandSet> get records => repository.records;
  CommandSet? get selected =>
      draft?.working ??
      (selectedId == null ? null : repository.byId(selectedId!));
  bool get isDirty => draft?.isDirty ?? false;
  List<String> get selectableIds =>
      repository.records.map((item) => item.id).toList();

  List<CommandSet> get visibleSets {
    final query = setQuery.trim().toLowerCase();
    if (query.isEmpty) return records;
    return records
        .where((item) => [
              item.id,
              item.name,
              item.operatorName,
              item.countryName,
              item.region ?? '',
            ].join(' ').toLowerCase().contains(query))
        .toList();
  }

  List<OperatorCommand> get visibleCommands {
    final query = commandQuery.trim().toLowerCase();
    final list = selected?.commands ?? const <OperatorCommand>[];
    if (query.isEmpty) return list;
    return list
        .where(
            (item) => '${item.name} ${item.id}'.toLowerCase().contains(query))
        .toList();
  }

  List<ResponseRule> get visibleRules {
    final query = ruleQuery.trim().toLowerCase();
    return (selected?.responseRules ?? const <ResponseRule>[]).where((item) {
      final channelOk = channelFilter == null || item.channel == channelFilter;
      final queryOk = query.isEmpty ||
          '${item.name} ${item.matcher.pattern}'.toLowerCase().contains(query);
      return channelOk && queryOk;
    }).toList();
  }

  OperatorCommand? get selectedCommand {
    final commands = selected?.commands ?? const <OperatorCommand>[];
    for (final command in commands) {
      if (command.id == selectedCommandId) return command;
    }
    return commands.firstOrNull;
  }

  bool requestSelectSet(String id) {
    if (id == selectedId) return true;
    if (isDirty) {
      pendingSelectionId = id;
      notifyListeners();
      return false;
    }
    _selectImmediately(id);
    return true;
  }

  void keepEditing() {
    pendingSelectionId = null;
    notifyListeners();
  }

  void discardAndContinue() {
    final target = pendingSelectionId;
    draft = null;
    pendingSelectionId = null;
    if (target != null) {
      _selectImmediately(target);
    } else {
      notifyListeners();
    }
  }

  void _selectImmediately(String id) {
    selectedId = id;
    draft = null;
    pendingSelectionId = null;
    section = CommandSetSection.commands;
    _ensureCommandSelection();
    notifyListeners();
  }

  void selectSection(CommandSetSection value) {
    section = value;
    notifyListeners();
  }

  void selectCommand(String id) {
    selectedCommandId = id;
    notifyListeners();
  }

  void setSetQuery(String value) {
    setQuery = value;
    notifyListeners();
  }

  void setCommandQuery(String value) {
    commandQuery = value;
    notifyListeners();
  }

  void setRuleQuery(String value) {
    ruleQuery = value;
    notifyListeners();
  }

  void setChannelFilter(ResponseChannel? value) {
    channelFilter = value;
    notifyListeners();
  }

  void updateMetadata(
      {required String name,
      required String operatorName,
      required String countryCode,
      required String countryName,
      String? region}) {
    final value = selected;
    if (value == null || value.isSystem) return;
    _update(value.copyWith(
        name: name,
        operatorName: operatorName,
        countryCode: countryCode,
        countryName: countryName,
        region: region,
        clearRegion: region == null || region.isEmpty));
  }

  void addCommand(CommandPurpose purpose) {
    final value = selected;
    if (value == null || value.isSystem) return;
    final base = _purposeKey(purpose);
    final id = _uniqueId(base, value.commands.map((item) => item.id));
    final operation =
        UssdDialogOperation('${id}_ussd', start: const UssdStart(''));
    final next = OperatorCommand(
        id: id, purpose: purpose, name: purpose.label, operations: [operation]);
    _update(value.copyWith(commands: [...value.commands, next]));
    selectedCommandId = id;
  }

  void updateCommand(OperatorCommand command) {
    final value = selected;
    if (value == null) return;
    _update(value.copyWith(commands: [
      for (final item in value.commands)
        if (item.id == command.id) command else item,
    ]));
  }

  void duplicateCommand(String id) {
    final value = selected;
    if (value == null || value.isSystem) return;
    final source = value.commands.singleWhere((item) => item.id == id);
    final nextId =
        _uniqueId('${source.id}_copy', value.commands.map((item) => item.id));
    final copy = source
        .copyWith(id: nextId, name: '${source.name} — копия', operations: [
      for (final operation in source.operations)
        operation.copyWithId('${operation.id}_copy'),
    ]);
    _update(value.copyWith(commands: [...value.commands, copy]));
    selectedCommandId = nextId;
  }

  void deleteCommand(String id) {
    final value = selected;
    if (value == null || value.isSystem) return;
    _update(value.copyWith(
        commands: value.commands.where((item) => item.id != id).toList()));
    _ensureCommandSelection();
  }

  void reorderCommand(int from, int to) {
    final value = selected;
    if (value == null ||
        from == to ||
        from < 0 ||
        to < 0 ||
        from >= value.commands.length ||
        to >= value.commands.length) {
      return;
    }
    final commands = List<OperatorCommand>.of(value.commands);
    final item = commands.removeAt(from);
    commands.insert(to, item);
    _update(value.copyWith(commands: commands));
  }

  void addRule() {
    final value = selected;
    if (value == null || value.isSystem) return;
    final id =
        _uniqueId('response_rule', value.responseRules.map((item) => item.id));
    final rule = ResponseRule(
        id: id,
        name: 'Новое правило',
        priority: value.responseRules.length,
        channel: ResponseChannel.ussd,
        matcher: const ResponseMatcher(mode: MatchMode.contains, pattern: ''),
        effects: const [
          ResponseEffect(
              field: ResponseField.balance, source: ValueSource.fullMatch)
        ]);
    _update(value.copyWith(responseRules: [...value.responseRules, rule]));
  }

  void updateRule(ResponseRule rule) {
    final value = selected;
    if (value == null) return;
    final exists = value.responseRules.any((item) => item.id == rule.id);
    _update(value.copyWith(responseRules: [
      for (final item in value.responseRules)
        if (item.id == rule.id) rule else item,
      if (!exists) rule,
    ]));
  }

  void duplicateRule(String id) {
    final value = selected;
    if (value == null || value.isSystem) return;
    final source = value.responseRules.singleWhere((item) => item.id == id);
    final nextId = _uniqueId(
        '${source.id}_copy', value.responseRules.map((item) => item.id));
    final copy = source.copyWith(
        id: nextId,
        name: '${source.name} — копия',
        priority: value.responseRules.length);
    _update(value.copyWith(responseRules: [...value.responseRules, copy]));
  }

  void deleteRule(String id) {
    final value = selected;
    if (value == null || value.isSystem) return;
    final next = value.responseRules.where((item) => item.id != id).toList();
    _update(value.copyWith(responseRules: [
      for (var i = 0; i < next.length; i++) next[i].copyWith(priority: i)
    ]));
  }

  void reorderRule(int from, int to) {
    final value = selected;
    if (value == null ||
        from == to ||
        from < 0 ||
        to < 0 ||
        from >= value.responseRules.length ||
        to >= value.responseRules.length) {
      return;
    }
    final rules = List<ResponseRule>.of(value.responseRules);
    final item = rules.removeAt(from);
    rules.insert(to, item);
    _update(value.copyWith(responseRules: [
      for (var i = 0; i < rules.length; i++) rules[i].copyWith(priority: i)
    ]));
  }

  ResponsePreview testRule(String id, String sample) {
    final rule = selected!.responseRules.singleWhere((item) => item.id == id);
    return previewResponse(rule, sample);
  }

  ValidationResult save() {
    final value = draft?.working;
    if (value == null) return const ValidationResult([]);
    final result = validateCommandSet(value,
        otherIds: repository.records
            .where((item) => item.id != value.id)
            .map((item) => item.id));
    if (!result.isValid) return result;
    repository.replace(value.id, value);
    draft = null;
    notifyListeners();
    return result;
  }

  void cancelDraft() {
    draft = null;
    _ensureCommandSelection();
    notifyListeners();
  }

  ValidationResult createBlank(
      {required String id,
      required String name,
      required String operator,
      required String countryCode,
      required String countryName,
      String? region}) {
    final value = CommandSet(
        id: id,
        name: name,
        operatorName: operator,
        countryCode: countryCode,
        countryName: countryName,
        region: region);
    return _create(value);
  }

  ValidationResult cloneSet(String sourceId,
      {required String id,
      required String name,
      required String operator,
      required String countryCode,
      required String countryName,
      String? region}) {
    final source = repository.byId(sourceId)!;
    return _create(source.copyWith(
        id: id,
        name: name,
        operatorName: operator,
        countryCode: countryCode,
        countryName: countryName,
        region: region,
        clearRegion: region == null || region.isEmpty,
        kind: CommandSetKind.operator,
        usedByPlanIds: const []));
  }

  ValidationResult _create(CommandSet value) {
    final result = validateCommandSet(value,
        otherIds: repository.records.map((item) => item.id));
    if (!result.isValid) return result;
    repository.create(value);
    selectedId = value.id;
    section = CommandSetSection.commands;
    draft = null;
    _ensureCommandSelection();
    notifyListeners();
    return result;
  }

  DeleteImpact inspectDelete(String id) {
    final value = repository.byId(id)!;
    if (value.isSystem) {
      return const DeleteImpact(false, 'Системный набор защищён.');
    }
    if (value.usedByPlanIds.isNotEmpty) {
      return DeleteImpact(
          false,
          'Сначала переназначьте использующие набор планы.',
          value.usedByPlanIds);
    }
    return const DeleteImpact(
        true, 'Удаление нельзя отменить до сброса демо-данных.');
  }

  void confirmDelete(String id) {
    final index = repository.records.indexWhere((item) => item.id == id);
    repository.delete(id);
    final records = repository.records;
    selectedId =
        records.isEmpty ? null : records[index.clamp(0, records.length - 1)].id;
    draft = null;
    _ensureCommandSelection();
    notifyListeners();
  }

  void resetDemo() {
    repository.reset();
    selectedId = repository.records.first.id;
    draft = null;
    section = CommandSetSection.commands;
    _ensureCommandSelection();
    notifyListeners();
  }

  void _update(CommandSet value) {
    final baseline = draft?.baseline ?? repository.byId(value.id)!;
    draft = CommandSetDraft(baseline, value);
    notifyListeners();
  }

  void _ensureCommandSelection() {
    final commands = selected?.commands ?? const <OperatorCommand>[];
    if (commands.every((item) => item.id != selectedCommandId)) {
      selectedCommandId = commands.firstOrNull?.id;
    }
  }

  String _uniqueId(String base, Iterable<String> used) {
    final set = used.toSet();
    if (!set.contains(base)) return base;
    do {
      _serial++;
    } while (set.contains('${base}_$_serial'));
    return '${base}_$_serial';
  }

  String _purposeKey(CommandPurpose purpose) => switch (purpose) {
        CommandPurpose.activateSim => 'activate_sim',
        CommandPurpose.activateWork => 'activate_work',
        CommandPurpose.getBalance => 'get_balance',
        CommandPurpose.getNumber => 'get_number',
        CommandPurpose.getTariff => 'get_tariff',
        CommandPurpose.getMinutes => 'get_minutes',
        CommandPurpose.getOptions => 'get_options',
        CommandPurpose.getPromisePayment => 'get_promise_payment',
        CommandPurpose.initializeTariff => 'initialize_tariff',
        CommandPurpose.sendMay => 'send_may',
        CommandPurpose.sendMon => 'send_mon',
        CommandPurpose.enterPin => 'enter_pin',
        CommandPurpose.disableService => 'disable_service',
        CommandPurpose.operatorService => 'operator_service',
      };
}
