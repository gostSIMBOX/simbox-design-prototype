import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import 'controller.dart';
import 'models.dart';

/// Renders a zone's `napravleine/*` icon (the same set `Ico.napr` draws
/// from), not [FugueIcon] — zones are visually the Sims table's `напр`
/// direction icons, just with a management UI attached.
class ZoneIcon extends StatelessWidget {
  final Zone zone;
  final double size;
  const ZoneIcon(this.zone, {super.key, this.size = 16});

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/imgs/${zone.icon}',
        width: size,
        height: size,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
      );
}

/// The one editable body of a zone: every DEF code, one per line, replaced
/// wholesale on save (Requirements #4/#5) — no per-code add/remove rows.
class ZoneCodeEditor extends StatefulWidget {
  final ZoneController controller;
  const ZoneCodeEditor({super.key, required this.controller});

  @override
  State<ZoneCodeEditor> createState() => _ZoneCodeEditorState();
}

class _ZoneCodeEditorState extends State<ZoneCodeEditor> {
  final _text = TextEditingController();
  String? _syncedForId;
  bool _syncedDirty = false;

  @override
  void initState() {
    super.initState();
    _syncFromController();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _syncFromController() {
    final zone = widget.controller.selected;
    _text.text = zone?.defCodes.join('\n') ?? '';
    _syncedForId = zone?.id;
    _syncedDirty = widget.controller.isDirty;
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.controller;
    final zone = st.selected;
    if (zone?.id != _syncedForId || (_syncedDirty && !st.isDirty)) {
      _syncFromController();
    }
    final count = zone?.defCodes.length ?? 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text('DEF-коды ($count)', style: T.panelTitle),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: T.border),
              borderRadius: BorderRadius.circular(T.radiusCtl),
            ),
            child: Scrollbar(
              child: TextField(
                controller: _text,
                maxLines: null,
                expands: true,
                enabled: zone != null,
                textAlignVertical: TextAlignVertical.top,
                style: T.mono,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged: st.updateCodesText,
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Text('Каждый код — новая строка. Пустые строки игнорируются.', style: T.caption),
      ),
    ]);
  }
}
