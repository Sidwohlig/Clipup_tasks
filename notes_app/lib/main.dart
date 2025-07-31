import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

void main() {
  runApp(const DreamNotesApp());
}

class DreamNotesApp extends StatelessWidget {
  const DreamNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Notes',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.blue,
      ),
      home: const DreamNotesScreen(),
    );
  }
}

class DreamNotesScreen extends StatefulWidget {
  const DreamNotesScreen({super.key});

  @override
  DreamNotesScreenState createState() => DreamNotesScreenState(); // Fixed typo
}

class DreamNotesScreenState extends State<DreamNotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _mood = 'Happy';
  String _responseMessage = '';
  List<dynamic> _notes = [];

  // Fetch notes from server
  Future<void> _fetchNotes() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:3000/notes')); // Changed to 127.0.0.1
      if (response.statusCode == 200) {
        setState(() {
          _notes = jsonDecode(response.body);
        });
      } else {
        setState(() {
          _responseMessage = 'Failed to fetch notes: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
      });
    }
  }

  // Create a new note
  Future<void> _createNote() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/notes'), // Changed to 127.0.0.1
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'mood': _mood,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _responseMessage = 'Note created!';
          _titleController.clear();
          _descriptionController.clear();
          _mood = 'Happy';
        });
        await _fetchNotes(); // Refresh notes list
      } else {
        setState(() {
          _responseMessage = 'Error: ${jsonDecode(response.body)['error'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Request failed: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNotes(); // Load notes on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dream Notes',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Form
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: _mood,
                          isExpanded: true,
                          items: ['Happy', 'Inspired', 'Calm', 'Excited', 'Deep Thought']
                              .map((mood) => DropdownMenuItem(
                                    value: mood,
                                    child: Text(mood),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _mood = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _createNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add Dream Note'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _responseMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Notes List
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    note['title'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${note['description']} • Mood: ${note['mood']}',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  trailing: Icon(
                                    Icons.star,
                                    color: note['mood'] == 'Happy'
                                        ? Colors.yellow
                                        : note['mood'] == 'Inspired'
                                            ? Colors.green
                                            : note['mood'] == 'Calm'
                                                ? Colors.blue
                                                : note['mood'] == 'Excited'
                                                    ? Colors.red
                                                    : Colors.purple, // For "Deep Thought"
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}