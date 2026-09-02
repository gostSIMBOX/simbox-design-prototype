import 'package:flutter/material.dart';
import '../data/icon_map.dart';
import '../data/models.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import '../widgets/action_group_bar.dart';
import '../widgets/dense_table.dart';
import '../widgets/panel.dart';
import 'sims_page.dart' show TableHeading, TableToolbar, columnDisplayLabel;

class ReadersPage extends StatefulWidget {
  const ReadersPage({super.key});
  @override
  State<ReadersPage> createState() => _ReadersPageState();
}

class _ReadersPageState extends State<ReadersPage> {
  final _search = TextEditingController();
  final _removePin = TextEditingController();
  final _setPin = TextEditingController();
  final _apdu = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    _removePin.dispose();
    _setPin.dispose();
    _apdu.dispose();
    super.dispose();
  }

  List<ColDef<Reader>> _cols() => [
        ColDef(
            key: 'model',
            w: 38,
            title: 'модель',
            build: (r) => Cell(icons: [if (Ico.readerModel(r.model) case final ico?) ico])),
        ColDef(key: 'device', w: 90, label: 'Ридер', build: (r) => Cell(mono: r.device)),
        ColDef(key: 'lock', w: 70, label: 'lock', build: (r) => Cell(text: r.lock)),
        ColDef(key: 'state', w: 100, label: 'state',
            build: (r) => Cell(text: r.state, sub: r.stateFault)),
        ColDef(key: 'spn', w: 90, label: 'SPN', build: (r) => Cell(text: r.spn)),
        ColDef(key: 'iccid', w: 150, label: 'ICCID', build: (r) => Cell(mono: r.iccid)),
        ColDef(key: 'pin', w: 60, label: 'PIN', build: (r) => Cell(mono: r.pin)),
        ColDef(key: 'imsi', w: 140, label: 'IMSI', build: (r) => Cell(mono: r.imsi)),
        ColDef(key: 'ki', w: 260, label: 'KI',
            build: (r) => Cell(mono: r.ki.isEmpty ? '00' : r.ki)),
        ColDef(key: 'progress', w: 90, label: 'прогр', build: (r) => Cell(text: r.progressDisplay)),
        ColDef(key: 'dataport', w: 110, label: 'dataport', build: (r) => Cell(mono: r.dataport)),
      ];

  List<ColDef<Reader>> _visibleCols(AppState st, List<ColDef<Reader>> all) {
    final defaults = [for (final c in all) c.key];
    final order = st.columnOrderFor(AdmPage.readers, defaults);
    final hidden = st.hiddenColumnsFor(AdmPage.readers);
    final byKey = {for (final c in all) c.key: c};
    return [for (final k in order) if (!hidden.contains(k) && byKey.containsKey(k)) byKey[k]!];
  }

  List<ActionGroup> _groups(AppState st) => [
        ActionGroup(
          key: 'refresh',
          label: 'Обновить',
          icon: 'free.png',
          subActions: [
            SubAction(
              key: 'all',
              label: 'Обновить',
              builder: (_) => AdmButton('Обновить',
                  primary: true, onPressed: () => st.showToast('Обновлено', 'free.png')),
            ),
          ],
        ),
        ActionGroup(
          key: 'pin',
          label: 'PIN',
          icon: 'lock.png',
          subActions: [
            SubAction(
              key: 'all',
              label: 'PIN',
              builder: (_) => Wrap(spacing: 12, runSpacing: 8, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  AdmField(_removePin, hint: 'PIN', width: 90),
                  const SizedBox(width: 8),
                  AdmButton('Снять PIN', onPressed: () {
                    final pin = _removePin.text.isEmpty ? '0000' : _removePin.text;
                    st.runOnReaders(
                        (r) => LogEntry(
                            '',
                            "asterisk -rx 'dongle cmd ${r.device} AT+CPIN=\"$pin\";"
                            "+CLCK=\"SC\",0,\"$pin\";+CFUN=1,1'",
                            const ['OK']),
                        toastText: 'PIN снят',
                        icon: 'lock.png');
                  }),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  AdmField(_setPin, hint: 'новый PIN', width: 90),
                  const SizedBox(width: 8),
                  AdmButton('Установить PIN', primary: true, onPressed: () {
                    st.runOnReaders(
                        (r) => LogEntry(
                            '',
                            "asterisk -rx 'dongle cmd ${r.device} "
                            "AT+CLCK=\"SC\",1,\"${_setPin.text}\";+CFUN=1,1'",
                            const ['OK']),
                        toastText: 'PIN установлен',
                        icon: 'lock.png');
                  }),
                ]),
              ]),
            ),
          ],
        ),
        ActionGroup(
          key: 'kisearch',
          label: 'Поиск KI',
          icon: 'pl2303.png',
          subActions: [
            SubAction(
              key: 'all',
              label: 'Поиск KI',
              builder: (_) => AdmButton('Запустить поиск KI',
                  primary: true,
                  onPressed: () => st.runOnReaders(
                      (r) => LogEntry(
                          '',
                          'wts --svistokmode=1 --device=reader --speed=9600 --ignorects '
                          '--port=${r.dataport} --dev=${r.device}',
                          const ['поиск запущен']),
                      toastText: 'Поиск KI запущен',
                      icon: 'pl2303.png')),
            ),
          ],
        ),
        ActionGroup(
          key: 'apdu',
          label: 'APDU-команда',
          icon: 'conn.png',
          subActions: [
            SubAction(
              key: 'all',
              label: 'APDU-команда',
              builder: (_) => Row(mainAxisSize: MainAxisSize.min, children: [
                AdmField(_apdu, mono: true, width: 200),
                const SizedBox(width: 8),
                AdmButton('Выполнить', primary: true, onPressed: () {
                  st.runOnReaders(
                      (r) => LogEntry('', 'apdu ${r.device} ${_apdu.text}', const ['OK']),
                      toastText: 'APDU-команда');
                }),
              ]),
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final rows = st.visibleReaders;
    final cols = _cols();

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TableHeading(title: 'Ридеры', count: rows.length),
        const SizedBox(height: 10),
        TableToolbar(
          groups: _groups(st),
          search: _search,
          onSearch: st.setQuery,
          page: AdmPage.readers,
          allColumns: [for (final c in cols) (key: c.key, label: columnDisplayLabel(c))],
        ),
        if (st.activeGroup == 'kisearch') ...[
          const SizedBox(height: 8),
          const _KiWarningBanner(),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: DenseTable<Reader>(
            cols: _visibleCols(st, cols),
            rows: rows,
            idOf: (r) => r.id,
            isSelected: st.isSelected,
            onToggleRow: st.toggleRow,
            onToggleAll: () => st.toggleAll(rows.map((e) => e.id).toList()),
            sortKey: st.sortKey,
            sortDir: st.sortDir,
            onSort: st.sortBy,
          ),
        ),
      ]),
    );
  }
}

/// Persistent caution banner shown while the "Поиск KI" action group is open —
/// reproduces readers.php's inline warning that the card is unavailable for
/// other operations during a KI search.
class _KiWarningBanner extends StatelessWidget {
  const _KiWarningBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0x1AE5484D),
          borderRadius: BorderRadius.circular(T.radiusCtl),
          border: Border.all(color: const Color(0x59E5484D)),
        ),
        child: const Text(
          'Внимание! Во время подбора KI карта недоступна для других операций.',
          style: TextStyle(fontFamily: 'SF Pro Text', fontSize: 12, color: Color(0xFFB3261E)),
        ),
      );
}
