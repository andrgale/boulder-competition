class DashboardStats {
  final int competitions;
  final int athletes;
  final int boulders;
  final int ascents;

  const DashboardStats({
    required this.competitions,
    required this.athletes,
    required this.boulders,
    required this.ascents,
  });

  factory DashboardStats.empty() => const DashboardStats(
        competitions: 0,
        athletes: 0,
        boulders: 0,
        ascents: 0,
      );

  factory DashboardStats.fromMap(Map<String, int> map) => DashboardStats(
        competitions: map['competitions'] ?? 0,
        athletes: map['athletes'] ?? 0,
        boulders: map['boulders'] ?? 0,
        ascents: map['ascents'] ?? 0,
      );

  DashboardStats copyWith({
    int? competitions,
    int? athletes,
    int? boulders,
    int? ascents,
  }) =>
      DashboardStats(
        competitions: competitions ?? this.competitions,
        athletes: athletes ?? this.athletes,
        boulders: boulders ?? this.boulders,
        ascents: ascents ?? this.ascents,
      );

  @override
  String toString() =>
      'DashboardStats(competitions: $competitions, athletes: $athletes, '
      'boulders: $boulders, ascents: $ascents)';
}
