
class Intimacy {
  final int value;
  final List<IntimacyRecord> history;

  Intimacy({required this.value, required this.history});
  
  Intimacy copyWith({int? value, List<IntimacyRecord>? history}) {
    return Intimacy(
      value: value ?? this.value,
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
