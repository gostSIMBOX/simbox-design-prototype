import 'package:flutter/material.dart';
import '../data/mock.dart';
import '../design/tokens.dart';
import '../widgets/adm_icon.dart';

class NaborPage extends StatelessWidget {
  const NaborPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 520,
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
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: T.hairline))),
                child: const Text('Наборы команд', style: T.screenTitle),
              ),
              for (final n in naborNames)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: T.rowSep))),
                  child: Row(children: [
                    AdmIcon(naborIcons[n]!, title: n),
                    const SizedBox(width: 10),
                    Text(n,
                        style: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: T.fg1)),
                    const Spacer(),
                    Text('${n == 'default' ? 6 : 9} команд', style: T.cellSub),
                  ]),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
