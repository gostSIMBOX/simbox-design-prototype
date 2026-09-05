typedef LocalizedText = Map<String, String>;

enum TermConfidence { confirmed, derived, historical, unresolved }

class TermDefinition {
  final String id;
  final LocalizedText shortLabel;
  final LocalizedText tooltip;
  final LocalizedText? definition;
  final String? formula;
  final List<String> aliases;
  final TermConfidence confidence;

  const TermDefinition({
    required this.id,
    required this.shortLabel,
    required this.tooltip,
    this.definition,
    this.formula,
    this.aliases = const [],
    this.confidence = TermConfidence.confirmed,
  });
}

const supportedLocales = <String>['en', 'th', 'ru', 'hi', 'zh'];

String resolveLocalized(LocalizedText text, {String locale = 'en'}) =>
    text[locale] ?? text['en'] ?? '[missing translation]';

LocalizedText _text(String en, String ru) => {
      'en': en,
      'th': en,
      'ru': ru,
      'hi': en,
      'zh': en,
    };

TermDefinition _term(
  String id,
  String en,
  String ru, {
  String? tooltipRu,
  String? definitionRu,
  String? formula,
  List<String> aliases = const [],
  TermConfidence confidence = TermConfidence.confirmed,
}) =>
    TermDefinition(
      id: id,
      shortLabel: _text(en, ru),
      tooltip: _text(en, tooltipRu ?? ru),
      definition: definitionRu == null ? null : _text(en, definitionRu),
      formula: formula,
      aliases: aliases,
      confidence: confidence,
    );

