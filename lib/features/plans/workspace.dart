import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import '../command_sets/models.dart';
import '../zones/controller.dart';
import 'controller.dart';
import 'detail_header.dart';
import 'directions_section.dart';
import 'explanation_banner.dart';
import 'registry_pane.dart';
import 'sections/call_modes_section.dart';
import 'sections/capacity_section.dart';
import 'sections/incoming_generation_section.dart';
import 'sections/sms_generation_section.dart';
import 'sections/timing_section.dart';

class PlansWorkspace extends StatelessWidget {
  final PlanController controller;
  final ZoneController zones;
  final List<CommandSet> commandSets;
  const PlansWorkspace({
    super.key,
    required this.controller,
    required this.zones,
    required this.commandSets,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.loadState == PlanLoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.loadState == PlanLoadState.error) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const FugueIcon('exclamation.png'),
        const SizedBox(height: 8),
        Text(controller.errorMessage ?? 'Не удалось загрузить планы.', style: T.body),
        const SizedBox(height: 8),
        TextButton(onPressed: controller.load, child: const Text('Повторить')),
      ]));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          const Expanded(child: Text('Планы', style: T.screenTitle)),
          if (!controller.explanationOpen) ExplanationReopenButton(controller: controller),
        ]),
      ),
      if (controller.explanationOpen) ExplanationBanner(controller: controller),
      Expanded(
        child: LayoutBuilder(builder: (context, constraints) {
          final narrow = constraints.maxWidth < 900;
          final detail = _DetailPane(controller: controller, zones: zones, commandSets: commandSets, narrow: narrow);
          if (narrow) {
            return Column(children: [
              PlanRegistryPane(controller: controller, commandSets: commandSets, compact: true),
              const SizedBox(height: 12),
              Expanded(child: detail),
            ]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            PlanRegistryPane(controller: controller, commandSets: commandSets),
            const SizedBox(width: 16),
            Expanded(child: detail),
          ]);
        }),
      ),
    ]);
  }
}

class _DetailPane extends StatelessWidget {
  final PlanController controller;
  final ZoneController zones;
  final List<CommandSet> commandSets;
  final bool narrow;
  const _DetailPane({
    required this.controller,
    required this.zones,
    required this.commandSets,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    final plan = controller.selected;
    if (plan == null) {
      return Container(
        decoration: BoxDecoration(
            color: T.surface, borderRadius: BorderRadius.circular(T.radiusCard), boxShadow: T.shadow),
        child: const Center(child: Text('Выберите план', style: T.caption)),
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: T.surface, borderRadius: BorderRadius.circular(T.radiusCard), boxShadow: T.shadow),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        PlanDetailHeader(controller: controller, commandSets: commandSets, narrow: narrow),
        Expanded(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              CapacitySection(controller: controller),
              CallModesSection(controller: controller),
              TimingSection(controller: controller),
              DirectionsSection(controller: controller, zones: zones),
              IncomingGenerationSection(controller: controller),
              SmsGenerationSection(controller: controller),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        if (controller.isDirty) _DraftBar(controller: controller, narrow: narrow),
      ]),
    );
  }
}

class _DraftBar extends StatelessWidget {
  final PlanController controller;
  final bool narrow;
  const _DraftBar({required this.controller, required this.narrow});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 16, vertical: 8),
        decoration: const BoxDecoration(color: T.surface, border: Border(top: BorderSide(color: T.hairline))),
        child: Row(children: [
          const FugueIcon('information.png'),
          const SizedBox(width: 8),
          if (!narrow) const Text('Есть несохранённые изменения', style: T.caption),
          const Spacer(),
          TextButton.icon(
              onPressed: controller.cancelDraft,
              icon: const FugueIcon('cross.png'),
              label: const Text('Отмена')),
          const SizedBox(width: 8),
          _GradientSaveButton(onPressed: () {
            controller.save();
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(const SnackBar(
              content: Row(children: [
                FugueIcon('tick.png'),
                SizedBox(width: 8),
                Text('План сохранён'),
              ]),
              behavior: SnackBarBehavior.floating,
            ));
          }),
        ]),
      );
}

class _GradientSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientSaveButton({required this.onPressed});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration:
            BoxDecoration(gradient: T.brandGradient, borderRadius: BorderRadius.circular(T.radiusCtl)),
        child: TextButton.icon(
          style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size(96, T.denseHit),
              padding: const EdgeInsets.symmetric(horizontal: 12)),
          onPressed: onPressed,
          icon: const FugueIcon('disk.png'),
          label: const Text('Сохранить'),
        ),
      );
}
