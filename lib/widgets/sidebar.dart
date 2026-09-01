import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.expanded,
    required this.activeKey,
    required this.onToggle,
    required this.onSelect,
  });

  final bool expanded;
  final String activeKey;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      width: expanded ? 208 : 64,
      decoration: BoxDecoration(
        color: T.surface,
        border: Border(right: BorderSide(color: T.rulePanel)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // logo doubles as the compact/full switch
          InkWell(
            onTap: onToggle,
            child: Container(
              height: 64,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: T.rulePanel)),
              ),
              child: Image.asset(
                expanded ? 'assets/logo_wide.png' : 'assets/logo_square.png',
                height: expanded ? 28 : 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (_, i) {
                final it = navItems[i];
                final active = it.key == activeKey;
                final row = Row(
                  mainAxisAlignment: expanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Ico(it.icon),
                    if (expanded) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          it.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active ? T.brand : T.fgBody,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
                return Tooltip(
                  message: expanded ? '' : it.label,
                  child: Material(
                    color: active ? T.rowSel : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onSelect(it.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        child: row,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
