bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// One of the six legacy direction slots (`alg.N`/`nodiff.N`/`limit_max.N`/
/// `limit_hard.N` in the archived `plan/` directory). Slots 1-4 are ordinary,
/// editable Plan policy; slots 0 and 5 exist only for legacy compatibility
/// and are never presented as ordinary directions.
class DirectionSlot {
  final int slot; // 0-5
  final bool editable; // false for 0 and 5
  final int alg; // legacy numeric algorithm code (values observed: 42,65,66,68,98) — a Plan-level policy code, unrelated to Zone's dialplan selector char
  final bool nodiff; // "различие не учитывается"
  final int limitSoft;
  final int limitHard;

  const DirectionSlot({
    required this.slot,
    required this.editable,
    required this.alg,
    required this.nodiff,
    required this.limitSoft,
    required this.limitHard,
  });

  DirectionSlot copyWith({int? alg, bool? nodiff, int? limitSoft, int? limitHard}) =>
      DirectionSlot(
        slot: slot,
        editable: editable,
        alg: alg ?? this.alg,
        nodiff: nodiff ?? this.nodiff,
        limitSoft: limitSoft ?? this.limitSoft,
        limitHard: limitHard ?? this.limitHard,
      );

  @override
  bool operator ==(Object other) =>
      other is DirectionSlot &&
      slot == other.slot &&
      editable == other.editable &&
      alg == other.alg &&
      nodiff == other.nodiff &&
      limitSoft == other.limitSoft &&
      limitHard == other.limitHard;

  @override
  int get hashCode => Object.hash(slot, editable, alg, nodiff, limitSoft, limitHard);
}

/// A billing/behavior plan ("план") — a named bundle of automation and
/// call-pacing policy applied to a group of SIMs. Belongs to exactly one
/// command set; a SIM selects exactly one plan (`Sim.plan`). Group/route
/// ownership lives in Направления (`Zone`/`GroupRule`), never here — see
/// `lib/features/plans/directions_section.dart` for the read-only
/// cross-reference.
class Plan {
  // Identity and ownership
  final String id;
  final String commandSetId;
  final int priority;
  final String? proTag; // routing tag compared by algorithms P/p/v, not a product tier

  // Capacity
  final int onlineMax;
  final int addMax;

  // Call modes and quality eligibility
  final bool canIn, canOut, canSout;
  final bool notVip;
  final Set<String> qualityFlags; // subset of {VIP,GOO,NOR,BAD,NEW,NOS,ROB,BLO}
  // capok/capnew/capfail are independent flags in the archive, not a single
  // mode (capno/capyes are always unset everywhere — audit-only, not
  // modeled; capnnew disagrees with capnew on 2/33 plans, so it is kept
  // audit-only rather than blindly merged as an alias).
  final bool capOk, capNew, capFail;

  // Timing and schedule
  final int diffSlow;
  final int diffMin;
  final int diffMinOut;
  final int? timeWake, timeSleep; // null = disabled (legacy -1) — the pair named in the banner
  final int? timeWorkWake, timeWorkSleep; // null = disabled (legacy -1)
  final int? timeHolidayWake, timeHolidaySleep; // null = disabled (legacy -1)

  // Directions — exactly 6 entries, slots 0-5, only 1-4 editable
  final List<DirectionSlot> directions;

  // Incoming-call generation
  final int iattMin, iattMax, iattSoft;
  final int inAcdMin, inAcdMax;
  final int outAcdMin, outAcdMax;
  final bool forwarding, conn, rand, inWait, inSound;
  final int outInAns; // legacy answer-mode code (e.g. 4/5/6/8/10), not boolean

  // SMS and beacon generation
  final int mayLimit, monLimit, msmLimit;
  final int smsoutSoft, smsoutHard;
  final int sattSoft, sattHard, sattSoftDay, sattHardDay, sattSoftTotal, sattHardTotal;
  final int nospam; // legacy small integer code (1/2 observed), not boolean

