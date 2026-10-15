import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final List<MoodEntry> _moods = [];

  final List<String> moods = ['😄', '🙂', '😐', '😔', '😟', '😡', '😰'];

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  /// Reload moods whenever the screen comes into view
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('mood_entries');

    if (data != null) {
      setState(() {
        _moods
          ..clear()
          ..addAll(
            data.map((e) => MoodEntry.fromJson(jsonDecode(e))),
          );
      });
    }
  }

  Future<void> _saveMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _moods.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('mood_entries', data);
  }

  void _addMood(String mood) async {
    HapticFeedback.selectionClick();

    setState(() {
      _moods.insert(
        0,
        MoodEntry(mood: mood, date: DateTime.now()),
      );
    });

    await _saveMoods();
  }

  int _moodValue(String mood) {
    switch (mood) {
      case '😄':
        return 7;
      case '🙂':
        return 6;
      case '😐':
        return 5;
      case '😔':
        return 4;
      case '😟':
        return 3;
      case '😡':
        return 2;
      case '😰':
        return 1;
      default:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recent = _moods.take(7).toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MOOD PICKER
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: moods.map((m) {
                return GestureDetector(
                  onTap: () => _addMood(m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // LAST 7 MOODS CHART
            Text(
              'Last 7 moods',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            if (recent.isEmpty)
              const Text('No mood data yet')
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    minY: 1,
                    maxY: 7,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    barGroups: List.generate(
                      recent.length,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: _moodValue(recent[i].mood).toDouble(),
                            width: 18,
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // MOOD TIMELINE
            Text(
              'Mood history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            if (_moods.isEmpty)
              const Text('No moods logged yet')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _moods.length,
                itemBuilder: (_, index) {
                  final m = _moods[index];
                  return ListTile(
                    leading: Text(m.mood, style: const TextStyle(fontSize: 24)),
                    title: Text(DateFormat('dd MMM yyyy').format(m.date)),
                    subtitle: Text(DateFormat('HH:mm').format(m.date)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
