import 'package:flutter/material.dart';
import '../features/command_sets/workspace.dart';
import '../state/app_state.dart';

class NaborPage extends StatelessWidget {
  const NaborPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).commandSets;
    return Padding(
      padding: const EdgeInsets.all(22),
      child: CommandSetsWorkspace(controller: controller),
    );
  }
}
