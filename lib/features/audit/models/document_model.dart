class DocumentModel {
  final String id;
  final String title;
  final String
  category; // Annual Reports, Audit Reports, Receipts, Circulars, AGM Minutes
  final String fileName;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String visibility; // 'admin' or 'member'

  DocumentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.fileName,
    required this.uploadedBy,
    required this.uploadedAt,
    this.visibility = 'member',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'fileName': fileName,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'visibility': visibility,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Circulars',
      fileName: map['fileName'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: DateTime.parse(map['uploadedAt']),
      visibility: map['visibility'] ?? 'member',
    );
  }
}
