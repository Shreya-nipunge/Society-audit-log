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
      'name': title,
      'type': category, // Typically 'PDF', 'Doc', etc. based on ERD
      'url': fileName, // The storage URL
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      // Local App properties
      'id': id,
      'category': category,
      'fileName': fileName,
      'visibility': visibility,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DocumentModel(
      id: docId,
      title: map['name'] ?? map['title'] ?? '',
      category: map['type'] ?? map['category'] ?? 'Circulars',
      fileName: map['url'] ?? map['fileName'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: map['uploadedAt'] != null ? DateTime.parse(map['uploadedAt']) : DateTime.now(),
      visibility: map['visibility'] ?? 'member',
    );
  }
}
