import 'package:flutter/material.dart';
import '../data/mock.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import '../widgets/panel.dart';
import 'proc_page.dart' show confirmDialog;

class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Panel(
          title: 'Обновление',
          icon: 'power.png',
          width: 400,
          padding: EdgeInsets.zero,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: T.hairline))),
              child: Text(
                'parent: 412:8f3c1a2+ tip\n'
                "branch 'default'\n"
                'M www/simbox/plan.php\n'
                '? /tmp/exec.log',
                style: T.monoDim.copyWith(color: const Color(0xFF546675)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdmButton('Обновить полностью',
                        primary: true,
                        expand: true,
                        onPressed: () => confirmDialog(
                              context,
                              title: 'Обновить полностью',
                              text:
                                  'Будет выполнен pull, компиляция и перезапуск софта.',
                              cmd:
                                  'cd /usr/simbox && hg pull -u && make && reload.sh',
                              onOk: () {
                                st.push(
                                    'cd /usr/simbox && hg pull -u && make && /usr/simbox/actions/reload.sh',
                                    const [
                                      'pulling…',
                                      '2 files updated',
                                      'make: ok',
                                      'asterisk restarted'
                                    ]);
                                st.showToast(
                                    'Обновление выполнено', 'power.png');
                              },
                            )),
                    const SizedBox(height: 9),
                    for (final a in upgradeActions) ...[
                      AdmButton(a.label,
                          icon: a.icon,
                          tooltip: a.cmd,
                          expand: true, onPressed: () {
                        st.push(a.cmd, a.output);
                        st.showToast(a.label, 'conn.png');
                      }),
                      const SizedBox(height: 9),
                    ],
                  ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
