import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController _controller;
  late String _selectedMood;

  // ✅ include all emojis used anywhere in the app
  final List<String> moods = ['😄', '🙂', '😐', '😔', '😡', '😟', '😰'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.text);

    // ✅ default to first mood if current mood isn't in the list
    if (widget.entry.mood != null && moods.contains(widget.entry.mood)) {
      _selectedMood = widget.entry.mood!;
    } else {
      _selectedMood = moods[0];
    }
  }

  void _save() {
    if (_controller.text.trim().isEmpty) return;

    Navigator.pop(
      context,
      JournalEntry(
        text: _controller.text.trim(),
        date: widget.entry.date,
        mood: _selectedMood,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Dropdown with safe initial value
            DropdownButton<String>(
              value: _selectedMood,
              isExpanded: true,
              items: moods
                  .map(
                    (mood) => DropdownMenuItem(
                      value: mood,
                      child: Text(
                        mood,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMood = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
