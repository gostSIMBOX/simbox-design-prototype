import 'package:flutter/material.dart';
import '../controller.dart';
import 'section_fields.dart';

class SmsGenerationSection extends StatelessWidget {
  final PlanController controller;
  const SmsGenerationSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected!;
    return PolicySection(title: 'SMS и MAY/MON/MSM', children: [
      IntField(
        key: ValueKey('mayLimit-${plan.id}-${plan.mayLimit}'),
        label: 'may_limit',
        value: plan.mayLimit,
        onChanged: (v) => controller.updateSmsGeneration(mayLimit: v),
      ),
      IntField(
        key: ValueKey('monLimit-${plan.id}-${plan.monLimit}'),
        label: 'mon_limit',
        value: plan.monLimit,
        onChanged: (v) => controller.updateSmsGeneration(monLimit: v),
      ),
      IntField(
        key: ValueKey('msmLimit-${plan.id}-${plan.msmLimit}'),
        label: 'msm_limit',
        value: plan.msmLimit,
        onChanged: (v) => controller.updateSmsGeneration(msmLimit: v),
      ),
      IntField(
        key: ValueKey('smsoutSoft-${plan.id}-${plan.smsoutSoft}'),
        label: 'smsout_soft',
        value: plan.smsoutSoft,
        onChanged: (v) => controller.updateSmsGeneration(smsoutSoft: v),
      ),
      IntField(
        key: ValueKey('smsoutHard-${plan.id}-${plan.smsoutHard}'),
        label: 'smsout_hard',
        value: plan.smsoutHard,
        onChanged: (v) => controller.updateSmsGeneration(smsoutHard: v),
      ),
      IntField(
        key: ValueKey('sattSoft-${plan.id}-${plan.sattSoft}'),
        label: 'satt_soft',
        value: plan.sattSoft,
        onChanged: (v) => controller.updateSmsGeneration(sattSoft: v),
      ),
      IntField(
        key: ValueKey('sattHard-${plan.id}-${plan.sattHard}'),
        label: 'satt_hard',
        value: plan.sattHard,
        onChanged: (v) => controller.updateSmsGeneration(sattHard: v),
      ),
      IntField(
        key: ValueKey('sattSoftDay-${plan.id}-${plan.sattSoftDay}'),
        label: 'satt_soft_day',
        value: plan.sattSoftDay,
        onChanged: (v) => controller.updateSmsGeneration(sattSoftDay: v),
      ),
      IntField(
        key: ValueKey('sattHardDay-${plan.id}-${plan.sattHardDay}'),
        label: 'satt_hard_day',
        value: plan.sattHardDay,
        onChanged: (v) => controller.updateSmsGeneration(sattHardDay: v),
      ),
      IntField(
        key: ValueKey('sattSoftTotal-${plan.id}-${plan.sattSoftTotal}'),
        label: 'satt_soft_total',
        value: plan.sattSoftTotal,
        onChanged: (v) => controller.updateSmsGeneration(sattSoftTotal: v),
      ),
      IntField(
        key: ValueKey('sattHardTotal-${plan.id}-${plan.sattHardTotal}'),
        label: 'satt_hard_total',
        value: plan.sattHardTotal,
        onChanged: (v) => controller.updateSmsGeneration(sattHardTotal: v),
      ),
      IntField(
        key: ValueKey('nospam-${plan.id}-${plan.nospam}'),
        label: 'nospam',
        value: plan.nospam,
        onChanged: (v) => controller.updateSmsGeneration(nospam: v),
      ),
    ]);
  }
}
