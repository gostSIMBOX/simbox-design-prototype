bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// One entry in a zone's group-selection fallback list — parsed from a
/// legacy dialplan selector string like `L1D=NS101`
/// (`libsCpp/asterisk-chan-svistok/src/select.c`'s `get_cr_group()`).
/// Order matters: rules are tried in list order until one succeeds.
class GroupRule {
  final int limitSlot; // 0-9, indexes the SIM's limit[10] (chan_dongle.h)
  final String alg; // raw selector char: D d ^ * > <
  final String type; // raw selector char: = - _
  final String group; // SIM group number, kept as text

  const GroupRule({
    required this.limitSlot,
    required this.alg,
    required this.type,
    required this.group,
  });

  GroupRule copyWith({int? limitSlot, String? alg, String? type, String? group}) => GroupRule(
        limitSlot: limitSlot ?? this.limitSlot,
        alg: alg ?? this.alg,
        type: type ?? this.type,
        group: group ?? this.group,
      );

  @override
  bool operator ==(Object other) =>
      other is GroupRule &&
      limitSlot == other.limitSlot &&
      alg == other.alg &&
      type == other.type &&
      group == other.group;

  @override
  int get hashCode => Object.hash(limitSlot, alg, type, group);
}

/// A routing direction ("направление") — the same concept the Sims table's
/// `напр` column shows one icon+letter-code for per SIM (see
/// `lib/data/icon_map.dart`'s `_naprMap`). A [Zone] here additionally carries
/// the full list of DEF-code dialplan patterns that decide which zone a
/// dialled number belongs to, plus the ordered list of group-selection rules
/// that decide which pool of SIMs actually carries the call — together, the
/// two pieces the legacy panel never got a UI for.
class Zone {
  final String id;
  final String name;
  final String? region;
  final String icon;
  final List<String> defCodes;
  final String? billingCode; // 2-letter code, e.g. 'NS' — shared by every rule below
  final List<GroupRule> groupRules; // ordered — fallback priority, first tried first

  const Zone({
    required this.id,
    required this.name,
    this.region,
    required this.icon,
    this.defCodes = const [],
    this.billingCode,
    this.groupRules = const [],
  });

  Zone copyWith({
    String? name,
    String? region,
    String? icon,
    List<String>? defCodes,
    String? billingCode,
    List<GroupRule>? groupRules,
  }) =>
      Zone(
        id: id,
        name: name ?? this.name,
        region: region ?? this.region,
        icon: icon ?? this.icon,
        defCodes: defCodes ?? this.defCodes,
        billingCode: billingCode ?? this.billingCode,
        groupRules: groupRules ?? this.groupRules,
      );

  @override
  bool operator ==(Object other) =>
      other is Zone &&
      id == other.id &&
      name == other.name &&
      region == other.region &&
      icon == other.icon &&
      billingCode == other.billingCode &&
      _listEquals(defCodes, other.defCodes) &&
      _listEquals(groupRules, other.groupRules);

  @override
  int get hashCode => Object.hash(
      id, name, region, icon, billingCode, Object.hashAll(defCodes), Object.hashAll(groupRules));
}
