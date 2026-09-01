import 'models.dart';

OperatorCommand _ussd(String id, CommandPurpose purpose, String code,
    {String? name,
    String queue = 'LOC',
    List<UssdReply> replies = const [],
    List<CommandParameter> parameters = const [],
    String? description,
    List<CommandOperation> after = const []}) {
  return OperatorCommand(
    id: id,
    purpose: purpose,
    name: name ?? purpose.label,
    description: description,
    parameters: parameters,
    operations: [
      UssdDialogOperation('${id}_ussd',
          start: UssdStart(code, queueClass: queue), replies: replies),
      ...after,
    ],
  );
}

OperatorCommand _call(String id, CommandPurpose purpose, String number,
        {String? name, String profile = 'default'}) =>
    OperatorCommand(
        id: id,
        purpose: purpose,
        name: name ?? purpose.label,
        operations: [
          PlaceCallOperation('${id}_call',
              numberTemplate: number, callProfile: profile)
        ]);

const _phone = CommandParameter(
    key: 'phone', label: 'Номер получателя', type: ParameterType.phoneNumber);

OperatorCommand _mayMon(String id, CommandPurpose purpose, String code) =>
    _ussd(id, purpose, code, queue: 'LO2', parameters: const [_phone]);

ResponseRule _valueRule(String id, String name, ResponseChannel channel,
        String pattern, ResponseField field, List<Normalizer> normalizers,
        {int priority = 0}) =>
    ResponseRule(
      id: id,
      name: name,
      priority: priority,
      channel: channel,
      matcher:
          ResponseMatcher(mode: MatchMode.regularExpression, pattern: pattern),
      effects: [
        ResponseEffect(
            field: field,
            source: ValueSource.capture,
            captureNameOrIndex: '1',
            normalizers: normalizers),
      ],
    );

ResponseRule _balance(String id, {int priority = 0}) => _valueRule(
    '${id}_balance',
    'Баланс',
    ResponseChannel.ussd,
    r'(?:Баланс|Balance|Balans|счет)[^0-9-]*(-?[0-9]+(?:[.,][0-9]+)?)',
    ResponseField.balance,
    const [Normalizer.trim, Normalizer.decimalNumber],
    priority: priority);

ResponseRule _number(String id, {int priority = 1}) => _valueRule(
    '${id}_number',
    'Номер телефона',
    ResponseChannel.ussd,
    r'(?:Номер|number|nomer)[^0-9+]*(\+?[0-9]{7,15})',
    ResponseField.phoneNumber,
    const [
      Normalizer.trim,
      Normalizer.digitsOnly,
      Normalizer.phoneWithCountryCode
    ],
    priority: priority);

ResponseRule _tariff(String id, {int priority = 2}) => _valueRule(
    '${id}_tariff',
    'Тариф',
    ResponseChannel.ussd,
    r'(?:Тариф|Tariff|Tarif)[: ]+([^\r\n]+)',
    ResponseField.tariff,
    const [Normalizer.trim, Normalizer.plainText],
    priority: priority);

ResponseRule _minutes(String id, {int priority = 3}) => _valueRule(
    '${id}_minutes',
    'Остаток минут',
    ResponseChannel.ussd,
    r'(?:минут|minutes|min)[^0-9]*([0-9]+)',
    ResponseField.remainingMinutes,
    const [Normalizer.trim, Normalizer.integerNumber],
    priority: priority);

ResponseRule _options(String id, {int priority = 4}) => _valueRule(
    '${id}_options',
    'Активные опции',
    ResponseChannel.ussd,
    r'(?:Опции|Options)[: ]+([^\r\n]+)',
    ResponseField.options,
    const [Normalizer.trim, Normalizer.plainText],
    priority: priority);

ResponseRule _promise(String id, {int priority = 5}) => _valueRule(
    '${id}_promise',
    'Доверительный платёж',
    ResponseChannel.ussd,
    r'(?:Доверительн|Promise)[^0-9]*([0-9]+(?:[.,][0-9]+)?)',
    ResponseField.promisePaymentAmount,
    const [Normalizer.trim, Normalizer.decimalNumber],
    priority: priority);

