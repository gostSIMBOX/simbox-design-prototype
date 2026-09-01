import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import 'adm_icon.dart';

/// Device/IP/version/clock strip — the content column's top row, to the
/// right of the [Sidebar].
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.now;
    String two(int v) => v.toString().padLeft(2, '0');
    final clock =
        '${two(t.day)}.${two(t.month)}.${t.year}  ${two(t.hour)}:${two(t.minute)}:${two(t.second)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: const BoxDecoration(
        color: T.surface,
        border: Border(bottom: BorderSide(color: T.hairline)),
        boxShadow: [BoxShadow(color: Color(0x249CB2C2), blurRadius: 32, offset: Offset(0, 1))],
      ),
      child: Row(children: [
        const AdmIcon('power.png'),
        const SizedBox(width: 14),
        const Text('simbox-a4',
            style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: T.ink)),
        const SizedBox(width: 14),
        Text('10.42.0.17', style: T.caption),
        const SizedBox(width: 14),
        Text('SimBox 8f3c1a2+', style: T.caption.copyWith(fontStyle: FontStyle.italic)),
        const Spacer(),
        Text(clock, style: T.caption),
        const SizedBox(width: 14),
        Text('up 41 days, 6:12', style: T.caption),
      ]),
    );
  }
}
