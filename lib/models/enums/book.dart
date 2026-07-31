class Book {
  final String id;
  final int bookIndex; // تم تغييره من index إلى bookIndex
  final String title;
  final String section;
  final bool isAvailable;

  Book({
    required this.id,
    required this.bookIndex,
    required this.title,
    required this.section,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookIndex': bookIndex,
      'title': title,
      'section': section,
      'isAvailable': isAvailable ? 1 : 0,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      bookIndex: map['bookIndex'] ?? 0,
      title: map['title'] ?? '',
      section: map['section'] ?? '',
      isAvailable: (map['isAvailable'] ?? 1) == 1,
    );
  }
}