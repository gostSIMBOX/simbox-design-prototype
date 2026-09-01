import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../widgets/panel.dart';

const _blocks = <List<String>>[
  [
    'sysdevs',
    'ttyUSB0 dongle0 E1550\n'
        'ttyUSB2 dongle1 E173\n'
        'ttyUSB4 dongle2 E1550\n'
        'ttyUSB6 dongle3 E1550'
  ],
  [
    'usbdevs',
    'Bus 002 Device 003: ID 12d1:1506 Huawei E1550\n'
        'Bus 002 Device 004: ID 12d1:1c05 Huawei E173\n'
        'Bus 002 Device 005: ID 1a40:0101 TERMINUS hub'
  ],
];

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Wrap(spacing: 18, runSpacing: 18, children: [
        for (final b in _blocks)
          Panel(
            title: b[0],
            width: 460,
            child: SelectableText(b[1],
                style: T.monoDim.copyWith(color: const Color(0xFF546675))),
          ),
      ]),
    );
  }
}
