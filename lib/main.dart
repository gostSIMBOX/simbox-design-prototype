import 'package:flutter/material.dart';
import 'design/tokens.dart';
import 'state/app_state.dart';
import 'widgets/adm_icon.dart';
import 'widgets/command_log.dart';
import 'widgets/top_bar.dart';
import 'pages/sims_page.dart';
import 'pages/dongles_page.dart';
import 'pages/diagmode_page.dart';
import 'pages/hubs_page.dart';
import 'pages/nabor_page.dart';
import 'pages/plan_page.dart';
import 'pages/proc_page.dart';
import 'pages/billing_page.dart';
import 'pages/upgrade_page.dart';
import 'pages/debug_page.dart';
import 'pages/icons_page.dart';

void main() => runApp(const SimBoxApp());

class SimBoxApp extends StatefulWidget {
  const SimBoxApp({super.key});
  @override
  State<SimBoxApp> createState() => _SimBoxAppState();
}

class _SimBoxAppState extends State<SimBoxApp> {
  final AppState state = AppState();

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
        state: state,
        child: MaterialApp(
          title: 'SimBox Adminka',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          home: const AdminShell(),
        ),
      );
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AppState? _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = AppScope.of(context);
    if (identical(s, _state)) return;
    _state?.toast.removeListener(_onToast);
    _state = s;
    s.toast.addListener(_onToast);
  }

  @override
  void dispose() {
    _state?.toast.removeListener(_onToast);
    super.dispose();
  }

  void _onToast() {
    final t = _state?.toast.value;
    if (t == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        backgroundColor: T.ink,
        behavior: SnackBarBehavior.floating,
        width: 360,
        duration: const Duration(milliseconds: 2400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(mainAxisSize: MainAxisSize.min, children: [
          AdmIcon(t.icon),
          const SizedBox(width: 10),
          Flexible(
              child: Text(t.text,
                  style: const TextStyle(
                      fontFamily: 'SF Pro Text', fontSize: 13, color: Colors.white))),
        ]),
      ));
  }

  Widget _page(AdmPage p) => switch (p) {
        AdmPage.sim => const SimsPage(),
        AdmPage.dongle => const DonglesPage(),
        AdmPage.diagmode => const DiagmodePage(),
        AdmPage.hubs => const HubsPage(),
        AdmPage.nabor => const NaborPage(),
        AdmPage.plan => const PlanPage(),
        AdmPage.proc => const ProcPage(),
        AdmPage.bablo => const BillingPage(),
        AdmPage.upgrade => const UpgradePage(),
        AdmPage.debug => const DebugPage(),
        AdmPage.icons => const IconsPage(),
      };

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: T.bg,
      body: Column(children: [
        const TopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: _page(s.page),
          ),
        ),
        const CommandLog(),
      ]),
    );
  }
}
