class JournalEntry {
  final String text;
  final DateTime date;
  final String mood;

  JournalEntry({
    required this.text,
    required this.date,
    required this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
      'mood': mood,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      text: json['text'],
      date: DateTime.parse(json['date']),
      mood: json['mood'] ?? '😐',
    );
  }
}
