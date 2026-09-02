import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

/// Collapsible policy-family section, matches the `ExpansionTile` accordion
/// look already used in `command_sets/commands_section.dart`.
class PolicySection extends StatelessWidget {
  final String title;
  final bool initiallyExpanded;
  final List<Widget> children;
  const PolicySection({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(T.radiusCtl), border: Border.all(color: T.hairline)),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          title: Text(title, style: T.panelTitle),
          initiallyExpanded: initiallyExpanded,
          children: [FieldWrap(children: children)],
        ),
      );
}

/// A labeled integer field bound directly to a controller callback. Commits
/// on Enter or on focus loss (so tabbing/clicking to the next field doesn't
/// silently discard the edit) — no persistent `TextEditingController` state
/// beyond the field's own lifetime, since the value only changes externally
/// via draft updates (Save/Cancel/switch plan), each of which remounts this
/// widget with a fresh `key`.
class IntField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const IntField({super.key, required this.label, required this.value, required this.onChanged});
  @override
  State<IntField> createState() => _IntFieldState();
}

class _IntFieldState extends State<IntField> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.value}');
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChange);

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final v = int.tryParse(_controller.text.trim());
    if (v != null) widget.onChanged(v);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 160,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          style: T.body,
          decoration: InputDecoration(
            labelText: widget.label,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(T.radiusCtl)),
          ),
          onSubmitted: (_) => _commit(),
        ),
      );
}

/// A nullable hour field (`-1`/absent in legacy => disabled). Empty text means
/// disabled; any parsed int in [0,23] enables the schedule.
class NullableHourField extends StatefulWidget {
  final String label;
  final int? value;
  final void Function(int? value) onChanged;
  const NullableHourField({super.key, required this.label, required this.value, required this.onChanged});
  @override
  State<NullableHourField> createState() => _NullableHourFieldState();
}

class _NullableHourFieldState extends State<NullableHourField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value == null ? '' : '${widget.value}');
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChange);

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final v = int.tryParse(trimmed);
    if (v != null && v >= 0 && v <= 23) widget.onChanged(v);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 160,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          style: T.body,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'выключено',
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(T.radiusCtl)),
          ),
          onSubmitted: (_) => _commit(),
        ),
      );
}

class BoolField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const BoolField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(T.radiusCtl),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Switch(value: value, onChanged: onChanged),
            const SizedBox(width: 4),
            Text(label, style: T.body),
          ]),
        ),
      );
}

class FieldWrap extends StatelessWidget {
  final List<Widget> children;
  const FieldWrap({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        child: Wrap(spacing: 16, runSpacing: 10, children: children),
      );
}
