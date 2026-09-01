import 'package:flutter/material.dart';
import '../data/mock.dart';
import '../design/tokens.dart';
import '../state/app_state.dart';
import '../widgets/panel.dart';

class ProcPage extends StatelessWidget {
  const ProcPage({super.key});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        title: 'Процессы',
        icon: 'conn.png',
        width: 400,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final a in procActions) ...[
            AdmButton(a.label,
                icon: a.icon,
                tooltip: a.cmd,
                expand: true,
                onPressed: () {
                  st.push(a.cmd, a.output);
                  st.showToast(a.label, 'conn.png');
                }),
            const SizedBox(height: 9),
          ],
          AdmButton('Перезапуск операционки',
              icon: 'stop.png',
              danger: true,
              expand: true,
              onPressed: () => confirmDialog(
                    context,
                    title: 'Перезапуск операционки',
                    text: 'Все звонки будут разорваны, панель станет недоступна '
                        'примерно на 2 минуты.',
                    cmd: '/usr/simbox/actions/reboot.sh',
                    onOk: () {
                      st.push('/usr/simbox/actions/reboot.sh',
                          const ['Broadcast message: system is going down for reboot NOW']);
                      st.showToast('Перезагрузка запущена', 'stop.png');
                    },
                  )),
          const SizedBox(height: 12),
          Text('Если не приходят SMS/USSD — почистить SMS и перезагрузить свистки.',
              style: T.caption),
        ]),
      ),
      ]),
    );
  }
}

Future<void> confirmDialog(
  BuildContext context, {
  required String title,
  required String text,
  required String cmd,
  required VoidCallback onOk,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: T.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.warning_amber_rounded, size: 20, color: T.danger),
        const SizedBox(width: 10),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: T.ink))),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: T.body.copyWith(height: 1.55, color: const Color(0xFF546675))),
            const SizedBox(height: 8),
            Text(cmd, style: T.mono.copyWith(color: T.fg2)),
          ]),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      actions: [
        AdmButton('Отмена', onPressed: () => Navigator.of(ctx).pop()),
        AdmButton('Выполнить',
            primary: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              onOk();
            }),
      ],
    ),
  );
}
