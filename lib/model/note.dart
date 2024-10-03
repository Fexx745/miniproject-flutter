// คลาส Note สำหรับเก็บข้อมูลบันทึก
class Note {
  String title;
  String content;
  DateTime createdDate;
  DateTime lastModifiedDate;
  DateTime reminderDate;

  // ตัวสร้าง (Constructor) สำหรับสร้างอ็อบเจ็กต์ Note
  Note({
    required this.title,
    required this.content,
    required this.createdDate,
    required this.lastModifiedDate,
    required this.reminderDate,
  });

  // แปลงข้อมูล Note เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'createdDate': createdDate.toIso8601String(),
      'lastModifiedDate': lastModifiedDate.toIso8601String(),
      'reminderDate': reminderDate.toIso8601String(),
    };
  }

  // สร้างอ็อบเจ็กต์ Note จากข้อมูล JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      createdDate: DateTime.parse(json['createdDate']),
      lastModifiedDate: DateTime.parse(json['lastModifiedDate']),
      reminderDate: DateTime.parse(json['reminderDate']),
    );
  }
}
