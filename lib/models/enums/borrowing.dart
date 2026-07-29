import 'package:teach_lib/models/enums/borrowing_status.dart';

class Borrowing {
  final String id;
  final String studentId;
  final String bookId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final BorrowingStatus status;

  Borrowing({
    required this.id,
    required this.studentId,
    required this.bookId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'bookId': bookId,
      'borrowDate': borrowDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status.stringValue,
    };
  }

  factory Borrowing.fromMap(Map<String, dynamic> map) {
    return Borrowing(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      bookId: map['bookId'] ?? '',
      borrowDate: DateTime.parse(map['borrowDate']),
      dueDate: DateTime.parse(map['dueDate']),
      returnDate: map['returnDate'] != null ? DateTime.parse(map['returnDate']) : null,
      status: BorrowingStatusExtension.fromString(map['status'] ?? 'Active'),
    );
  }
}