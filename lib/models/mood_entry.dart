class MoodEntry {
  final String mood;
  final DateTime date;

  MoodEntry({
    required this.mood,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'date': date.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      mood: json['mood'],
      date: DateTime.parse(json['date']),
    );
  }
}
