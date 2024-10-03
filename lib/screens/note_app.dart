import 'package:flutter/material.dart';
import 'package:flutter_application_3/model/note.dart'; // Import โมเดล Note
import 'package:flutter_application_3/services/weather_service.dart'; // Import Service สภาพอากาศ
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    List<Map<String, dynamic>> jsonData =
        notes.map((note) => note.toJson()).toList();
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
    TextEditingController titleController =
        TextEditingController(text: note.title);
    TextEditingController contentController =
        TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('แก้ไขบันทึก'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'ชื่อ')),
              SizedBox(height: 10),
              TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'เนื้อหา'),
                  maxLines: 5),
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
              child: Text('บันทึก'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก'),
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

  void deleteNoteWithConfirmation(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบโน๊ตนี้?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  notes.remove(note); // ลบโน๊ตจากรายการ
                });
                saveNotes(); // บันทึกการเปลี่ยนแปลง
                Navigator.of(context).pop(); // ปิด Popup
              },
              child: Text('ลบ', style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // ปิด Popup ถ้าไม่ต้องการลบ
              child: Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  void showAddNoteDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('เพิ่มบันทึก'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'ชื่อ')),
              SizedBox(height: 10),
              TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'เนื้อหา'),
                  maxLines: 5),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addNote(titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
              child: Text('เพิ่ม'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.tealAccent[700],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String>(
            future: WeatherService().fetchWeather(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('กำลังโหลดสภาพอากาศ...');
              } else if (snapshot.hasError) {
                return Text('ข้อผิดพลาดในการโหลดสภาพอากาศ');
              } else {
                return Text(snapshot.data ?? '');
              }
            },
          ),
        ),
        body: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.teal[50], // เพิ่มสี background ให้กับ card
              child: ListTile(
                title: Text(
                  notes[index].title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18), // ปรับแต่งฟอนต์ของชื่อ
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('สร้างเมื่อ: ${notes[index].createdDate.toLocal()}'),
                    Text(
                        'แก้ไขล่าสุด: ${notes[index].lastModifiedDate.toLocal()}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.teal[700]),
                      onPressed: () => editNote(notes[index]),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => deleteNoteWithConfirmation(
                          notes[index]), // เรียกใช้ฟังก์ชันใหม่
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: showAddNoteDialog,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
