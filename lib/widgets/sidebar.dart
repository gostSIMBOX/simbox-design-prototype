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

const _widthFull = 208.0;
const _widthCompact = 64.0;

/// Left navigation rail. Click the logo header to toggle full (labeled) vs.
/// compact (icon-only) mode — the logo image itself swaps wide <-> square.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final compact = s.navCompact;

    return Container(
      width: compact ? _widthCompact : _widthFull,
      decoration: const BoxDecoration(
        color: T.surface,
        border: Border(right: BorderSide(color: T.border)),
        boxShadow: [BoxShadow(color: Color(0x249CB2C2), blurRadius: 32, offset: Offset(0, 1))],
      ),
      child: Column(children: [
        _LogoHeader(compact: compact, onTap: s.toggleNav),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final tab in _tabs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _NavItem(tab.$1, tab.$2, tab.$3, s.page == tab.$1, compact),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  final bool compact;
  final VoidCallback onTap;
  const _LogoHeader({required this.compact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Свернуть / развернуть меню',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: const Color(0x0D005BEA),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: T.hairline)),
            ),
            child: compact
                ? Image.asset('assets/brand/logo_transparent.png',
                    height: 34, width: 34, errorBuilder: (_, __, ___) => const SizedBox(width: 34, height: 34))
                : Image.asset('assets/brand/logo_wide_transparent.png',
                    height: 30, errorBuilder: (_, __, ___) => const SizedBox(height: 30)),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AdmPage page;
  final String label, icon;
  final bool active;
  final bool compact;
  const _NavItem(this.page, this.label, this.icon, this.active, this.compact);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final button = Material(
      color: active ? T.rowSel : Colors.transparent,
      borderRadius: BorderRadius.circular(T.radiusCtl),
      child: InkWell(
        onTap: () => s.goTo(page),
        borderRadius: BorderRadius.circular(T.radiusCtl),
        hoverColor: const Color(0x0A000000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Opacity(opacity: active ? 1 : 0.75, child: AdmIcon(icon)),
              if (!compact) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? T.brandDeep : const Color(0xFF546675),
                      )),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Tooltip(message: label, child: button);
  }
}
