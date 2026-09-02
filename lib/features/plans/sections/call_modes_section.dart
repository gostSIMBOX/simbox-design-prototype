import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../controller.dart';
import 'section_fields.dart';

const _qualityCodes = ['VIP', 'GOO', 'NOR', 'BAD', 'NEW', 'NOS', 'ROB', 'BLO'];

class CallModesSection extends StatelessWidget {
  final PlanController controller;
  const CallModesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected!;
    return PolicySection(title: 'Режимы звонков и качество', children: [
      BoolField(
          label: 'Входящие',
          value: plan.canIn,
          onChanged: (v) => controller.updateCallModes(canIn: v)),
      BoolField(
          label: 'Исходящие',
          value: plan.canOut,
          onChanged: (v) => controller.updateCallModes(canOut: v)),
      BoolField(
          label: 'Исходящие sout',
          value: plan.canSout,
          onChanged: (v) => controller.updateCallModes(canSout: v)),
      BoolField(
          label: 'Не VIP',
          value: plan.notVip,
          onChanged: (v) => controller.updateCallModes(notVip: v)),
      BoolField(
          label: 'cap: ok',
          value: plan.capOk,
          onChanged: (v) => controller.updateCallModes(capOk: v)),
      BoolField(
          label: 'cap: new',
          value: plan.capNew,
          onChanged: (v) => controller.updateCallModes(capNew: v)),
      BoolField(
          label: 'cap: fail',
          value: plan.capFail,
          onChanged: (v) => controller.updateCallModes(capFail: v)),
      SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final code in _qualityCodes)
              FilterChip(
                label: Text(code, style: T.body),
                selected: plan.qualityFlags.contains(code),
                onSelected: (selected) {
                  final next = Set<String>.of(plan.qualityFlags);
                  if (selected) {
                    next.add(code);
                  } else {
                    next.remove(code);
                  }
                  controller.updateCallModes(qualityFlags: next);
                },
              ),
          ],
        ),
      ),
    ]);
  }
}
