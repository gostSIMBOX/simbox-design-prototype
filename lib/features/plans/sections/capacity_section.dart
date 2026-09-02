import 'package:flutter/material.dart';
import '../controller.dart';
import 'section_fields.dart';

class CapacitySection extends StatelessWidget {
  final PlanController controller;
  const CapacitySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected!;
    return PolicySection(title: 'Ёмкость', children: [
      IntField(
        key: ValueKey('onlineMax-${plan.id}-${plan.onlineMax}'),
        label: 'Макс. онлайн-симок',
        value: plan.onlineMax,
        onChanged: (v) => controller.updateCapacity(onlineMax: v),
      ),
      IntField(
        key: ValueKey('addMax-${plan.id}-${plan.addMax}'),
        label: 'Макс. add/reserve',
        value: plan.addMax,
        onChanged: (v) => controller.updateCapacity(addMax: v),
      ),
    ]);
  }
}
