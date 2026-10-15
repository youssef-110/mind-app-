import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

enum MoodFilter { today, week, all }

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  MoodFilter _selectedFilter = MoodFilter.all;

  final List<String> allowedMoods = [
    '😄', '🙂', '😐', '😔', '😡', '😟', '😰'
  ];

  Future<List<MoodEntry>> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('mood_entries') ?? [];
    return data.map((e) => MoodEntry.fromJson(jsonDecode(e))).toList();
  }

  Future<void> _saveEntries(List<MoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('mood_entries', data);
    setState(() {});
  }

  List<MoodEntry> _applyFilter(List<MoodEntry> entries) {
    final now = DateTime.now();

    if (_selectedFilter == MoodFilter.today) {
      return entries.where((e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day).toList();
    }

    if (_selectedFilter == MoodFilter.week) {
      return entries.where((e) =>
          e.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood History')),
      body: Column(
        children: [
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _filterButton('Today', MoodFilter.today),
              _filterButton('This Week', MoodFilter.week),
              _filterButton('All Time', MoodFilter.all),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: FutureBuilder<List<MoodEntry>>(
              future: _loadEntries(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allEntries = snapshot.data!;
                final filtered = _applyFilter(allEntries);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No moods yet'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];

                    return Dismissible(
                      key: ValueKey(entry.date.toIso8601String()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        allEntries.remove(entry);
                        await _saveEntries(allEntries);
                      },
                      child: ListTile(
                        leading: Text(
                          entry.mood,
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(
                          entry.date.toLocal().toString().split('.')[0],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editMood(entry, allEntries);
                            } else {
                              allEntries.remove(entry);
                              _saveEntries(allEntries);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String text, MoodFilter filter) {
    final selected = _selectedFilter == filter;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = filter),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? Colors.blue : Colors.grey.shade300,
        foregroundColor:
            selected ? Colors.white : Colors.black,
      ),
      child: Text(text),
    );
  }

  void _editMood(MoodEntry entry, List<MoodEntry> allEntries) {
    String selectedMood = entry.mood;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Mood'),
        content: Wrap(
          spacing: 10,
          children: allowedMoods.map((mood) {
            return GestureDetector(
              onTap: () {
                selectedMood = mood;
                Navigator.pop(context);
                final index = allEntries.indexOf(entry);
                allEntries[index] = MoodEntry(
                  mood: selectedMood,
                  date: entry.date,
                );
                _saveEntries(allEntries);
              },
              child: Text(mood, style: const TextStyle(fontSize: 28)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
