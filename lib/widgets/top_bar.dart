import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import 'adm_icon.dart';

const _tabs = <(AdmPage, String, String)>[
  (AdmPage.sim, 'Симки', 'free.png'),
  (AdmPage.dongle, 'Свистки (nm)', 'dongle1550.png'),
  (AdmPage.diagmode, 'Свистки (um)', 'diagmode/diagmode_update.png'),
  (AdmPage.hubs, 'Хабы', 'usb/hub_16.png'),
  (AdmPage.nabor, 'Наборы команд', 'ussdsms.png'),
  (AdmPage.plan, 'Планы', 'clock.png'),
  (AdmPage.proc, 'Процессы', 'conn.png'),
  (AdmPage.bablo, 'Биллинг', 'may.png'),
  (AdmPage.upgrade, 'Обновление', 'power.png'),
  (AdmPage.debug, 'Debug', 'logussd.png'),
  (AdmPage.icons, 'Иконки', 'qos/ivip.png'),
];

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.now;
    String two(int v) => v.toString().padLeft(2, '0');
    final clock =
        '${two(t.day)}.${two(t.month)}.${t.year}  ${two(t.hour)}:${two(t.minute)}:${two(t.second)}';

    return Container(
      decoration: const BoxDecoration(
        color: T.surface,
        boxShadow: [BoxShadow(color: Color(0x249CB2C2), blurRadius: 32, offset: Offset(0, 1))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: T.hairline)),
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
              Text('SimBox 8f3c1a2+',
                  style: T.caption.copyWith(fontStyle: FontStyle.italic)),
              const Spacer(),
              Text(clock, style: T.caption),
              const SizedBox(width: 14),
              Text('up 41 days, 6:12', style: T.caption),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final tab in _tabs) _TabButton(tab.$1, tab.$2, tab.$3, s.page == tab.$1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final AdmPage page;
  final String label, icon;
  final bool active;
  const _TabButton(this.page, this.label, this.icon, this.active);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Material(
      color: active ? T.rowSel : Colors.transparent,
      borderRadius: BorderRadius.circular(T.radiusCtl),
      child: InkWell(
        onTap: () => s.goTo(page),
        borderRadius: BorderRadius.circular(T.radiusCtl),
        hoverColor: const Color(0x0A000000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Opacity(opacity: active ? 1 : 0.75, child: AdmIcon(icon)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? T.brandDeep : const Color(0xFF546675),
                )),
          ]),
        ),
      ),
    );
  }
}
