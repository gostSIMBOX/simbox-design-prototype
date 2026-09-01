import 'package:flutter/material.dart';
import '../design/tokens.dart';
import 'adm_icon.dart';

/// The one card surface: 10px radius, single app-wide shadow, hairline header.
class Panel extends StatelessWidget {
  final String title;
  final String? icon;
  final Widget child;
  final double? width;
  final List<Widget> actions;
  final EdgeInsets padding;

  const Panel({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    this.width,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.radiusCard),
        boxShadow: T.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: T.hairline)),
            ),
            child: Row(children: [
              if (icon != null) ...[AdmIcon(icon!), const SizedBox(width: 8)],
              Flexible(child: Text(title, style: T.panelTitle, overflow: TextOverflow.ellipsis)),
              if (actions.isNotEmpty) ...[const Spacer(), ...actions],
            ]),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}

class AdmButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback onPressed;
  final bool primary;
  final bool danger;
  final bool expand;
  final String? tooltip;

  const AdmButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.danger = false,
    this.expand = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[AdmIcon(icon!), const SizedBox(width: 8)],
        Flexible(
          child: Text(label,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 13,
                fontWeight: primary ? FontWeight.w500 : FontWeight.w400,
                color: primary ? Colors.white : (danger ? T.danger : T.fg1),
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: primary ? T.brandGradient : null,
        color: primary ? null : T.surface,
        borderRadius: BorderRadius.circular(T.radiusCtl),
        border: primary ? null : Border.all(color: danger ? T.danger : T.border),
      ),
      child: content,
    );

    final w = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(T.radiusCtl),
        hoverColor: const Color(0x0A000000),
        child: child,
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}

class AdmField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final double? width;
  final bool mono;
  const AdmField(this.controller, {super.key, this.hint, this.width, this.mono = false});

  @override
  Widget build(BuildContext context) {
    final f = TextField(
      controller: controller,
      style: mono ? T.mono : const TextStyle(fontFamily: 'SF Pro Text', fontSize: 12, color: T.fg1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: T.caption,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        filled: true,
        fillColor: T.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(T.radiusCtl),
          borderSide: const BorderSide(color: T.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(T.radiusCtl),
          borderSide: const BorderSide(color: T.brandDeep, width: 1.6),
        ),
      ),
    );
    return width == null ? f : SizedBox(width: width, child: f);
  }
}

class AdmCheck extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? icon;
  const AdmCheck(
      {super.key, required this.value, required this.onChanged, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: T.brandDeep,
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[AdmIcon(icon!), const SizedBox(width: 6)],
          Text(label, style: T.body),
        ]),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final List<Widget> trailing;
  const SectionTitle(this.text, {super.key, this.trailing = const []});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Text(text, style: T.screenTitle),
          if (trailing.isNotEmpty) ...[const SizedBox(width: 14), ...trailing],
        ]),
      );
}