ResponseRule _blocked(String id, {int priority = 90}) => ResponseRule(
    id: '${id}_blocked',
    name: 'Номер заблокирован',
    priority: priority,
    channel: ResponseChannel.sms,
    matcher: const ResponseMatcher(
        mode: MatchMode.contains, pattern: 'заблокирован'),
    outcome: SemanticOutcome.blocked);

ResponseRule _lowBalance(String id, {int priority = 91}) => ResponseRule(
    id: '${id}_low_balance',
    name: 'Недостаточно средств',
    priority: priority,
    channel: ResponseChannel.sms,
    matcher: const ResponseMatcher(
        mode: MatchMode.contains, pattern: 'Недостаточно средств'),
    outcome: SemanticOutcome.lowBalance);

const defaultCommandSet = CommandSet(
  id: 'default',
  name: 'Набор по умолчанию',
  operatorName: 'Все операторы',
  countryCode: 'ZZ',
  countryName: 'Все страны',
  kind: CommandSetKind.systemFallback,
  usedByPlanIds: ['default'],
);

final commandSetSeed = <CommandSet>[
  defaultCommandSet,
  CommandSet(
    id: 'megafon_msk',
    name: 'MegaFon · Москва',
    operatorName: 'MegaFon',
    countryCode: 'RU',
    countryName: 'Россия',
    region: 'Москва',
    commands: [
      _ussd('activate_sim', CommandPurpose.activateSim, '*926*1*1#'),
      _ussd('activate_work', CommandPurpose.activateWork, '*105*335#'),
      _ussd('get_balance', CommandPurpose.getBalance, '*100#'),
      _ussd('get_number', CommandPurpose.getNumber, '*205#'),
      _ussd('get_tariff', CommandPurpose.getTariff, '*105*2*0#'),
    ],
    responseRules: [
      _balance('megafon_msk'),
      _number('megafon_msk'),
      _tariff('megafon_msk')
    ],
  ),
  CommandSet(
    id: 'megafon_spb',
    name: 'MegaFon · Санкт-Петербург',
    operatorName: 'MegaFon',
    countryCode: 'RU',
    countryName: 'Россия',
    region: 'Санкт-Петербург',
    commands: [
      _ussd('activate_sim', CommandPurpose.activateSim, '*105*0082#'),
      _ussd('activate_work', CommandPurpose.activateWork, '*105*0082#',
          replies: const [UssdReply('reply_1', '1', fallbackAfterSeconds: 7)],
          description: 'Интерактивное включение работы через меню оператора.'),
      _ussd('get_balance', CommandPurpose.getBalance, '*100#'),
      _ussd('get_number', CommandPurpose.getNumber, '*105*00#'),
      _ussd('get_minutes', CommandPurpose.getMinutes, '*100*2#'),
      _ussd('get_promise_payment', CommandPurpose.getPromisePayment, '*106#',
          replies: const [
            UssdReply('reply_100', '100', fallbackAfterSeconds: 15)
          ],
          after: const [
            SendSmsOperation('promise_sms',
                destinationTemplate: '0006', messageTemplate: '100')
          ]),
      _mayMon('send_may', CommandPurpose.sendMay, '*144*{{phone}}#'),
      _mayMon('send_mon', CommandPurpose.sendMon, '*143*{{phone}}#'),
    ],
    responseRules: [
      _balance('megafon_spb'),
      _number('megafon_spb'),
      _minutes('megafon_spb'),
      _blocked('megafon_spb'),
      _lowBalance('megafon_spb'),
    ],
  ),
  CommandSet(
    id: 'beeline_spb',
    name: 'Beeline · Санкт-Петербург',
    operatorName: 'Beeline',
    countryCode: 'RU',
    countryName: 'Россия',
    region: 'Санкт-Петербург',
    usedByPlanIds: const ['beeline_spb'],
    commands: [
      _ussd('activate_sim', CommandPurpose.activateSim, '*101*1111#'),
      _call('activate_work', CommandPurpose.activateWork, '06747073'),
      _ussd('get_balance', CommandPurpose.getBalance, '#102#'),
      _ussd('get_number', CommandPurpose.getNumber, '*110*10#'),
      _ussd('get_tariff', CommandPurpose.getTariff, '*110*05#'),
      _call('get_minutes', CommandPurpose.getMinutes, '06745'),
      _ussd('get_promise_payment', CommandPurpose.getPromisePayment, '*141#'),
      _ussd('initialize_tariff', CommandPurpose.initializeTariff, '*111*777#',
          replies: const [UssdReply('reply_2', '2')]),
      _mayMon('send_may', CommandPurpose.sendMay, '*144*{{phone}}#'),
      _mayMon('send_mon', CommandPurpose.sendMon, '*143*{{phone}}#'),
    ],
    responseRules: [
      _balance('beeline_spb'),
      _number('beeline_spb'),
      _tariff('beeline_spb'),
      _minutes('beeline_spb'),
      _promise('beeline_spb'),
      _blocked('beeline_spb'),
    ],
  ),
  CommandSet(
    id: 'mts_spb',
    name: 'MTS · Санкт-Петербург',
    operatorName: 'MTS',
    countryCode: 'RU',
    countryName: 'Россия',
    region: 'Санкт-Петербург',
    commands: [
      _ussd('get_balance', CommandPurpose.getBalance, '*100#'),
      _ussd('get_number', CommandPurpose.getNumber, '*111*0887#'),
      _ussd('initialize_tariff', CommandPurpose.initializeTariff, '*111*777#',
          replies: const [UssdReply('reply_2', '2')]),
    ],
    responseRules: [_balance('mts_spb'), _number('mts_spb')],
  ),
  CommandSet(
    id: 'tele2_spb',
    name: 'Tele2 · Санкт-Петербург',
    operatorName: 'Tele2',
    countryCode: 'RU',
    countryName: 'Россия',
    region: 'Санкт-Петербург',
    usedByPlanIds: const ['tele2_spb'],
    commands: [
      _call('activate_sim', CommandPurpose.activateSim, '610'),
      _ussd('activate_work', CommandPurpose.activateWork, '*116*52#'),
      _ussd('get_balance', CommandPurpose.getBalance, '*105#'),
      _ussd('get_number', CommandPurpose.getNumber, '*201#'),
      _ussd('get_tariff', CommandPurpose.getTariff, '*108#'),
      _ussd('get_minutes', CommandPurpose.getMinutes, '*116*17#'),
      OperatorCommand(
          id: 'get_options',
          purpose: CommandPurpose.getOptions,
          name: CommandPurpose.getOptions.label,
          operations: const [
            UssdDialogOperation('get_options_primary',
                start: UssdStart('*153#')),
            UssdDialogOperation('get_options_secondary',
                start: UssdStart('*155*21#')),
          ]),
      _ussd('get_promise_payment', CommandPurpose.getPromisePayment, '*122*1#'),
      const OperatorCommand(
          id: 'enter_pin',
          purpose: CommandPurpose.enterPin,
          name: 'Ввести PIN SIM',
          parameters: [
            CommandParameter(
                key: 'pin',
                label: 'PIN',
                type: ParameterType.pin,
                secret: true),
          ],
          operations: [
            SendAtOperation('enter_pin_at',
                commandTemplate:
                    r'AT+CPIN="{{pin}}";+CLCK="SC",0,"{{pin}}";+CFUN=1,1'),
          ]),
      _ussd('disable_service_209', CommandPurpose.disableService, '*152*0#',
          name: 'Отключить услугу 209'),
    ],
    responseRules: [
      _balance('tele2_spb'),
      _number('tele2_spb'),
      _tariff('tele2_spb'),
      _minutes('tele2_spb'),
      _options('tele2_spb'),
      _promise('tele2_spb'),
      _lowBalance('tele2_spb'),
    ],
  ),
  CommandSet(
    id: 'rostel_spb',
    name: 'Rostelecom · Санкт-Петербург',
    operatorName: 'Rostelecom',
    countryCode: 'RU',
    countryName: 'Россия',
    region: 'Санкт-Петербург',
    commands: [
      _call('activate_sim', CommandPurpose.activateSim, '88127106834',
          profile: '10s'),
      _ussd('activate_work', CommandPurpose.activateWork, '*106*27*1#'),
      _ussd('get_balance', CommandPurpose.getBalance, '*102#'),
      _ussd('get_number', CommandPurpose.getNumber, '*110#'),
      _ussd('get_tariff', CommandPurpose.getTariff, '*100*42#'),
      _ussd('get_minutes', CommandPurpose.getMinutes, '*106*27*2#'),
      _ussd('get_options', CommandPurpose.getOptions, '*109*100*1#'),
      _ussd('get_promise_payment', CommandPurpose.getPromisePayment,
          '*100*17*100#'),
    ],
    responseRules: [
      _balance('rostel_spb'),
      _number('rostel_spb'),
      _tariff('rostel_spb'),
      _minutes('rostel_spb'),
      _options('rostel_spb'),
      _promise('rostel_spb'),
      _blocked('rostel_spb'),
      _lowBalance('rostel_spb'),
    ],
  ),
  CommandSet(
    id: 'kievstar',
    name: 'Kyivstar · Украина',
    operatorName: 'Kyivstar',
    countryCode: 'UA',
    countryName: 'Украина',
    commands: [
      _ussd('activate_sim', CommandPurpose.activateSim, '*111#',
          description:
              'Активная helper-последовательность объединена с основной командой.'),
      _ussd('activate_work', CommandPurpose.activateWork, '*100*77#'),
      _ussd('get_balance', CommandPurpose.getBalance, '*111#'),
      _ussd('get_number', CommandPurpose.getNumber, '*161#'),
      _ussd('get_tariff', CommandPurpose.getTariff, '*100*01*2#'),
    ],
    responseRules: [
      _balance('kievstar'),
      _number('kievstar'),
      _tariff('kievstar')
    ],
  ),
  CommandSet(
    id: 'velcom',
    name: 'Velcom · Беларусь',
    operatorName: 'Velcom',
    countryCode: 'BY',
    countryName: 'Беларусь',
    commands: [
      _ussd('activate_work', CommandPurpose.activateWork, '*141*3*4#',
          replies: const [
            UssdReply('reply_1', '1', fallbackAfterSeconds: 20),
            UssdReply('reply_0', '0', fallbackAfterSeconds: 20),
            UssdReply('reply_3', '3', fallbackAfterSeconds: 20),
            UssdReply('reply_final', '1', fallbackAfterSeconds: 20),
          ]),
      _ussd('get_balance', CommandPurpose.getBalance, '*100#'),
      _ussd('get_number', CommandPurpose.getNumber, '*147#'),
      _ussd('get_tariff', CommandPurpose.getTariff, '*141*3*4#'),
      _mayMon('send_may', CommandPurpose.sendMay, '*131*{{phone}}#'),
    ],
    responseRules: [_balance('velcom'), _number('velcom'), _tariff('velcom')],
  ),
  CommandSet(
    id: 'life',
    name: 'life:) · Беларусь',
    operatorName: 'life:)',
    countryCode: 'BY',
    countryName: 'Беларусь',
    commands: [
      _ussd('activate_work', CommandPurpose.activateWork, '*110*1*3*1#'),
      _ussd('get_balance', CommandPurpose.getBalance, '*100#'),
      _ussd('get_number', CommandPurpose.getNumber, '*147#'),
      _ussd('get_tariff', CommandPurpose.getTariff, '*141*3*4#'),
      _mayMon('send_may', CommandPurpose.sendMay, '*120*2*{{phone}}#'),
    ],
    responseRules: [_balance('life'), _number('life'), _tariff('life')],
  ),
];