final terminology = <String, TermDefinition>{
  'metric.acd': _term(
    'metric.acd',
    'Average Call Duration',
    'Средняя длительность соединения',
    tooltipRu: 'Средняя длительность отвеченных соединений по Number B.',
    definitionRu:
        'Суммарная длительность отвеченных соединений, делённая на количество отвеченных вызовов.',
    formula: 'ACD = total_billsec / total_answered',
    aliases: const ['ACD'],
  ),
  'metric.asr': _term(
    'metric.asr',
    'Answer-Seizure Ratio',
    'Доля отвеченных вызовов',
    tooltipRu: 'Процент отвеченных вызовов по Number B.',
    definitionRu:
        'Количество отвеченных вызовов, делённое на все попытки вызова, в процентах.',
    formula: 'ASR = total_answered / total_calls * 100',
    aliases: const ['ASR'],
  ),
  'call.number_b': _term(
    'call.number_b',
    'Number B',
    'Number B · вызываемый номер',
    tooltipRu:
        'Вызываемый номер, по которому simserver хранит агрегированную историю.',
    definitionRu:
        'Номер назначения вызова; ключ агрегатов total_calls, total_answered и total_billsec на simserver.',
  ),
  'qos.goo': _term(
    'qos.goo',
    'Good connection history',
    'Хорошая история соединений',
    tooltipRu: 'Серверный класс Number B: ACD ≥ 300 с и ASR ≥ 80%.',
    definitionRu:
        'Класс simserver для Number B с высокой средней длительностью и долей отвеченных вызовов. Границы включительные.',
    formula:
        'ACD = total_billsec / total_answered; ASR = total_answered / total_calls * 100; GOO = ACD >= 300 && ASR >= 80',
    aliases: const ['GOO', 'GOO_ACD=300', 'GOO_ASR=80'],
  ),
  'qos.vip': _term('qos.vip', 'Trusted source', 'Доверенный источник'),
  'qos.nor':
      _term('qos.nor', 'Known number, normal metrics', 'Нормальные показатели'),
  'qos.bad':
      _term('qos.bad', 'Known number, poor metrics', 'Плохие показатели'),
  'qos.new': _term('qos.new', 'Number outside history', 'Номер вне истории'),
  'qos.nos': _term('qos.nos', 'Server did not respond', 'Сервер не ответил'),
  'qos.rob':
      _term('qos.rob', 'Automation suspected', 'Подозрение на автоматизацию'),
  'qos.blo': _term('qos.blo', 'Enhanced blocking', 'Усиленная блокировка'),
  'qos.nec': _term('qos.nec', 'NEW + CAPTCHA passed', 'NEW + капча пройдена'),
  'qos.ne0': _term(
    'qos.ne0',
    'NE0 · historical code',
    'NE0 · исторический код',
    tooltipRu:
        'Producer NE0 в активном dialplan закомментирован; точное значение не установлено.',
    confidence: TermConfidence.unresolved,
  ),
  'qos.nem': _term(
    'qos.nem',
    'NEM · historical code',
    'NEM · исторический код',
    tooltipRu:
        'Producer NEM в активном dialplan закомментирован; точное значение не установлено.',
    confidence: TermConfidence.unresolved,
  ),
  'incoming.recency.very': _term(
    'incoming.recency.very',
    'Previous connection very recent',
    'Предыдущее соединение очень недавно',
    tooltipRu:
        'Предыдущее соединение этого звонящего номера с этой принимающей SIM было менее 4 минут назад.',
    confidence: TermConfidence.derived,
  ),
  'incoming.recency.fast': _term(
    'incoming.recency.fast',
    'Previous connection recent',
    'Предыдущее соединение недавно',
    tooltipRu:
        'Предыдущее соединение этого звонящего номера с этой принимающей SIM было менее 30 минут назад.',
    confidence: TermConfidence.derived,
  ),
  'incoming.recency.slow': _term(
    'incoming.recency.slow',
    'Previous connection old',
    'Предыдущее соединение давно',
    tooltipRu:
        'Предыдущее соединение этого звонящего номера с этой принимающей SIM было 30 минут назад или раньше.',
    confidence: TermConfidence.derived,
  ),
  'incoming.recency.never': _term(
    'incoming.recency.never',
    'No previous connection',
    'Предыдущего соединения не было',
    tooltipRu:
        'Предыдущего соединения этого звонящего номера с этой принимающей SIM не было.',
    confidence: TermConfidence.derived,
  ),
  'call.sou': _term(
    'call.sou',
    'Internal call between managed SIMs',
    'Внутренний звонок между SIM',
    definitionRu:
        'Одна управляемая SIM звонит на другую управляемую SIM. Это не звонок SIM самой себе.',
    aliases: const ['SOU'],
  ),
  'call.sou.in': _term('call.sou.in', 'SIM-to-SIM receiving side',
      'SIM-to-SIM: принимающая сторона'),
  'call.sou.out': _term('call.sou.out', 'SIM-to-SIM initiating side',
      'SIM-to-SIM: инициирующая сторона'),
  'call.result.answer':
      _term('call.result.answer', 'Call answered', 'Звонок принят'),
  'call.result.no_answer': _term(
      'call.result.no_answer', 'No answer', 'Без ответа',
      tooltipRu: 'Звонок завершён без ответа вызываемого абонента.'),
  'call.live.ring': _term('call.live.ring', 'Ringback', 'Ringback',
      tooltipRu: 'Вызываемый абонент оповещается; слышен ringback.'),
  'call.live.wait':
      _term('call.live.wait', 'Waiting / cooldown', 'Ожидание / cooldown'),
  'call.end_party': _term(
    'call.end_party',
    'Connection termination party',
    'END_PARTY · сторона завершения',
    definitionRu:
        'По какой стороне было разорвано соединение: наша сторона, удалённая сторона или сеть.',
    aliases: const ['END_PARTY', 'EP'],
  ),
  'call.end.us': _term('call.end.us', 'Ended by us', 'Завершено нами'),
  'call.end.remote': _term('call.end.remote', 'Ended by remote party',
      'Завершено удалённой стороной'),
  'call.end.network':
      _term('call.end.network', 'Ended by network', 'Завершено сетью'),
  'modem.cfun.1':
      _term('modem.cfun.1', 'Full functionality', 'Полный рабочий режим'),
  'modem.cfun.5': _term('modem.cfun.5', 'Modem offline', 'Модем offline'),
  'modem.cfun.4': _term(
    'modem.cfun.4',
    'SIM removed',
    'SIM удалена',
    tooltipRu: 'CFUN=4: SIM удалена; legacy-переход готовит CFUN=6.',
  ),
  'modem.cfun.6': _term('modem.cfun.6', 'Modem resetting', 'Перезапуск модема'),
  'sim.state.0': _term('sim.state.0', 'SIM not ready', 'SIM не готова'),
  'sim.state.1': _term('sim.state.1', 'SIM present', 'SIM присутствует'),
  'sim.state.4': _term(
    'sim.state.4',
    'SIM present',
    'SIM присутствует',
    tooltipRu: 'SIMST=4: SIM присутствует и распознана модемом.',
  ),
  'sim.pin_required': _term(
    'sim.pin_required',
    'PIN required',
    'Требуется PIN',
    tooltipRu:
        'Требуется PIN. В legacy это составное состояние pinrequired при SIMST=0.',
  ),
  'sim.state.255': _term('sim.state.255', 'SIM absent', 'SIM отсутствует'),
  'network.state.0': _term('network.state.0', 'No network', 'Нет сети'),
  'network.state.1':
      _term('network.state.1', 'Network available', 'Сеть доступна'),
  'network.state.2':
      _term('network.state.2', 'Searching network', 'Поиск сети'),
  'network.state.no_valid_sim': _term('network.state.no_valid_sim',
      'Network without valid SIM', 'Сеть без валидной SIM'),
  'captcha.ok': _term('captcha.ok', 'CAPTCHA passed', 'Капча пройдена'),
  'captcha.new': _term('captcha.new', 'New CAPTCHA', 'Новая капча'),
  'captcha.fail': _term('captcha.fail', 'CAPTCHA failed', 'Капча не пройдена'),
  'captcha.pal': _term(
    'captcha.pal',
    'PAL · unresolved',
    'PAL · значение не установлено',
    tooltipRu:
        'Историческая аббревиатура PAL; подтверждённое значение в доступном коде не найдено.',
    confidence: TermConfidence.unresolved,
  ),
  'call.special.short_beacon': _term(
    'call.special.short_beacon',
    'Short call beacon',
    'Короткий звонок-маяк',
    tooltipRu:
        'Специальный короткий звонок-маяк; не путать с SMS-командой MAY.',
  ),
  'command.callback_request': _term(
    'command.callback_request',
    'Operator callback request',
    'Операторский запрос перезвонить',
    tooltipRu:
        'Команда оператора: отправить просьбу перезвонить. Может использовать MSM как SMS fallback.',
    aliases: const ['MAY', 'send_may'],
  ),
  'command.balance_topup_request': _term(
    'command.balance_topup_request',
    'Balance top-up request',
    'Просьба пополнить счёт',
    tooltipRu:
        'Команда оператора: отправить другому абоненту просьбу пополнить баланс этой SIM.',
    aliases: const ['MON', 'send_mon'],
  ),
  'command.callback_sms_fallback': _term(
    'command.callback_sms_fallback',
    'Callback request by SMS',
    'SMS с просьбой перезвонить',
    tooltipRu:
        'SMS с просьбой перезвонить — fallback для MAY; не означает Multiple-SIM.',
    aliases: const ['MSM'],
  ),
  'im.ima': _term(
    'im.ima',
    'IMA · historical relationship',
    'IMA · историческая связь',
    tooltipRu:
        'Историческая метка IMA; активный producer/consumer в доступном коде не найден.',
    confidence: TermConfidence.unresolved,
  ),
  'im.imb': _term('im.imb', 'Primary SIM in Number B history',
      'Основная SIM в истории номера B',
      tooltipRu: 'Эта SIM первая (основная) в упорядоченной истории номера B.'),
  'im.imc': _term(
      'im.imc', 'Later SIM in Number B history', 'SIM есть в истории номера B',
      tooltipRu:
          'Эта SIM встречается в истории номера B, но не является первой.'),
  'im.imd': _term('im.imd', 'New SIM allowed', 'Новая SIM разрешена',
      tooltipRu:
          'Этой SIM нет в истории номера B; другие SIM есть, но выбор новой SIM разрешён.'),
  'im.ime': _term(
      'im.ime', 'Only listed SIMs allowed', 'Разрешены только SIM из истории',
      tooltipRu:
          'Этой SIM нет в истории номера B; разрешены только перечисленные в истории SIM.'),
  'im.imn': _term('im.imn', 'Empty SIM history', 'История SIM пуста',
      tooltipRu: 'История SIM для номера B пуста; разрешена любая SIM.'),
  'recognition.10': _term('recognition.10', 'Silence', 'Тишина (нет речи)'),
  'recognition.20':
      _term('recognition.20', 'Answering machine', 'Автоответчик'),
  'recognition.30': _term(
      'recognition.30', 'Acoustic busy tone', 'Акустический сигнал «занято»'),
  'recognition.50':
      _term('recognition.50', 'Speech detected', 'Обнаружена речь'),
  'recognition.90': _unresolvedRecognition('90'),
  'recognition.91': _unresolvedRecognition('91'),
  'recognition.92': _unresolvedRecognition('92'),
  'recognition.100':
      _term('recognition.100', 'Successful result', 'Успешный результат'),
  'recognition.110': _term('recognition.110', 'Own SIM: insufficient funds',
      'Своя SIM: недостаточно средств',
      tooltipRu:
          'Объявление оператора о недостатке средств на собственной вызывающей SIM.'),
  'recognition.120': _term('recognition.120', 'Own SIM: number blocked',
      'Своя SIM: номер заблокирован',
      tooltipRu:
          'Объявление оператора о блокировке номера собственной вызывающей SIM.'),
  'special.pre': _term('special.pre', 'Pre-processing', 'Предобработка'),
  'special.pos': _term('special.pos', 'Post-processing', 'Постобработка'),
  'special.spe': _term(
      'special.spe', 'SPE · unresolved', 'SPE · значение не установлено',
      confidence: TermConfidence.unresolved),
  'special.mag': _term(
      'special.mag', 'MAG · unresolved', 'MAG · значение не установлено',
      confidence: TermConfidence.unresolved),
  'special.nav': _term(
      'special.nav', 'NAV · unresolved', 'NAV · значение не установлено',
      confidence: TermConfidence.unresolved),
  'special.mon': _term('special.mon', 'MON special mode · unresolved',
      'MON · значение режима не установлено',
      tooltipRu:
          'Историческая spec-метка MON; не смешивать с командой send_mon «попросить пополнить счёт».',
      confidence: TermConfidence.unresolved),
};

TermDefinition _unresolvedRecognition(String code) => _term(
      'recognition.$code',
      'REC $code · unresolved',
      'REC $code · значение не установлено',
      tooltipRu:
          'REC=$code вычисляется на simserver; точное значение в этом репозитории не установлено.',
      confidence: TermConfidence.unresolved,
    );

TermDefinition termById(String id, {String? fallbackLabel}) =>
    terminology[id] ??
    _term(
      id,
      fallbackLabel ?? 'Unknown term: $id',
      fallbackLabel ?? 'Неизвестный термин: $id',
      confidence: TermConfidence.historical,
    );
