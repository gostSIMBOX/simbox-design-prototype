import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'commands_section.dart';
import 'controller.dart';
import 'detail_header.dart';
import 'models.dart';
import 'registry_pane.dart';
import 'response_rules_section.dart';

class CommandSetsWorkspace extends StatelessWidget {
  final CommandSetController controller;
  const CommandSetsWorkspace({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.loadState == CommandSetLoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.loadState == CommandSetLoadState.error) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const FugueIcon('exclamation.png'),
        const SizedBox(height: 8),
        Text(controller.errorMessage ?? 'Не удалось загрузить наборы.',
            style: T.body),
        const SizedBox(height: 8),
        TextButton(onPressed: controller.load, child: const Text('Повторить')),
      ]));
    }
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 900;
      final detail = _DetailPane(controller: controller, narrow: narrow);
      if (narrow) {
        return Column(children: [
          CommandSetRegistryPane(controller: controller, compact: true),
          const SizedBox(height: 12),
          Expanded(child: detail),
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CommandSetRegistryPane(controller: controller),
        const SizedBox(width: 16),
        Expanded(child: detail),
      ]);
    });
  }
}

class _DetailPane extends StatelessWidget {
  final CommandSetController controller;
  final bool narrow;
  const _DetailPane({required this.controller, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final set = controller.selected;
    if (set == null) {
      return Container(
        decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.radiusCard),
            boxShadow: T.shadow),
        child: const Center(
            child: Text('Выберите набор команд', style: T.caption)),
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.radiusCard),
          boxShadow: T.shadow),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CommandSetDetailHeader(controller: controller, narrow: narrow),
        Padding(
          padding:
              EdgeInsets.fromLTRB(narrow ? 10 : 16, 8, narrow ? 10 : 16, 8),
          child: SegmentedButton<CommandSetSection>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                  value: CommandSetSection.commands,
                  icon: const FugueIcon('application-task.png'),
                  label: Text('Команды ${set.commands.length}')),
              ButtonSegment(
                  value: CommandSetSection.responseRules,
                  icon: const FugueIcon('funnel--pencil.png'),
                  label: Text('Правила ответов ${set.responseRules.length}')),
            ],
            selected: {controller.section},
            onSelectionChanged: (value) =>
                controller.selectSection(value.first),
          ),
        ),
        const Divider(height: 1, color: T.hairline),
        Expanded(
            child: controller.section == CommandSetSection.commands
                ? CommandsSection(controller: controller, narrow: narrow)
                : ResponseRulesSection(controller: controller, narrow: narrow)),
        if (controller.isDirty)
          _DraftBar(controller: controller, narrow: narrow),
      ]),
    );
  }
}

class _DraftBar extends StatelessWidget {
  final CommandSetController controller;
  final bool narrow;
  const _DraftBar({required this.controller, required this.narrow});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            EdgeInsets.symmetric(horizontal: narrow ? 12 : 16, vertical: 8),
        decoration: const BoxDecoration(
            color: T.surface,
            border: Border(top: BorderSide(color: T.hairline))),
        child: Row(children: [
          const FugueIcon('information.png'),
          const SizedBox(width: 8),
          if (!narrow)
            const Text('Есть несохранённые изменения', style: T.caption),
          const Spacer(),
          TextButton.icon(
              onPressed: controller.cancelDraft,
              icon: const FugueIcon('cross.png'),
              label: const Text('Отмена')),
          const SizedBox(width: 8),
          _GradientSaveButton(onPressed: () {
            final result = controller.save();
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(SnackBar(
              content: Row(children: [
                FugueIcon(result.isValid ? 'tick.png' : 'exclamation.png'),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(result.isValid
                        ? 'Набор сохранён'
                        : result.issues.first.message)),
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
        decoration: BoxDecoration(
            gradient: T.brandGradient,
            borderRadius: BorderRadius.circular(T.radiusCtl)),
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