  const Plan({
    required this.id,
    required this.commandSetId,
    this.priority = 0,
    this.proTag,
    this.onlineMax = 0,
    this.addMax = 0,
    this.canIn = true,
    this.canOut = true,
    this.canSout = false,
    this.notVip = false,
    this.qualityFlags = const {},
    this.capOk = true,
    this.capNew = true,
    this.capFail = false,
    this.diffSlow = 0,
    this.diffMin = 0,
    this.diffMinOut = 0,
    this.timeWake,
    this.timeSleep,
    this.timeWorkWake,
    this.timeWorkSleep,
    this.timeHolidayWake,
    this.timeHolidaySleep,
    this.directions = const [],
    this.iattMin = 0,
    this.iattMax = 0,
    this.iattSoft = 0,
    this.inAcdMin = 0,
    this.inAcdMax = 0,
    this.outAcdMin = 0,
    this.outAcdMax = 0,
    this.forwarding = false,
    this.outInAns = 0,
    this.conn = false,
    this.rand = false,
    this.inWait = false,
    this.inSound = false,
    this.mayLimit = 0,
    this.monLimit = 0,
    this.msmLimit = 0,
    this.smsoutSoft = 0,
    this.smsoutHard = 0,
    this.sattSoft = 0,
    this.sattHard = 0,
    this.sattSoftDay = 0,
    this.sattHardDay = 0,
    this.sattSoftTotal = 0,
    this.sattHardTotal = 0,
    this.nospam = 0,
  });

  Plan copyWith({
    String? commandSetId,
    int? priority,
    String? proTag,
    bool clearProTag = false,
    int? onlineMax,
    int? addMax,
    bool? canIn,
    bool? canOut,
    bool? canSout,
    bool? notVip,
    Set<String>? qualityFlags,
    bool? capOk,
    bool? capNew,
    bool? capFail,
    int? diffSlow,
    int? diffMin,
    int? diffMinOut,
    int? timeWake,
    bool clearTimeWake = false,
    int? timeSleep,
    bool clearTimeSleep = false,
    int? timeWorkWake,
    bool clearTimeWorkWake = false,
    int? timeWorkSleep,
    bool clearTimeWorkSleep = false,
    int? timeHolidayWake,
    bool clearTimeHolidayWake = false,
    int? timeHolidaySleep,
    bool clearTimeHolidaySleep = false,
    List<DirectionSlot>? directions,
    int? iattMin,
    int? iattMax,
    int? iattSoft,
    int? inAcdMin,
    int? inAcdMax,
    int? outAcdMin,
    int? outAcdMax,
    bool? forwarding,
    int? outInAns,
    bool? conn,
    bool? rand,
    bool? inWait,
    bool? inSound,
    int? mayLimit,
    int? monLimit,
    int? msmLimit,
    int? smsoutSoft,
    int? smsoutHard,
    int? sattSoft,
    int? sattHard,
    int? sattSoftDay,
    int? sattHardDay,
    int? sattSoftTotal,
    int? sattHardTotal,
    int? nospam,
  }) =>
      Plan(
        id: id,
        commandSetId: commandSetId ?? this.commandSetId,
        priority: priority ?? this.priority,
        proTag: clearProTag ? null : proTag ?? this.proTag,
        onlineMax: onlineMax ?? this.onlineMax,
        addMax: addMax ?? this.addMax,
        canIn: canIn ?? this.canIn,
        canOut: canOut ?? this.canOut,
        canSout: canSout ?? this.canSout,
        notVip: notVip ?? this.notVip,
        qualityFlags: qualityFlags ?? this.qualityFlags,
        capOk: capOk ?? this.capOk,
        capNew: capNew ?? this.capNew,
        capFail: capFail ?? this.capFail,
        diffSlow: diffSlow ?? this.diffSlow,
        diffMin: diffMin ?? this.diffMin,
        diffMinOut: diffMinOut ?? this.diffMinOut,
        timeWake: clearTimeWake ? null : timeWake ?? this.timeWake,
        timeSleep: clearTimeSleep ? null : timeSleep ?? this.timeSleep,
        timeWorkWake: clearTimeWorkWake ? null : timeWorkWake ?? this.timeWorkWake,
        timeWorkSleep: clearTimeWorkSleep ? null : timeWorkSleep ?? this.timeWorkSleep,
        timeHolidayWake: clearTimeHolidayWake ? null : timeHolidayWake ?? this.timeHolidayWake,
        timeHolidaySleep: clearTimeHolidaySleep ? null : timeHolidaySleep ?? this.timeHolidaySleep,
        directions: directions ?? this.directions,
        iattMin: iattMin ?? this.iattMin,
        iattMax: iattMax ?? this.iattMax,
        iattSoft: iattSoft ?? this.iattSoft,
        inAcdMin: inAcdMin ?? this.inAcdMin,
        inAcdMax: inAcdMax ?? this.inAcdMax,
        outAcdMin: outAcdMin ?? this.outAcdMin,
        outAcdMax: outAcdMax ?? this.outAcdMax,
        forwarding: forwarding ?? this.forwarding,
        outInAns: outInAns ?? this.outInAns,
        conn: conn ?? this.conn,
        rand: rand ?? this.rand,
        inWait: inWait ?? this.inWait,
        inSound: inSound ?? this.inSound,
        mayLimit: mayLimit ?? this.mayLimit,
        monLimit: monLimit ?? this.monLimit,
        msmLimit: msmLimit ?? this.msmLimit,
        smsoutSoft: smsoutSoft ?? this.smsoutSoft,
        smsoutHard: smsoutHard ?? this.smsoutHard,
        sattSoft: sattSoft ?? this.sattSoft,
        sattHard: sattHard ?? this.sattHard,
        sattSoftDay: sattSoftDay ?? this.sattSoftDay,
        sattHardDay: sattHardDay ?? this.sattHardDay,
        sattSoftTotal: sattSoftTotal ?? this.sattSoftTotal,
        sattHardTotal: sattHardTotal ?? this.sattHardTotal,
        nospam: nospam ?? this.nospam,
      );

