import 'package:flutter/foundation.dart';
import 'models.dart';
import 'repository.dart';

enum PlanLoadState { loading, ready, error }

class PlanDeleteImpact {
  final bool allowed;
  final String message;
  const PlanDeleteImpact(this.allowed, this.message);
}

class PlanDraft {
  final Plan saved;
  Plan working;
  PlanDraft(this.saved) : working = saved;
  bool get isDirty => working != saved;
}

class PlanController extends ChangeNotifier {
  final PlanRepository repository;
  final int Function(String planId) usageCount;
  PlanLoadState loadState = PlanLoadState.loading;
  String? errorMessage;
  String? selectedId;
  String query = '';
  String? commandSetFilter;
  bool explanationOpen = true;
  PlanDraft? draft;
  String? pendingSelectionId;

  PlanController(this.repository, {required this.usageCount});

  void load() {
    loadState = PlanLoadState.ready;
    selectedId ??= repository.records.firstOrNull?.id;
    notifyListeners();
  }

  List<Plan> get records => repository.records;

  Plan? get selected =>
      draft?.working ??
      (selectedId == null ? null : repository.byId(selectedId!));

  bool get isDirty => draft?.isDirty ?? false;

  List<Plan> get visiblePlans {
    final q = query.trim().toLowerCase();
    final filterId = commandSetFilter;
    return records.where((p) {
      final setOk = filterId == null || p.commandSetId == filterId;
      final queryOk = q.isEmpty ||
          [p.id, p.commandSetId].join(' ').toLowerCase().contains(q);
      return setOk && queryOk;
    }).toList();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setCommandSetFilter(String? id) {
    commandSetFilter = id;
    notifyListeners();
  }

  void toggleExplanation() {
    explanationOpen = !explanationOpen;
    notifyListeners();
  }

  bool requestSelectPlan(String id) {
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
    notifyListeners();
  }

  void _update(Plan value) {
    final current = selected;
    if (current == null) return;
    draft ??= PlanDraft(current);
    draft!.working = value;
    notifyListeners();
  }

  void updateIdentity(
      {String? commandSetId,
      int? priority,
      String? proTag,
      bool clearProTag = false}) {
    final current = selected;
    if (current == null) return;
    _update(current.copyWith(
      commandSetId: commandSetId,
      priority: priority,
      proTag: proTag,
      clearProTag: clearProTag,
    ));
  }

  void updateCapacity({int? onlineMax, int? addMax}) {
    final current = selected;
    if (current == null) return;
    _update(current.copyWith(onlineMax: onlineMax, addMax: addMax));
  }

  void updateCallModes({
    bool? canIn,
    bool? canOut,
    bool? canSout,
    bool? notVip,
    Set<String>? qualityFlags,
    bool? capOk,
    bool? capNew,
    bool? capFail,
  }) {
    final current = selected;
    if (current == null) return;
    _update(current.copyWith(
      canIn: canIn,
      canOut: canOut,
      canSout: canSout,
      notVip: notVip,
      qualityFlags: qualityFlags,
      capOk: capOk,
      capNew: capNew,
      capFail: capFail,
    ));
  }

  void updateTiming({
    int? diffSlow,
    int? diffMin,
    int? diffMinOut,
    int? timeWake,
    bool clearTimeWake = false,
    int? timeSleep,
    bool clearTimeSleep = false,
    int? timeWorkWake,
    bool clearTimeWorkWake = false,
    int? timeWorkSleep,
    bool clearTimeWorkSleep = false,
    int? timeHolidayWake,
    bool clearTimeHolidayWake = false,
    int? timeHolidaySleep,
    bool clearTimeHolidaySleep = false,
  }) {
    final current = selected;
    if (current == null) return;
    _update(current.copyWith(
      diffSlow: diffSlow,
      diffMin: diffMin,
      diffMinOut: diffMinOut,
      timeWake: timeWake,
      clearTimeWake: clearTimeWake,
      timeSleep: timeSleep,
      clearTimeSleep: clearTimeSleep,
      timeWorkWake: timeWorkWake,
      clearTimeWorkWake: clearTimeWorkWake,
      timeWorkSleep: timeWorkSleep,
      clearTimeWorkSleep: clearTimeWorkSleep,
      timeHolidayWake: timeHolidayWake,
      clearTimeHolidayWake: clearTimeHolidayWake,
      timeHolidaySleep: timeHolidaySleep,
      clearTimeHolidaySleep: clearTimeHolidaySleep,
    ));
  }

  /// [slot] must be 1-4 (the editable directions); 0 and 5 are compatibility-only
  /// and silently ignored, matching Specifications' edge-case table.
  void updateDirectionSlot(int slot,
      {int? alg, bool? nodiff, int? limitSoft, int? limitHard}) {
    if (slot < 1 || slot > 4) return;
    final current = selected;
    if (current == null) return;
    final index = current.directions.indexWhere((d) => d.slot == slot);
    if (index < 0) return;
    final slots = List<DirectionSlot>.of(current.directions);
    slots[index] = slots[index].copyWith(
        alg: alg, nodiff: nodiff, limitSoft: limitSoft, limitHard: limitHard);
    _update(current.copyWith(directions: slots));
  }

  void updateIncomingGeneration({
    int? iattMin,
    int? iattMax,
    int? iattSoft,
    int? inAcdMin,
    int? inAcdMax,
    int? outAcdMin,
    int? outAcdMax,
    bool? forwarding,
    int? outInAns,
    bool? conn,
    bool? rand,
    bool? inWait,
    bool? inSound,
  }) {
    final current = selected;
    if (current == null) return;
    _update(current.copyWith(
      iattMin: iattMin,
      iattMax: iattMax,
      iattSoft: iattSoft,
      inAcdMin: inAcdMin,
      inAcdMax: inAcdMax,
      outAcdMin: outAcdMin,
      outAcdMax: outAcdMax,
      forwarding: forwarding,
      outInAns: outInAns,
      conn: conn,
      rand: rand,
      inWait: inWait,
      inSound: inSound,
    ));
  }

  void updateSmsGeneration({
    int? mayLimit,
    int? monLimit,
    int? msmLimit,
    int? smsoutSoft,
    int? smsoutHard,
    int? sattSoft,
    int? sattHard,
    int? sattSoftDay,
    int? sattHardDay,
    int? sattSoftTotal,
    int? sattHardTotal,
    int? nospam,
  }) {
    final current = selected;
    if (current == null) return;
    _update(current.copyWith(
      mayLimit: mayLimit,
      monLimit: monLimit,
      msmLimit: msmLimit,
      smsoutSoft: smsoutSoft,
      smsoutHard: smsoutHard,
      sattSoft: sattSoft,
      sattHard: sattHard,
      sattSoftDay: sattSoftDay,
      sattHardDay: sattHardDay,
      sattSoftTotal: sattSoftTotal,
      sattHardTotal: sattHardTotal,
      nospam: nospam,
    ));
  }

  void cancelDraft() {
    draft = null;
    notifyListeners();
  }

  void save() {
    final d = draft;
    if (d == null) return;
    repository.replace(d.saved.id, d.working);
    draft = null;
    notifyListeners();
  }

  void createPlan(String id, String commandSetId, {String? cloneFromId}) {
    final source = cloneFromId == null ? null : repository.byId(cloneFromId);
    final record = source != null
        ? Plan(
            id: id,
            commandSetId: commandSetId,
            priority: source.priority,
            proTag: source.proTag,
            onlineMax: source.onlineMax,
            addMax: source.addMax,
            canIn: source.canIn,
            canOut: source.canOut,
            canSout: source.canSout,
            notVip: source.notVip,
            qualityFlags: source.qualityFlags,
            capOk: source.capOk,
            capNew: source.capNew,
            capFail: source.capFail,
            diffSlow: source.diffSlow,
            diffMin: source.diffMin,
            diffMinOut: source.diffMinOut,
            timeWake: source.timeWake,
            timeSleep: source.timeSleep,
            timeWorkWake: source.timeWorkWake,
            timeWorkSleep: source.timeWorkSleep,
            timeHolidayWake: source.timeHolidayWake,
            timeHolidaySleep: source.timeHolidaySleep,
            directions: source.directions,
            iattMin: source.iattMin,
            iattMax: source.iattMax,
            iattSoft: source.iattSoft,
            inAcdMin: source.inAcdMin,
            inAcdMax: source.inAcdMax,
            outAcdMin: source.outAcdMin,
            outAcdMax: source.outAcdMax,
            forwarding: source.forwarding,
            outInAns: source.outInAns,
            conn: source.conn,
            rand: source.rand,
            inWait: source.inWait,
            inSound: source.inSound,
            mayLimit: source.mayLimit,
            monLimit: source.monLimit,
            msmLimit: source.msmLimit,
            smsoutSoft: source.smsoutSoft,
            smsoutHard: source.smsoutHard,
            sattSoft: source.sattSoft,
            sattHard: source.sattHard,
            sattSoftDay: source.sattSoftDay,
            sattHardDay: source.sattHardDay,
            sattSoftTotal: source.sattSoftTotal,
            sattHardTotal: source.sattHardTotal,
            nospam: source.nospam,
          )
        : Plan(
            id: id,
            commandSetId: commandSetId,
            directions: [
              for (var n = 0; n < 6; n++)
                DirectionSlot(
                  slot: n,
                  editable: n >= 1 && n <= 4,
                  alg: 0,
                  nodiff: false,
                  limitSoft: 0,
                  limitHard: 0,
                ),
            ],
          );
    repository.create(record);
    _selectImmediately(id);
  }

  PlanDeleteImpact inspectDelete(String id) {
    if (id == 'default') {
      return const PlanDeleteImpact(false, 'План default защищён от удаления.');
    }
    final count = usageCount(id);
    if (count > 0) {
      return PlanDeleteImpact(false,
          'План «$id» используется $count симками. Переназначьте эти симки на другой план, прежде чем удалять «$id».');
    }
    return PlanDeleteImpact(true, '«$id» не используется ни одной симкой.');
  }

  void deletePlan(String id) {
    repository.delete(id);
    if (selectedId == id) {
      selectedId = repository.records.firstOrNull?.id;
      draft = null;
    }
    notifyListeners();
  }

  void resetDemo() {
    repository.reset();
    selectedId = repository.records.firstOrNull?.id;
    draft = null;
    notifyListeners();
  }
}
