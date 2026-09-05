class GlossaryGroup {
  final String title;
  final List<String> termIds;

  const GlossaryGroup(this.title, this.termIds);
}

const glossaryCatalog = <GlossaryGroup>[
  GlossaryGroup('Метрики и классификация Number B', [
    'call.number_b',
    'metric.acd',
    'metric.asr',
    'qos.goo',
    'qos.vip',
    'qos.nor',
    'qos.bad',
    'qos.new',
    'qos.nos',
    'qos.nec',
    'qos.ne0',
    'qos.nem',
  ]),
  GlossaryGroup('Связь SIM с номером', [
    'im.ima',
    'im.imb',
    'im.imc',
    'im.imd',
    'im.ime',
    'im.imn',
  ]),
  GlossaryGroup('Звонок и завершение соединения', [
    'call.sou',
    'call.end_party',
    'call.end.us',
    'call.end.remote',
    'call.end.network',
    'incoming.recency.very',
    'incoming.recency.fast',
    'incoming.recency.slow',
    'incoming.recency.never',
  ]),
  GlossaryGroup('Команды MAY, MON и MSM', [
    'call.special.short_beacon',
    'command.callback_request',
    'command.balance_topup_request',
    'command.callback_sms_fallback',
  ]),
  GlossaryGroup('Модем, SIM и сеть', [
    'modem.cfun.1',
    'modem.cfun.4',
    'modem.cfun.5',
    'modem.cfun.6',
    'sim.state.0',
    'sim.state.1',
    'sim.state.4',
    'sim.pin_required',
    'sim.state.255',
    'network.state.0',
    'network.state.1',
    'network.state.2',
    'network.state.no_valid_sim',
  ]),
];