  @override
  bool operator ==(Object other) =>
      other is Plan &&
      id == other.id &&
      commandSetId == other.commandSetId &&
      priority == other.priority &&
      proTag == other.proTag &&
      onlineMax == other.onlineMax &&
      addMax == other.addMax &&
      canIn == other.canIn &&
      canOut == other.canOut &&
      canSout == other.canSout &&
      notVip == other.notVip &&
      _setEquals(qualityFlags, other.qualityFlags) &&
      capOk == other.capOk &&
      capNew == other.capNew &&
      capFail == other.capFail &&
      diffSlow == other.diffSlow &&
      diffMin == other.diffMin &&
      diffMinOut == other.diffMinOut &&
      timeWake == other.timeWake &&
      timeSleep == other.timeSleep &&
      timeWorkWake == other.timeWorkWake &&
      timeWorkSleep == other.timeWorkSleep &&
      timeHolidayWake == other.timeHolidayWake &&
      timeHolidaySleep == other.timeHolidaySleep &&
      _listEquals(directions, other.directions) &&
      iattMin == other.iattMin &&
      iattMax == other.iattMax &&
      iattSoft == other.iattSoft &&
      inAcdMin == other.inAcdMin &&
      inAcdMax == other.inAcdMax &&
      outAcdMin == other.outAcdMin &&
      outAcdMax == other.outAcdMax &&
      forwarding == other.forwarding &&
      outInAns == other.outInAns &&
      conn == other.conn &&
      rand == other.rand &&
      inWait == other.inWait &&
      inSound == other.inSound &&
      mayLimit == other.mayLimit &&
      monLimit == other.monLimit &&
      msmLimit == other.msmLimit &&
      smsoutSoft == other.smsoutSoft &&
      smsoutHard == other.smsoutHard &&
      sattSoft == other.sattSoft &&
      sattHard == other.sattHard &&
      sattSoftDay == other.sattSoftDay &&
      sattHardDay == other.sattHardDay &&
      sattSoftTotal == other.sattSoftTotal &&
      sattHardTotal == other.sattHardTotal &&
      nospam == other.nospam;

  @override
  int get hashCode => Object.hash(
        id,
        commandSetId,
        priority,
        proTag,
        Object.hash(onlineMax, addMax, canIn, canOut, canSout, notVip),
        Object.hashAllUnordered(qualityFlags),
        Object.hash(capOk, capNew, capFail, diffSlow, diffMin, diffMinOut),
        Object.hash(timeWake, timeSleep),
        Object.hash(timeWorkWake, timeWorkSleep, timeHolidayWake, timeHolidaySleep),
        Object.hashAll(directions),
        Object.hash(iattMin, iattMax, iattSoft, inAcdMin, inAcdMax, outAcdMin, outAcdMax),
        Object.hash(forwarding, outInAns, conn, rand, inWait, inSound),
        Object.hash(mayLimit, monLimit, msmLimit, smsoutSoft, smsoutHard),
        Object.hash(sattSoft, sattHard, sattSoftDay, sattHardDay, sattSoftTotal, sattHardTotal),
        nospam,
      );
}

bool _setEquals<T>(Set<T> a, Set<T> b) => a.length == b.length && a.containsAll(b);
