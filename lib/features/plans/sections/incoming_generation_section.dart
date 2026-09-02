import 'package:flutter/material.dart';
import '../controller.dart';
import 'section_fields.dart';

class IncomingGenerationSection extends StatelessWidget {
  final PlanController controller;
  const IncomingGenerationSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected!;
    return PolicySection(title: 'Генерация входящих', children: [
      IntField(
        key: ValueKey('iattMin-${plan.id}-${plan.iattMin}'),
        label: 'iatt_min',
        value: plan.iattMin,
        onChanged: (v) => controller.updateIncomingGeneration(iattMin: v),
      ),
      IntField(
        key: ValueKey('iattMax-${plan.id}-${plan.iattMax}'),
        label: 'iatt_max',
        value: plan.iattMax,
        onChanged: (v) => controller.updateIncomingGeneration(iattMax: v),
      ),
      IntField(
        key: ValueKey('iattSoft-${plan.id}-${plan.iattSoft}'),
        label: 'iatt_soft',
        value: plan.iattSoft,
        onChanged: (v) => controller.updateIncomingGeneration(iattSoft: v),
      ),
      IntField(
        key: ValueKey('inAcdMin-${plan.id}-${plan.inAcdMin}'),
        label: 'in_acd_min',
        value: plan.inAcdMin,
        onChanged: (v) => controller.updateIncomingGeneration(inAcdMin: v),
      ),
      IntField(
        key: ValueKey('inAcdMax-${plan.id}-${plan.inAcdMax}'),
        label: 'in_acd_max',
        value: plan.inAcdMax,
        onChanged: (v) => controller.updateIncomingGeneration(inAcdMax: v),
      ),
      IntField(
        key: ValueKey('outAcdMin-${plan.id}-${plan.outAcdMin}'),
        label: 'out_acd_min',
        value: plan.outAcdMin,
        onChanged: (v) => controller.updateIncomingGeneration(outAcdMin: v),
      ),
      IntField(
        key: ValueKey('outAcdMax-${plan.id}-${plan.outAcdMax}'),
        label: 'out_acd_max',
        value: plan.outAcdMax,
        onChanged: (v) => controller.updateIncomingGeneration(outAcdMax: v),
      ),
      IntField(
        key: ValueKey('outInAns-${plan.id}-${plan.outInAns}'),
        label: 'out_in_ans',
        value: plan.outInAns,
        onChanged: (v) => controller.updateIncomingGeneration(outInAns: v),
      ),
      BoolField(
          label: 'forwarding',
          value: plan.forwarding,
          onChanged: (v) => controller.updateIncomingGeneration(forwarding: v)),
      BoolField(
          label: 'conn',
          value: plan.conn,
          onChanged: (v) => controller.updateIncomingGeneration(conn: v)),
      BoolField(
          label: 'rand',
          value: plan.rand,
          onChanged: (v) => controller.updateIncomingGeneration(rand: v)),
      BoolField(
          label: 'in_wait',
          value: plan.inWait,
          onChanged: (v) => controller.updateIncomingGeneration(inWait: v)),
      BoolField(
          label: 'in_sound',
          value: plan.inSound,
          onChanged: (v) => controller.updateIncomingGeneration(inSound: v)),
    ]);
  }
}
