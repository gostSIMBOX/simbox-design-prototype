import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../zones/code_editor.dart';
import '../zones/controller.dart';
import '../zones/models.dart';
import 'controller.dart';
import 'models.dart';
import 'sections/section_fields.dart';

/// Read-only route context for a plan's direction slot: every [GroupRule] in
/// [zones] whose `limitSlot` matches, restricted to zones that belong to
/// [commandSetId]'s operator/region (matched by the shared `<operator>_<region>`
/// naming convention both features use — see 03-specifications.md's Resolved
/// Design Decisions). Never mutates Zones data; purely a live projection.
List<({Zone zone, GroupRule rule})> routesForSlot(
  ZoneController zones,
  String commandSetId,
  int slot,
) =>
    [
      for (final zone in zones.records)
        if (_belongsToCommandSet(zone, commandSetId))
          for (final rule in zone.groupRules)
            if (rule.limitSlot == slot) (zone: zone, rule: rule),
    ];

bool _belongsToCommandSet(Zone zone, String commandSetId) =>
    zone.id == commandSetId ||
    zone.id.startsWith('${commandSetId}_') ||
    commandSetId.startsWith('${zone.id}_');

class DirectionsSection extends StatelessWidget {
  final PlanController controller;
  final ZoneController zones;
  const DirectionsSection({super.key, required this.controller, required this.zones});

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected!;
    return PolicySection(title: 'Направления', children: [
      SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final slot in plan.directions)
              slot.editable
                  ? _EditableSlotRow(controller: controller, zones: zones, plan: plan, slot: slot)
                  : _CompatibilitySlotRow(slot: slot),
          ],
        ),
      ),
    ]);
  }
}

class _EditableSlotRow extends StatelessWidget {
  final PlanController controller;
  final ZoneController zones;
  final Plan plan;
  final DirectionSlot slot;
  const _EditableSlotRow(
      {required this.controller, required this.zones, required this.plan, required this.slot});

  @override
  Widget build(BuildContext context) {
    final routes = routesForSlot(zones, plan.commandSetId, slot.slot);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Слот L${slot.slot}', style: T.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(spacing: 12, runSpacing: 8, children: [
          IntField(
            key: ValueKey('alg-${plan.id}-${slot.slot}-${slot.alg}'),
            label: 'алгоритм',
            value: slot.alg,
            onChanged: (v) => controller.updateDirectionSlot(slot.slot, alg: v),
          ),
          BoolField(
            label: 'не учитывать различие',
            value: slot.nodiff,
            onChanged: (v) => controller.updateDirectionSlot(slot.slot, nodiff: v),
          ),
          IntField(
            key: ValueKey('limitSoft-${plan.id}-${slot.slot}-${slot.limitSoft}'),
            label: 'мягкий лимит',
            value: slot.limitSoft,
            onChanged: (v) => controller.updateDirectionSlot(slot.slot, limitSoft: v),
          ),
          IntField(
            key: ValueKey('limitHard-${plan.id}-${slot.slot}-${slot.limitHard}'),
            label: 'жёсткий лимит',
            value: slot.limitHard,
            onChanged: (v) => controller.updateDirectionSlot(slot.slot, limitHard: v),
          ),
        ]),
        const SizedBox(height: 6),
        Text('Маршруты, использующие этот слот (из Направления):', style: T.cellSub),
        const SizedBox(height: 4),
        if (routes.isEmpty)
          Text('нет данных для этого набора команд', style: T.caption)
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final route in routes.take(6))
                Chip(
                  avatar: ZoneIcon(route.zone, size: 14),
                  label: Text('${route.zone.name} · ${route.zone.billingCode ?? ''}${route.rule.group}',
                      style: T.cellSub),
                  visualDensity: VisualDensity.compact,
                ),
              if (routes.length > 6)
                ActionChip(
                  label: Text('показать все ${routes.length}', style: T.cellSub),
                  onPressed: () => _showAllRoutes(context, plan.id, slot.slot, routes),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
      ]),
    );
  }

  void _showAllRoutes(
      BuildContext context, String planId, int slot, List<({Zone zone, GroupRule rule})> routes) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Маршруты слота L$slot'),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final route in routes)
                ListTile(
                  dense: true,
                  leading: ZoneIcon(route.zone, size: 16),
                  title: Text(route.zone.name),
                  subtitle: Text('${route.zone.billingCode ?? ''}${route.rule.group}'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
        ],
      ),
    );
  }
}

class _CompatibilitySlotRow extends StatelessWidget {
  final DirectionSlot slot;
  const _CompatibilitySlotRow({required this.slot});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '⚠ Слот L${slot.slot} — совместимость, не редактируется как обычное направление',
          style: T.caption,
        ),
      );
}
