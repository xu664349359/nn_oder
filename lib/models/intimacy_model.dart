
class Intimacy {
  final int score;
  final int level;
  final List<IntimacyRecord> history;

  Intimacy({
    required this.score,
    required this.level,
    this.history = const [],
  });
  
  Intimacy copyWith({
    int? score,
    int? level,
    List<IntimacyRecord>? history,
  }) {
    return Intimacy(
      score: score ?? this.score,
      level: level ?? this.level,
      history: history ?? this.history,
    );
  }
}

class IntimacyRecord {
  final String id;
  final int change;
  final String reason;
  final DateTime timestamp;

  IntimacyRecord({
    required this.id,
    required this.change,
    required this.reason,
    required this.timestamp,
  });
}
