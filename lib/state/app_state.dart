import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/mock.dart';

enum AdmPage { sim, dongle, diagmode, hubs, nabor, plan, proc, bablo, upgrade, debug, icons }

class Toast {
  final String text, icon;
  const Toast(this.text, this.icon);
}

/// Single source of truth for the panel. Replace the `_exec` body with real
/// transport (ssh / http) to drive live hardware — see TODO(api).
class AppState extends ChangeNotifier {
  AdmPage page = AdmPage.sim;
  final Set<int> selected = <int>{};
  String? sortKey;
  int sortDir = 1;
  String query = '';

  bool navCompact = false;
  String? activeGroup;
  String? railSubAction;
  bool columnsOpen = false;
  final Map<AdmPage, List<String>> columnOrder = {};
  final Map<AdmPage, Set<String>> hiddenColumns = {};

  final List<LogEntry> logs = [];
  bool logOpen = true;

  bool queueMode = false;
  bool liveRefresh = true;

  DateTime now = DateTime.now();
  final Map<int, int> powerOverride = {};
  final Map<int, int> pauseOverride = {};
  final Map<int, int> flashProgress = {4: 62, 6: 100};

  final Map<String, bool> planShow = {
    'modes': true,
    'timings': true,
    'sched': true,
    'fwd': true,
    'gin': true,
    'gsms': true,
    'napr': true,
  };

  final ValueNotifier<Toast?> toast = ValueNotifier(null);

  Timer? _timer;

  AppState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
      if (liveRefresh && page == AdmPage.diagmode) {
        flashProgress[4] = (flashProgress[4]! + 3).clamp(0, 100);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    toast.dispose();
    super.dispose();
  }

  // ---- navigation ----------------------------------------------------------

  void goTo(AdmPage p) {
    page = p;
    selected.clear();
    sortKey = null;
    query = '';
    activeGroup = null;
    railSubAction = null;
    columnsOpen = false;
    notifyListeners();
  }

  void toggleNav() {
    navCompact = !navCompact;
    notifyListeners();
  }

  void toggleGroup(String key, [List<String>? subActionKeys]) {
    if (activeGroup == key) {
      activeGroup = null;
      railSubAction = null;
    } else {
      activeGroup = key;
      columnsOpen = false;
      railSubAction = (subActionKeys != null && subActionKeys.isNotEmpty)
          ? subActionKeys.first
          : null;
    }
    notifyListeners();
  }

  void selectSubAction(String key) {
    railSubAction = key;
    notifyListeners();
  }

  void toggleColumns() {
    columnsOpen = !columnsOpen;
    if (columnsOpen) {
      activeGroup = null;
      railSubAction = null;
    }
    notifyListeners();
  }

  List<String> columnOrderFor(AdmPage p, List<String> defaultIds) =>
      columnOrder.putIfAbsent(p, () => List.of(defaultIds));

  Set<String> hiddenColumnsFor(AdmPage p) => hiddenColumns.putIfAbsent(p, () => <String>{});

  void toggleColumnHidden(AdmPage p, String colId) {
    final hidden = hiddenColumnsFor(p);
    hidden.contains(colId) ? hidden.remove(colId) : hidden.add(colId);
    notifyListeners();
  }

  void moveColumn(AdmPage p, String colId, int direction, List<String> defaultIds) {
    final order = columnOrderFor(p, defaultIds);
    final i = order.indexOf(colId);
    final n = i + direction;
    if (i < 0 || n < 0 || n >= order.length) return;
    order.removeAt(i);
    order.insert(n, colId);
    notifyListeners();
  }

  void resetColumns(AdmPage p, List<String> defaultIds) {
    columnOrder[p] = List.of(defaultIds);
    hiddenColumns[p] = <String>{};
    notifyListeners();
  }

