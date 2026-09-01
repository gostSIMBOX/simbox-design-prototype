import 'models.dart';

class CommandSetRepositoryException implements Exception {
  final String message;
  const CommandSetRepositoryException(this.message);
  @override
  String toString() => message;
}

abstract interface class CommandSetRepository {
  List<CommandSet> get records;
  CommandSet? byId(String id);
  void create(CommandSet record);
  void replace(String id, CommandSet record);
  void delete(String id);
  void reset();
}

class InMemoryCommandSetRepository implements CommandSetRepository {
  final List<CommandSet> _seed;
  late List<CommandSet> _records;

  InMemoryCommandSetRepository(Iterable<CommandSet> seed)
      : _seed = List.unmodifiable(seed) {
    _records = List.of(_seed);
  }

  @override
  List<CommandSet> get records => List.unmodifiable(_records);

  @override
  CommandSet? byId(String id) {
    for (final record in _records) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  void create(CommandSet record) {
    if (byId(record.id) != null) {
      throw CommandSetRepositoryException('Набор ${record.id} уже существует.');
    }
    _records = [..._records, record];
  }

  @override
  void replace(String id, CommandSet record) {
    final index = _records.indexWhere((item) => item.id == id);
    if (index < 0) throw CommandSetRepositoryException('Набор $id не найден.');
    if (record.id != id) {
      throw const CommandSetRepositoryException(
          'ID существующего набора нельзя изменить.');
    }
    final next = List<CommandSet>.of(_records);
    next[index] = record;
    _records = next;
  }

  @override
  void delete(String id) {
    final record = byId(id);
    if (record == null) {
      throw CommandSetRepositoryException('Набор $id не найден.');
    }
    if (record.isSystem) {
      throw const CommandSetRepositoryException(
          'Системный набор нельзя удалить.');
    }
    if (record.usedByPlanIds.isNotEmpty) {
      throw const CommandSetRepositoryException(
          'Сначала переназначьте использующие набор планы.');
    }
    _records = _records.where((item) => item.id != id).toList();
  }

  @override
  void reset() => _records = List.of(_seed);
}
