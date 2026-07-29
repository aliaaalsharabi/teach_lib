class Book {
  final String id;
  final int index; // رقم الفهرس (باركود)
  final String title;
  final String section;
  final bool isAvailable;

  Book({
    required this.id,
    required this.index,
    required this.title,
    required this.section,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'index': index,
      'title': title,
      'section': section,
      'isAvailable': isAvailable ? 1 : 0, // SQLite لا يدعم bool مباشرة
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      index: map['index'] ?? 0,
      title: map['title'] ?? '',
      section: map['section'] ?? '',
      isAvailable: (map['isAvailable'] ?? 1) == 1,
    );
  }
}