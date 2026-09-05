import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import 'adm_icon.dart';

/// Bottom console — the counterpart of `exec_br()` output in the 2015 panel.
class CommandLog extends StatelessWidget {
  const CommandLog({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: T.surface,
        border: Border(top: BorderSide(color: T.headSep)),
        boxShadow: [
          BoxShadow(
              color: Color(0x2E9CB2C2), blurRadius: 32, offset: Offset(0, -1))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            child: Row(children: [
              const AdmIcon('logussd.png'),
              const SizedBox(width: 12),
              const Text('Вывод команд', style: T.panelTitle),
              const SizedBox(width: 10),
              Text(s.logs.isEmpty ? '' : '${s.logs.length} записей',
                  style: T.caption),
              const Spacer(),
              _small('Очистить', s.clearLog),
              const SizedBox(width: 8),
              _small(s.logOpen ? 'Свернуть' : 'Развернуть', s.toggleLog),
            ]),
          ),
          if (s.logOpen)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: s.logs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: Text(
                        'Пока пусто. Выберите строки и запустите действие — здесь появится '
                        'команда и её вывод, как в оригинальной панели.',
                        style: T.caption.copyWith(color: T.fg2),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                      itemCount: s.logs.length,
                      itemBuilder: (_, i) {
                        final e = s.logs[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: T.hairline))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    SizedBox(
                                        width: 62,
                                        child: Text(e.time,
                                            style: T.cellTertiary)),
                                    Expanded(
                                        child: Text(e.cmd,
                                            style:
                                                T.mono.copyWith(color: T.ink))),
                                  ]),
                              for (final l in e.lines)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 62, top: 2),
                                  child: Text(l,
                                      style: T.mono.copyWith(color: T.fgMuted)),
                                ),
                              if (e.warn.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 62, top: 4),
                                  child: Text(e.warn,
                                      style: const TextStyle(
                                          fontFamily: 'SF Pro Text',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: T.danger)),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _small(String label, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: T.border),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'SF Pro Text', fontSize: 11, color: T.fg1)),
          ),
        ),
      );
}
