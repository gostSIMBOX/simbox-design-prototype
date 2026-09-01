import 'package:flutter/foundation.dart';
import 'models.dart';
import 'repository.dart';

enum ZoneLoadState { loading, ready, error }

class ZoneDraft {
  final Zone saved;
  Zone working;
  ZoneDraft(this.saved) : working = saved;
  bool get isDirty => working != saved;
}

List<String> parseCodeLines(String text) =>
    text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

class ZoneController extends ChangeNotifier {
  final ZoneRepository repository;
  ZoneLoadState loadState = ZoneLoadState.loading;
  String? errorMessage;
  String? selectedId;
  String query = '';
  ZoneDraft? draft;
  String? pendingSelectionId;

  ZoneController(this.repository);

  void load() {
    loadState = ZoneLoadState.ready;
    selectedId ??= repository.records.firstOrNull?.id;
    notifyListeners();
  }

  List<Zone> get records => repository.records;

  Zone? get selected =>
      draft?.working ?? (selectedId == null ? null : repository.byId(selectedId!));

  bool get isDirty => draft?.isDirty ?? false;

  List<Zone> get visibleZones {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return records;
    return records
        .where((z) => [z.id, z.name, z.region ?? ''].join(' ').toLowerCase().contains(q))
        .toList();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  bool requestSelectZone(String id) {
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

  /// Called on every textarea change — cheap even at 1,550 lines (split +
  /// trim + filter), no debounce needed for this prototype.
  void updateCodesText(String text) {
    final current = selected;
    if (current == null) return;
    draft ??= ZoneDraft(current);
    draft!.working = draft!.working.copyWith(defCodes: parseCodeLines(text));
    notifyListeners();
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

  void createZone(String id, String name, String? region) {
    repository.create(Zone(
      id: id,
      name: name,
      region: region,
      icon: 'napravleine/hz.png',
      defCodes: const [],
    ));
    _selectImmediately(id);
  }

  void renameZone(String id, String name, String? region) {
    final current = repository.byId(id);
    if (current == null) return;
    repository.replace(id, current.copyWith(name: name, region: region));
    notifyListeners();
  }

  void deleteZone(String id) {
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