  /// Closes an open action-group rail or the columns editor, if either is
  /// open — used by the global Escape-key handler.
  void closeRail() {
    if (activeGroup == null && !columnsOpen) return;
    activeGroup = null;
    railSubAction = null;
    columnsOpen = false;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void sortBy(String key) {
    if (sortKey == key) {
      sortDir = -sortDir;
    } else {
      sortKey = key;
      sortDir = 1;
    }
    notifyListeners();
  }

  // ---- selection -----------------------------------------------------------

  bool isSelected(int id) => selected.contains(id);

  void toggleRow(int id) {
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    notifyListeners();
  }

  void toggleAll(List<int> ids) {
    if (selected.length == ids.length) {
      selected.clear();
    } else {
      selected
        ..clear()
        ..addAll(ids);
    }
    notifyListeners();
  }

  void clearSelection() {
    selected.clear();
    notifyListeners();
  }

  // ---- data ----------------------------------------------------------------

  List<Sim> get visibleSims {
    var list = sims.where((s) => query.isEmpty || s.haystack.contains(query.toLowerCase())).toList();
    final k = sortKey;
    if (k != null) list.sort((a, b) => _cmp(a.field(k), b.field(k)) * sortDir);
    return list;
  }

  List<Dongle> get visibleDongles {
    var list =
        dongles.where((d) => query.isEmpty || d.haystack.contains(query.toLowerCase())).toList();
    final k = sortKey;
    if (k != null) list.sort((a, b) => _cmp(a.field(k), b.field(k)) * sortDir);
    return list;
  }

  List<UmDevice> get umDevices => [
        UmDevice(
            id: 91,
            device: '/dev/ttyUSB4',
            model: 'E1550',
            port: '/dev/ttyUSB5',
            pct: flashProgress[4]!),
        UmDevice(
            id: 92,
            device: '/dev/ttyUSB6',
            model: 'E173',
            port: '/dev/ttyUSB7',
            pct: flashProgress[6]!),
      ];

  int _cmp(Object? a, Object? b) {
    if (a is num && b is num) return a.compareTo(b);
    return '$a'.compareTo('$b');
  }

  int cfunOf(int id, int fallback) => powerOverride[id] ?? fallback;
  int pauseOf(int id, int fallback) => pauseOverride[id] ?? fallback;

  // ---- command log ---------------------------------------------------------

  void push(String cmd, List<String> lines, [String warn = '']) {
    final t = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    logs.insert(0, LogEntry('${two(t.hour)}:${two(t.minute)}:${two(t.second)}', cmd, lines, warn));
    if (logs.length > 40) logs.removeRange(40, logs.length);
    logOpen = true;
    notifyListeners();
  }

  void clearLog() {
    logs.clear();
    notifyListeners();
  }

  void toggleLog() {
    logOpen = !logOpen;
    notifyListeners();
  }

  void showToast(String text, [String icon = 'free.png']) {
    toast.value = Toast(text, icon);
  }

  /// Runs `build` for every selected row and records the result.
  /// TODO(api): replace with the real exec transport.
  void runOnSelection(LogEntry Function(Sim) build,
      {String? toastText, String icon = 'free.png'}) {
    final rows = visibleSims.where((s) => selected.contains(s.id)).toList();
    if (rows.isEmpty) {
      showToast('Не выбрано ни одной строки', 'stop.png');
      return;
    }
    final prefix = queueMode ? '[в очередь] ' : '';
    for (final r in rows.take(4)) {
      final e = build(r);
      push(prefix + e.cmd, e.lines, e.warn);
    }
    if (rows.length > 4) {
      push('… ещё ${rows.length - 4} команд поставлено в работу', const []);
    }
    showToast(toastText ?? 'Отправлено: ${rows.length}', icon);
  }

  void runOnDongles(LogEntry Function(Dongle) build,
      {String? toastText, String icon = 'free.png'}) {
    final rows = visibleDongles.where((d) => selected.contains(d.id)).toList();
    if (rows.isEmpty) {
      showToast('Не выбрано ни одного свистка', 'stop.png');
      return;
    }
    for (final r in rows.take(4)) {
      final e = build(r);
      push(e.cmd, e.lines, e.warn);
    }
    showToast(toastText ?? 'Отправлено: ${rows.length}', icon);
  }

  void setPower(int cfun) {
    final rows = visibleSims.where((s) => selected.contains(s.id)).toList();
    for (final r in rows) {
      powerOverride[r.id] = cfun;
    }
  }

  void setPause(int value) {
    final rows = visibleSims.where((s) => selected.contains(s.id)).toList();
    for (final r in rows) {
      pauseOverride[r.id] = value;
    }
  }

  void setPlanGroup(String key, bool on) {
    planShow[key] = on;
    notifyListeners();
  }

  void setQueueMode(bool v) {
    queueMode = v;
    notifyListeners();
  }

  void setLiveRefresh(bool v) {
    liveRefresh = v;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
