import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherWidget extends StatelessWidget {
  Future<String> fetchWeather() async {
    const city = 'Nakhon Ratchasima';
    const apikey = 'a0d63355b66540d793c104957242409';

    final response = await http.get(Uri.parse(
      'http://api.weatherapi.com/v1/current.json?key=$apikey&q=$city&aqi=no',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return 'นครราชสีมา อุณหภูมิ: ${data['current']['temp_c']} °C';
    } else {
      return 'ไม่สามารถโหลดข้อมูลสภาพอากาศ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100], // สีพื้นหลัง
      ),
      home: NoteApp(), // เรียกใช้ NoteApp ที่เราสร้างขึ้น
    );
  }
}

class NoteApp extends StatefulWidget {
  @override
  _NoteAppState createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesData = prefs.getString('notes');

    if (notesData != null) {
      setState(() {
        List<dynamic> jsonData = jsonDecode(notesData);
        notes = jsonData.map((item) => Note.fromJson(item)).toList();
      });
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonData = notes.map((note) => note.toJson()).toList();
    prefs.setString('notes', jsonEncode(jsonData));
  }

  void addNote(String title, String content) {
    if (title.isNotEmpty) {
      setState(() {
        notes.add(Note(
          title: title,
          content: content,
          reminderDate: DateTime.now().add(Duration(days: 1)),
          createdDate: DateTime.now(),
          lastModifiedDate: DateTime.now(),
        ));
      });
      saveNotes();
    }
  }

  void editNote(Note note) {
    TextEditingController titleController = TextEditingController(text: note.title);
    TextEditingController contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  note.title = titleController.text;
                  note.content = contentController.text;
                  note.lastModifiedDate = DateTime.now();
                });
                saveNotes();
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void deleteNote(Note note) {
    setState(() {
      notes.remove(note);
    });
    saveNotes();
  }

  void showAddNoteDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Note', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addNote(titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: WeatherWidget().fetchWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading Weather...');
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              return Text(snapshot.data ?? 'No Data');
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            elevation: 4,
            child: ListTile(
              title: Text(notes[index].title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'วันเดือนปีที่สร้าง: ${notes[index].createdDate.toLocal().toString().split(' ')[0]} ${notes[index].createdDate.toLocal().toString().split(' ')[1].substring(0, 5)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'แก้ไขล่าสุด: ${notes[index].lastModifiedDate.toLocal().toString().split(' ')[0]} ${notes[index].lastModifiedDate.toLocal().toString().split(' ')[1].substring(0, 5)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () => editNote(notes[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteNote(notes[index]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddNoteDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.green[500],
        foregroundColor: Colors.white,
      ),
    );
  }
}

class Note {
  String title;
  String content;
  DateTime reminderDate;
  DateTime createdDate;
  DateTime lastModifiedDate;

  Note({
    required this.title,
    required this.content,
    required this.reminderDate,
    required this.createdDate,
    required this.lastModifiedDate,
  });

  // Convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'reminderDate': reminderDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'lastModifiedDate': lastModifiedDate.toIso8601String(),
    };
  }

  // Convert JSON to Note
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      reminderDate: DateTime.parse(json['reminderDate']),
      createdDate: DateTime.parse(json['createdDate']),
      lastModifiedDate: DateTime.parse(json['lastModifiedDate']),
    );
  }
}
