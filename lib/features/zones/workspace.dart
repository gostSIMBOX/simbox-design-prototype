import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'code_editor.dart';
import 'controller.dart';
import 'detail_header.dart';
import 'group_rules_editor.dart';
import 'registry_pane.dart';

class ZonesWorkspace extends StatelessWidget {
  final ZoneController controller;
  const ZonesWorkspace({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.loadState == ZoneLoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.loadState == ZoneLoadState.error) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const FugueIcon('exclamation.png'),
        const SizedBox(height: 8),
        Text(controller.errorMessage ?? 'Не удалось загрузить направления.',
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
          ZoneRegistryPane(controller: controller, compact: true),
          const SizedBox(height: 12),
          Expanded(child: detail),
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ZoneRegistryPane(controller: controller),
        const SizedBox(width: 16),
        Expanded(child: detail),
      ]);
    });
  }
}

class _DetailPane extends StatelessWidget {
  final ZoneController controller;
  final bool narrow;
  const _DetailPane({required this.controller, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final zone = controller.selected;
    if (zone == null) {
      return Container(
        decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.radiusCard),
            boxShadow: T.shadow),
        child:
            const Center(child: Text('Выберите направление', style: T.caption)),
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.radiusCard),
          boxShadow: T.shadow),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ZoneDetailHeader(controller: controller, narrow: narrow),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                      height: 280,
                      child: ZoneCodeEditor(controller: controller)),
                  GroupRulesEditor(controller: controller),
                ]),
          ),
        ),
        if (controller.isDirty)
          _DraftBar(controller: controller, narrow: narrow),
      ]),
    );
  }
}

class _DraftBar extends StatelessWidget {
  final ZoneController controller;
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
            controller.save();
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(const SnackBar(
              content: Row(children: [
                FugueIcon('tick.png'),
                SizedBox(width: 8),
                Text('Направление сохранено'),
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
