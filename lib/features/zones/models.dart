bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// A routing direction ("направление") — the same concept the Sims table's
/// `напр` column shows one icon+letter-code for per SIM (see
/// `lib/data/icon_map.dart`'s `_naprMap`). A [Zone] here additionally carries
/// the full list of DEF-code dialplan patterns that decide which zone a
/// dialled number belongs to — the piece the legacy panel never got a UI for.
class Zone {
  final String id;
  final String name;
  final String? region;
  final String icon;
  final List<String> defCodes;

  const Zone({
    required this.id,
    required this.name,
    this.region,
    required this.icon,
    this.defCodes = const [],
  });

  Zone copyWith({String? name, String? region, String? icon, List<String>? defCodes}) => Zone(
        id: id,
        name: name ?? this.name,
        region: region ?? this.region,
        icon: icon ?? this.icon,
        defCodes: defCodes ?? this.defCodes,
      );

  @override
  bool operator ==(Object other) =>
      other is Zone &&
      id == other.id &&
      name == other.name &&
      region == other.region &&
      icon == other.icon &&
      _listEquals(defCodes, other.defCodes);

  @override
  int get hashCode => Object.hash(id, name, region, icon, Object.hashAll(defCodes));
}
