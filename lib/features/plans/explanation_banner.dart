import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../widgets/fugue_icon.dart';
import 'controller.dart';

/// Dismissible explanation banner — exact verbatim copy from Requirements'
/// Explanation Banner section, not paraphrased. Session-lifetime state lives
/// on [PlanController.explanationOpen] (Requirements #25-27).
class ExplanationBanner extends StatelessWidget {
  final PlanController controller;
  const ExplanationBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
            color: T.surface, borderRadius: BorderRadius.circular(T.radiusCard), boxShadow: T.shadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const FugueIcon('information.png'),
            const SizedBox(width: 8),
            const Expanded(child: Text('Пояснение', style: T.panelTitle)),
            IconButton(
              tooltip: 'Скрыть пояснение',
              constraints: const BoxConstraints.tightFor(width: T.denseHit, height: T.denseHit),
              onPressed: controller.toggleExplanation,
              icon: const FugueIcon('cross.png', semanticLabel: 'Скрыть пояснение'),
            ),
          ]),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4, right: 8),
            child: Text(
              'Планы нужны для 2 целей: 1) автоматизация хитрых запросов (например, вместо '
              '*100# — кнопка Get balance); 2) групповая установка параметров симок. Допустимо '
              'использовать план default для любых симок, экспериментов и новых операторов.\n\n'
              'time_wake / time_sleep — когда симка спит/просыпается (час), минуты выбираются '
              'алгоритмом индивидуально для каждой симки. Если значение не в [0;23] — расписание '
              'выключено.\n\n'
              'Пауза между звонками: diff_slow — гарантированная пауза в любом случае; diff_min — '
              'пауза на все звонки; пауза на симку берётся как min(diff_min; diff_min_out если '
              'GOO).\n\n'
              'После изменения плана нужно выбрать симки на вкладке «Симки» и нажать '
              '«Восстановить параметры плана».',
              style: T.body,
            ),
          ),
        ]),
      );
}

/// "?" affordance shown next to the page title when the banner is dismissed.
class ExplanationReopenButton extends StatelessWidget {
  final PlanController controller;
  const ExplanationReopenButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Показать пояснение',
        constraints: const BoxConstraints.tightFor(width: T.denseHit, height: T.denseHit),
        onPressed: controller.toggleExplanation,
        icon: const FugueIcon('information.png', semanticLabel: 'Показать пояснение'),
      );
}
