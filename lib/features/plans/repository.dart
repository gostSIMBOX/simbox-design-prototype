import 'models.dart';

class PlanRepositoryException implements Exception {
  final String message;
  const PlanRepositoryException(this.message);
  @override
  String toString() => message;
}

abstract interface class PlanRepository {
  List<Plan> get records;
  Plan? byId(String id);
  void create(Plan record);
  void replace(String id, Plan record);
  void delete(String id);
  void reset();
}

/// [liveSims] is read at delete time (not captured once) so the referenced-
/// by-SIM guard always reflects the current mock data, not a stale snapshot.
class InMemoryPlanRepository implements PlanRepository {
  final List<Plan> _seed;
  late List<Plan> _records;
  final List<String> Function() liveSimPlanIds;

  InMemoryPlanRepository(Iterable<Plan> seed, {required this.liveSimPlanIds})
      : _seed = List.unmodifiable(seed) {
    _records = List.of(_seed);
  }

  @override
  List<Plan> get records => List.unmodifiable(_records);

  @override
  Plan? byId(String id) {
    for (final record in _records) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  void create(Plan record) {
    if (byId(record.id) != null) {
      throw PlanRepositoryException('План ${record.id} уже существует.');
    }
    _records = [..._records, record];
  }

  @override
  void replace(String id, Plan record) {
    final index = _records.indexWhere((item) => item.id == id);
    if (index < 0) throw PlanRepositoryException('План $id не найден.');
    if (record.id != id) {
      throw const PlanRepositoryException('ID существующего плана нельзя изменить.');
    }
    final next = List<Plan>.of(_records);
    next[index] = record;
    _records = next;
  }

  @override
  void delete(String id) {
    if (byId(id) == null) {
      throw PlanRepositoryException('План $id не найден.');
    }
    if (id == 'default') {
      throw const PlanRepositoryException('План default защищён от удаления.');
    }
    final usageCount = liveSimPlanIds().where((planId) => planId == id).length;
    if (usageCount > 0) {
      throw PlanRepositoryException('План $id используется $usageCount симками.');
    }
    _records = _records.where((item) => item.id != id).toList();
  }

  @override
  void reset() => _records = List.of(_seed);
}
