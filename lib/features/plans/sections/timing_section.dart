import 'package:flutter/material.dart';
import '../controller.dart';
import 'section_fields.dart';

class TimingSection extends StatelessWidget {
  final PlanController controller;
  const TimingSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected!;
    return PolicySection(title: 'Тайминги и расписание', children: [
      IntField(
        key: ValueKey('diffSlow-${plan.id}-${plan.diffSlow}'),
        label: 'diff_slow',
        value: plan.diffSlow,
        onChanged: (v) => controller.updateTiming(diffSlow: v),
      ),
      IntField(
        key: ValueKey('diffMin-${plan.id}-${plan.diffMin}'),
        label: 'diff_min',
        value: plan.diffMin,
        onChanged: (v) => controller.updateTiming(diffMin: v),
      ),
      IntField(
        key: ValueKey('diffMinOut-${plan.id}-${plan.diffMinOut}'),
        label: 'diff_min_out',
        value: plan.diffMinOut,
        onChanged: (v) => controller.updateTiming(diffMinOut: v),
      ),
      NullableHourField(
        key: ValueKey('timeWake-${plan.id}-${plan.timeWake}'),
        label: 'time_wake',
        value: plan.timeWake,
        onChanged: (v) =>
            controller.updateTiming(timeWake: v, clearTimeWake: v == null),
      ),
      NullableHourField(
        key: ValueKey('timeSleep-${plan.id}-${plan.timeSleep}'),
        label: 'time_sleep',
        value: plan.timeSleep,
        onChanged: (v) =>
            controller.updateTiming(timeSleep: v, clearTimeSleep: v == null),
      ),
      NullableHourField(
        key: ValueKey('timeWorkWake-${plan.id}-${plan.timeWorkWake}'),
        label: 'time_work_wake',
        value: plan.timeWorkWake,
        onChanged: (v) => controller.updateTiming(
            timeWorkWake: v, clearTimeWorkWake: v == null),
      ),
      NullableHourField(
        key: ValueKey('timeWorkSleep-${plan.id}-${plan.timeWorkSleep}'),
        label: 'time_work_sleep',
        value: plan.timeWorkSleep,
        onChanged: (v) => controller.updateTiming(
            timeWorkSleep: v, clearTimeWorkSleep: v == null),
      ),
      NullableHourField(
        key: ValueKey('timeHolidayWake-${plan.id}-${plan.timeHolidayWake}'),
        label: 'time_holiday_wake',
        value: plan.timeHolidayWake,
        onChanged: (v) => controller.updateTiming(
            timeHolidayWake: v, clearTimeHolidayWake: v == null),
      ),
      NullableHourField(
        key: ValueKey('timeHolidaySleep-${plan.id}-${plan.timeHolidaySleep}'),
        label: 'time_holiday_sleep',
        value: plan.timeHolidaySleep,
        onChanged: (v) => controller.updateTiming(
            timeHolidaySleep: v, clearTimeHolidaySleep: v == null),
      ),
    ]);
  }
}
