class NoticeModel {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String status;
  final String author;

  NoticeModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.status,
    required this.author,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'status': status,
      'author': author,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map, String docId) {
    return NoticeModel(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      status: map['status'] ?? 'Published',
      author: map['author'] ?? 'Admin',
    );
  }
}
