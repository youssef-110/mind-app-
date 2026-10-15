import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindspace/main.dart';
import 'package:mindspace/models/journal_entry.dart';
import 'package:mindspace/models/mood_entry.dart';

void main() {
  testWidgets('app starts on the journal tab with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Mood'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });

  test('JournalEntry survives a JSON round trip', () {
    final entry = JournalEntry(
      text: 'Good day',
      date: DateTime(2026, 1, 5, 10, 30),
      mood: '😀',
    );
    final copy = JournalEntry.fromJson(entry.toJson());

    expect(copy.text, entry.text);
    expect(copy.date, entry.date);
    expect(copy.mood, entry.mood);
  });

  test('JournalEntry falls back to a neutral mood when none is stored', () {
    final entry = JournalEntry.fromJson({
      'text': 'Old entry',
      'date': DateTime(2026, 1, 1).toIso8601String(),
    });

    expect(entry.mood, '😐');
  });

  test('MoodEntry survives a JSON round trip', () {
    final entry = MoodEntry(mood: '😢', date: DateTime(2026, 1, 2));
    final copy = MoodEntry.fromJson(entry.toJson());

    expect(copy.mood, entry.mood);
    expect(copy.date, entry.date);
  });
}
