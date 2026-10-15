import 'package:flutter/material.dart';
import 'add_entry_screen.dart';
import '../models/journal_entry.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_entry_screen.dart';
import 'package:flutter/services.dart';


class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('journal_entries');

    if (entriesJson != null) {
      setState(() {
        _entries
          ..clear()
          ..addAll(
            entriesJson.map(
              (e) => JournalEntry.fromJson(jsonDecode(e)),
            ),
          );
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson =
        _entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('journal_entries', entriesJson);
  }

  // STEP 5 — EXPORT / BACKUP
  Future<void> _exportJournal() async {
    final data = _entries.map((e) => e.toJson()).toList();
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(data);

    debugPrint(jsonString);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal exported to console'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportJournal,
          ),
        ],
      ),
      body: _entries.isEmpty
          ? const Center(
              child: Text(
                'No entries yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];

                return Dismissible(
                  key: ValueKey(entry.date.toIso8601String()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child:
                        const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete entry'),
                        content: const Text(
                          'Are you sure you want to delete this entry?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    HapticFeedback.mediumImpact();
                    setState(() => _entries.removeAt(index));
                    await _saveEntries();
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      key: ValueKey(entry.date.toIso8601String()),
                      margin: const EdgeInsets.all(8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.mood ?? '🙂',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      final updated =
                                          await Navigator.push<
                                              JournalEntry>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditEntryScreen(
                                                  entry: entry),
                                        ),
                                      );
                                      if (updated != null) {
                                        HapticFeedback
                                            .selectionClick();
                                        setState(() =>
                                            _entries[index] = updated);
                                        await _saveEntries();
                                      }
                                    }

                                    if (value == 'delete') {
                                      HapticFeedback
                                          .mediumImpact();
                                      setState(() =>
                                          _entries.removeAt(index));
                                      await _saveEntries();
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit')),
                                    PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete')),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm')
                                  .format(entry.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit),
        label: const Text('New entry'),
        onPressed: () async {
          final result =
              await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEntryScreen(),
            ),
          );

          if (result != null &&
              result['text'].toString().trim().isNotEmpty) {
            HapticFeedback.lightImpact();
            setState(() {
              _entries.insert(
                0,
                JournalEntry(
                  text: result['text'],
                  mood: result['mood'],
                  date: DateTime.now(),
                ),
              );
            });
            await _saveEntries();
          }
        },
      ),
    ); 
  }
}
