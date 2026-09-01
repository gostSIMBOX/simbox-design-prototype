import 'package:flutter/material.dart';
import '../data/mock.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import '../widgets/adm_icon.dart';
import '../widgets/panel.dart';

class _PlanCol {
  final String group, label;
  final double w;
  final String? icon;
  const _PlanCol(this.group, this.w, this.label, [this.icon]);
}

const _planCols = <_PlanCol>[
  _PlanCol('*', 132, 'план / набор'),
  _PlanCol('*', 60, 'online'),
  _PlanCol('*', 62, 'add/res'),
  _PlanCol('*', 62, 'priority'),
  _PlanCol('modes', 38, '', 'state_in.png'),
  _PlanCol('modes', 38, '', 'state_out.png'),
  _PlanCol('modes', 38, '', 'qos/ivip.png'),
  _PlanCol('modes', 38, '', 'qos/igoo.png'),
  _PlanCol('modes', 38, '', 'qos/inor.png'),
  _PlanCol('modes', 38, '', 'qos/ibad.png'),
  _PlanCol('timings', 68, 'diff_slow'),
  _PlanCol('timings', 66, 'diff_min'),
  _PlanCol('timings', 80, 'diff_min_vip'),
  _PlanCol('sched', 78, 'time_wake'),
  _PlanCol('sched', 80, 'time_sleep'),
  _PlanCol('fwd', 66, 'forward'),
  _PlanCol('gin', 66, 'IATT_min'),
  _PlanCol('gin', 66, 'IATT_max'),
  _PlanCol('gsms', 58, 'MAY', 'may.png'),
  _PlanCol('gsms', 58, 'MON', 'mon.png'),
  _PlanCol('napr', 60, 'Напр.1'),
  _PlanCol('napr', 68, 'limit_soft'),
  _PlanCol('napr', 68, 'limit_hard'),
];

const _planGroups = <List<String>>[
  ['modes', 'режимы', 'qos/igoo.png'],
  ['timings', 'тайминги', 'clock.png'],
  ['sched', 'расписание', 'pause2.png'],
  ['fwd', 'форвардинг звонков', 'spec/forwarding.png'],
  ['gin', 'генерация входящих', 'need_in.png'],
  ['gsms', 'генерация sms', 'satt.png'],
  ['napr', 'направления', 'napravleine/hz.png'],
];

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cols = _planCols.where((c) => c.group == '*' || st.planShow[c.group] == true).toList();
    final width = cols.fold<double>(0, (a, c) => a + c.w);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        title: 'Отображение информации',
        width: 290,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final g in _planGroups)
            AdmCheck(
              value: st.planShow[g[0]] == true,
              onChanged: (v) => st.setPlanGroup(g[0], v),
              label: g[1],
              icon: g[2],
            ),
        ]),
      ),
      const SizedBox(width: 18),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.radiusCard),
            boxShadow: T.shadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration:
                  const BoxDecoration(border: Border(bottom: BorderSide(color: T.hairline))),
              child: Row(children: [
                const Text('Планы', style: T.screenTitle),
                const Spacer(),
                AdmButton('Сохранить',
                    primary: true,
                    onPressed: () {
                      st.push('/usr/simbox/www/simbox/plan.php?save=1',
                          const ['3 плана сохранено']);
                      st.showToast('Планы сохранены');
                    }),
              ]),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: T.headBg,
                      border: Border(bottom: BorderSide(color: T.headSep)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      for (final c in cols)
                        SizedBox(
                          width: c.w,
                          child: Padding(
                            padding: T.headPad,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (c.icon != null) ...[
                                  AdmIcon(c.icon!, title: c.label.isEmpty ? c.group : c.label),
                                  const SizedBox(height: 2),
                                ],
                                Text(c.label, style: T.head, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ),
                    ]),
                  ),
                  for (var i = 0; i < planRows.length; i++)
                    _row(cols, i),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Text(
                'После изменения плана выберите симки на вкладке «Симки» и нажмите '
                '«Восстановить параметры плана».',
                style: T.caption,
              ),
            ),
          ]),
        ),
      ),
      ]),
    );
  }

  Widget _row(List<_PlanCol> cols, int index) {
    final p = planRows[index];
    var vi = -1;
    return Container(
      decoration: BoxDecoration(
        color: index.isOdd ? T.rowOdd : T.rowEven,
        border: const Border(bottom: BorderSide(color: T.rowSep)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        for (final c in cols)
          SizedBox(
            width: c.w,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Builder(builder: (_) {
                if (c.label == 'план / набор') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p.name,
                          style: T.cell.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text(p.sub, style: T.cellSub, overflow: TextOverflow.ellipsis),
                    ],
                  );
                }
                vi++;
                final v = vi < p.values.length ? p.values[vi] : '';
                if (c.icon != null && c.label.isEmpty) {
                  return Checkbox(
                    value: v == 1,
                    onChanged: (_) {},
                    activeColor: T.brandDeep,
                    visualDensity: VisualDensity.compact,
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: T.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: T.border),
                  ),
                  child: Text('$v', style: T.cell, overflow: TextOverflow.ellipsis),
                );
              }),
            ),
          ),
      ]),
    );
  }
}
