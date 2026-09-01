import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import 'adm_icon.dart';

/// One selectable action within a group. For a group with a single
/// [SubAction] (Rule A/C — see 03-specifications.md), `builder` renders the
/// group's whole expanded content (a flat button strip, or one action's
/// fields+Run button). For a group with several [SubAction]s (Rule B),
/// `builder` renders just that one action's fields+Run button(s) — the
/// caller (a dropdown) picks which is visible.
class SubAction {
  final String key;
  final String label;
  final Widget Function(BuildContext) builder;
  const SubAction({required this.key, required this.label, required this.builder});
}

/// One collapsible action group shown as a pill in a [TableToolbar].
class ActionGroup {
  final String key;
  final String label;
  final String icon;
  final List<SubAction> subActions;

  /// Settings shared by every sub-action in the group (e.g. queue+delay,
  /// live-refresh) — shown alongside the dropdown regardless of which
  /// sub-action is selected. Only rendered when there's more than one
  /// sub-action (Rule B); ignored for Rule A/C groups.
  final Widget Function(BuildContext)? sharedSettings;

  const ActionGroup({
    required this.key,
    required this.label,
    required this.icon,
    required this.subActions,
    this.sharedSettings,
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

/// Icon-only pill for narrow layouts — same tap target, label dropped, kept
/// discoverable via [Tooltip].
class ActionGroupIconPill extends StatelessWidget {
  final ActionGroup group;
  final bool open;
  final VoidCallback onTap;
  const ActionGroupIconPill(
      {super.key, required this.group, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: group.label,
      child: Material(
        color: open ? T.rowSel : T.surface,
        borderRadius: BorderRadius.circular(T.radiusCtl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(T.radiusCtl),
          hoverColor: const Color(0x0A000000),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(T.radiusCtl),
              border: Border.all(color: open ? const Color(0x59005BEA) : T.border),
            ),
            child: AdmIcon(group.icon),
          ),
        ),
      ),
    );
  }
}

/// Small square icon-button used for the rail's cancel/back affordance.
class RailIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const RailIconButton({super.key, required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.radiusCtl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(T.radiusCtl),
          hoverColor: const Color(0x0A000000),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(T.radiusCtl),
              border: Border.all(color: T.border),
            ),
            child: Icon(icon, size: 16, color: T.fg1),
          ),
        ),
      ),
    );
  }
}

class _SubActionDropdown extends StatelessWidget {
  final List<SubAction> subActions;
  final String value;
  final ValueChanged<String> onChanged;
  final bool compact;
  const _SubActionDropdown(
      {required this.subActions, required this.value, required this.onChanged, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(T.radiusCtl),
        border: Border.all(color: T.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.expand_more, size: 16, color: T.fgMuted),
          style: const TextStyle(fontFamily: 'SF Pro Text', fontSize: 12, color: T.fg1),
          items: [
            for (final s in subActions)
              DropdownMenuItem(
                value: s.key,
                child: Text(compact ? '' : s.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          selectedItemBuilder: compact
              ? (ctx) => [for (final _ in subActions) const SizedBox(width: 8)]
              : null,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Vertical hairline separator between a group's picker and its shared
/// settings.
class _RailDivider extends StatelessWidget {
  const _RailDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 22, margin: const EdgeInsets.symmetric(horizontal: 12), color: T.hairline);
}

/// Renders the toolbar's action-rail region: idle pills, or the currently
/// open group's Rule A/B/C content — never the columns editor (that's a
/// sibling, mutually-exclusive widget rendered by [TableToolbar] instead).
/// Always a single row: any overflow scrolls horizontally, never wraps.
class ActionRail extends StatelessWidget {
  final List<ActionGroup> groups;
  final bool compact;
  const ActionRail({super.key, required this.groups, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final activeKey = st.activeGroup;

    Widget content;
    if (activeKey == null) {
      content = Row(mainAxisSize: MainAxisSize.min, children: [
        for (final g in groups) ...[
          compact
              ? ActionGroupIconPill(
                  group: g,
                  open: false,
                  onTap: () => st.toggleGroup(g.key, [for (final s in g.subActions) s.key]),
                )
              : ActionGroupPill(
                  group: g,
                  open: false,
                  onTap: () => st.toggleGroup(g.key, [for (final s in g.subActions) s.key]),
                ),
          const SizedBox(width: 6),
        ],
      ]);
    } else {
      ActionGroup? group;
      for (final g in groups) {
        if (g.key == activeKey) {
          group = g;
          break;
        }
      }
      if (group == null) {
        content = const SizedBox.shrink();
      } else if (group.subActions.length <= 1) {
        final sub = group.subActions.isNotEmpty ? group.subActions.first : null;
        final g = group;
        content = Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          RailIconButton(icon: Icons.arrow_back, tooltip: 'Отмена', onTap: () => st.toggleGroup(g.key)),
          const SizedBox(width: 10),
          if (sub != null) sub.builder(context),
          if (g.sharedSettings != null) ...[
            const _RailDivider(),
            g.sharedSettings!(context),
          ],
        ]);
      } else {
        final selectedKey = st.railSubAction ?? group.subActions.first.key;
        var selected = group.subActions.first;
        for (final s in group.subActions) {
          if (s.key == selectedKey) {
            selected = s;
            break;
          }
        }
        final g = group;
        content = Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          RailIconButton(icon: Icons.arrow_back, tooltip: 'Отмена', onTap: () => st.toggleGroup(g.key)),
          const SizedBox(width: 10),
          _SubActionDropdown(
            subActions: g.subActions,
            value: selected.key,
            onChanged: st.selectSubAction,
            compact: compact,
          ),
          const SizedBox(width: 10),
          selected.builder(context),
          if (g.sharedSettings != null) ...[
            const _RailDivider(),
            g.sharedSettings!(context),
          ],
        ]);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Align(alignment: Alignment.centerLeft, heightFactor: 1, child: content),
    );
  }
}
