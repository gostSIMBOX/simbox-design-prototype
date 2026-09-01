import 'package:flutter/material.dart';
import '../data/icon_map.dart';
import '../data/mock.dart';
import '../design/tokens.dart';
import '../widgets/adm_icon.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  static const _grid = [84.0, 60.0, 220.0, 90.0, 90.0];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 580,
        child: Container(
          decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.radiusCard),
            boxShadow: T.shadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration:
                  const BoxDecoration(border: Border(bottom: BorderSide(color: T.hairline))),
              child: const Text('Биллинг', style: T.screenTitle),
            ),
            Container(
              color: T.headBg,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(children: [
                SizedBox(width: _grid[0], child: const Text('Дата', style: T.head)),
                SizedBox(width: _grid[1], child: const Text('Напр.', style: T.head)),
                SizedBox(width: _grid[2], child: const Text('Оператор', style: T.head)),
                SizedBox(
                    width: _grid[3],
                    child: const Text('Минуты', style: T.head, textAlign: TextAlign.right)),
                SizedBox(
                    width: _grid[4],
                    child: const Text('Деньги', style: T.head, textAlign: TextAlign.right)),
              ]),
            ),
            for (var i = 0; i < billing.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: i.isOdd ? T.rowOdd : T.rowEven,
                  border: const Border(bottom: BorderSide(color: T.rowSep)),
                ),
                child: Row(children: [
                  SizedBox(width: _grid[0], child: Text(billing[i].date, style: T.cell)),
                  SizedBox(width: _grid[1], child: AdmIcon.ref(Ico.napr(billing[i].code))),
                  SizedBox(
                      width: _grid[2],
                      child: Text(billing[i].name,
                          style: T.cell.copyWith(color: const Color(0xFF546675)))),
                  SizedBox(
                      width: _grid[3],
                      child: Text(billing[i].minutes, style: T.cell, textAlign: TextAlign.right)),
                  SizedBox(
                      width: _grid[4],
                      child: Text(billing[i].money, style: T.cell, textAlign: TextAlign.right)),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(children: [
                SizedBox(
                    width: _grid[0],
                    child: Text('Всего', style: T.cell.copyWith(fontWeight: FontWeight.w600))),
                SizedBox(width: _grid[1] + _grid[2]),
                SizedBox(
                    width: _grid[3],
                    child: Text('515.1',
                        style: T.cell.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
                SizedBox(
                    width: _grid[4],
                    child: Text('7.96',
                        style: T.cell.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
              ]),
            ),
          ]),
        ),
      ),
      ),
    );
  }
}
