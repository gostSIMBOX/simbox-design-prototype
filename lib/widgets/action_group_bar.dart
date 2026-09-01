import 'package:flutter/material.dart';
import '../design/tokens.dart';
import 'adm_icon.dart';

/// One collapsible action group shown as a pill in a [TableHeaderBar] — the
/// pill's `builder` returns the existing `Panel`-based content for that group,
/// unchanged from before this was pulled out of the below-the-table `Wrap`.
class ActionGroup {
  final String key;
  final String label;
  final String icon;
  final Widget Function(BuildContext) builder;
  const ActionGroup({
    required this.key,
    required this.label,
    required this.icon,
    required this.builder,
  });
}

/// Toggle pill for one [ActionGroup]. Closed = outline + muted text + ▼.
/// Open = brand-tint fill + brand text + ▲.
class ActionGroupPill extends StatelessWidget {
  final ActionGroup group;
  final bool open;
  final VoidCallback onTap;
  const ActionGroupPill({super.key, required this.group, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: open ? T.rowSel : T.surface,
      borderRadius: BorderRadius.circular(T.radiusCtl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(T.radiusCtl),
        hoverColor: const Color(0x0A000000),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(T.radiusCtl),
            border: Border.all(color: open ? const Color(0x59005BEA) : T.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AdmIcon(group.icon),
            const SizedBox(width: 7),
            Text(group.label,
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 12,
                  fontWeight: open ? FontWeight.w600 : FontWeight.w500,
                  color: open ? T.brandDeep : const Color(0xFF546675),
                )),
            const SizedBox(width: 6),
            Text(open ? '▲' : '▼',
                style: TextStyle(fontSize: 9, color: open ? T.brandDeep : T.fg2)),
          ]),
        ),
      ),
    );
  }
}

/// The floating panel for whichever [ActionGroup] is currently open. Callers
/// place this inside a `Stack`/`Positioned` above the table so it overlays
/// rather than reflowing the layout (see 03-specifications.md Architecture).
class ActionGroupOverlay extends StatelessWidget {
  final List<ActionGroup> groups;
  final String activeKey;
  const ActionGroupOverlay({super.key, required this.groups, required this.activeKey});

  @override
  Widget build(BuildContext context) {
    ActionGroup? group;
    for (final g in groups) {
      if (g.key == activeKey) {
        group = g;
        break;
      }
    }
    if (group == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FE),
        border: const Border(bottom: BorderSide(color: T.border)),
        boxShadow: const [BoxShadow(color: Color(0x599CB2C2), blurRadius: 32, offset: Offset(0, 12))],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: SingleChildScrollView(
          child: Align(alignment: Alignment.topLeft, child: group.builder(context)),
        ),
      ),
    );
  }
}
