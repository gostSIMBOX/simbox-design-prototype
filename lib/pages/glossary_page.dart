import 'package:flutter/material.dart';
import '../data/glossary_catalog.dart';
import '../data/terminology.dart';
import '../design/tokens.dart';

class GlossaryPage extends StatelessWidget {
  const GlossaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.radiusCard),
            boxShadow: T.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Глоссарий GostSimBox', style: T.screenTitle),
              const SizedBox(height: 6),
              Text(
                'Термины legacy-протокола, таблиц и маршрутизации. Формулы и raw-коды не переводятся.',
                style: T.caption.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final group in glossaryCatalog) ...[
          _GlossaryGroupCard(group: group),
          const SizedBox(height: 18),
        ],
      ]),
    );
  }
}

class _GlossaryGroupCard extends StatelessWidget {
  final GlossaryGroup group;
  const _GlossaryGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.radiusCard),
        boxShadow: T.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: T.hairline)),
          ),
          child: Text(group.title, style: T.panelTitle),
        ),
        for (var index = 0; index < group.termIds.length; index++)
          _GlossaryRow(
            term: termById(group.termIds[index]),
            showDivider: index != group.termIds.length - 1,
          ),
      ]),
    );
  }
}

class _GlossaryRow extends StatelessWidget {
  final TermDefinition term;
  final bool showDivider;
  const _GlossaryRow({required this.term, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final title = resolveLocalized(term.shortLabel, locale: 'ru');
    final body =
        resolveLocalized(term.definition ?? term.tooltip, locale: 'ru');
    final aliases = term.aliases.join(' · ');

    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 620;
      final details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(body, style: T.body.copyWith(height: 1.45)),
          if (term.formula != null) ...[
            const SizedBox(height: 5),
            Text(term.formula!, style: T.mono),
          ],
          if (aliases.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Raw / aliases: $aliases', style: T.cellSub),
          ],
          if (term.confidence == TermConfidence.unresolved) ...[
            const SizedBox(height: 4),
            Text('Значение не установлено по доступному исходному коду',
                style: T.cellAlarm),
          ],
        ],
      );
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: T.hairline))
              : null,
        ),
        child: narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: T.panelTitle),
                  const SizedBox(height: 6),
                  details,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 230, child: Text(title, style: T.panelTitle)),
                  const SizedBox(width: 18),
                  Expanded(child: details),
                ],
              ),
      );
    });
  }
}
