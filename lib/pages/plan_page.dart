import 'package:flutter/material.dart';
import '../features/plans/workspace.dart';
import '../state/app_state.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(22),
      child: PlansWorkspace(
        controller: state.plans,
        zones: state.zones,
        commandSets: state.commandSets.records,
      ),
    );
  }
}
