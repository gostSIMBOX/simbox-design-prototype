import 'package:flutter/material.dart';
import '../features/zones/workspace.dart';
import '../state/app_state.dart';

class ZonesPage extends StatelessWidget {
  const ZonesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).zones;
    return Padding(
      padding: const EdgeInsets.all(22),
      child: ZonesWorkspace(controller: controller),
    );
  }
}
