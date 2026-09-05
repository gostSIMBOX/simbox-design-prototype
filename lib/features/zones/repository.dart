import 'models.dart';

class ZoneRepositoryException implements Exception {
  final String message;
  const ZoneRepositoryException(this.message);
  @override
  String toString() => message;
}

abstract interface class ZoneRepository {
  List<Zone> get records;
  Zone? byId(String id);
  void create(Zone record);
  void replace(String id, Zone record);
  void delete(String id);
  void reset();
}

class InMemoryZoneRepository implements ZoneRepository {
  final List<Zone> _seed;
  late List<Zone> _records;

  InMemoryZoneRepository(Iterable<Zone> seed)
      : _seed = List.unmodifiable(seed) {
    _records = List.of(_seed);
  }

  @override
  List<Zone> get records => List.unmodifiable(_records);

  @override
  Zone? byId(String id) {
    for (final record in _records) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  void create(Zone record) {
    if (byId(record.id) != null) {
      throw ZoneRepositoryException('Направление ${record.id} уже существует.');
    }
    _records = [..._records, record];
  }

  @override
  void replace(String id, Zone record) {
    final index = _records.indexWhere((item) => item.id == id);
    if (index < 0) throw ZoneRepositoryException('Направление $id не найдено.');
    if (record.id != id) {
      throw const ZoneRepositoryException(
          'ID существующего направления нельзя изменить.');
    }
    final next = List<Zone>.of(_records);
    next[index] = record;
    _records = next;
  }

  @override
  void delete(String id) {
    if (byId(id) == null) {
      throw ZoneRepositoryException('Направление $id не найдено.');
    }
    _records = _records.where((item) => item.id != id).toList();
  }

  @override
  void reset() => _records = List.of(_seed);
}
