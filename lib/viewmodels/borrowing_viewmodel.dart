import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:teach_lib/models/enums/borrowing.dart';
import 'package:teach_lib/models/enums/book.dart';
import 'package:teach_lib/models/enums/student.dart';
import 'package:teach_lib/models/enums/borrowing_status.dart';

class BorrowingViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Borrowing> _overdueList = [];
  List<Borrowing> _activeLoans = [];
  bool _isLoading = false;
  String _message = '';

  List<Borrowing> get overdueList => _overdueList;
  List<Borrowing> get activeLoans => _activeLoans;
  bool get isLoading => _isLoading;
  String get message => _message;

  Future<void> loadOverdue() async {
    _isLoading = true;
    notifyListeners();
    try {
      _overdueList = await _db.getOverdueList();
      _message = '';
    } catch (e) {
      _message = 'فشل تحميل المتأخرين: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadActiveLoans() async {
    _isLoading = true;
    notifyListeners();
    try {
      _activeLoans = await _db.getActiveLoans();
      _message = '';
    } catch (e) {
      _message = 'فشل تحميل الإعارات النشطة: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> borrowBook(String studentId, String bookId) async {
    _isLoading = true;
    _message = '';
    notifyListeners();

    try {
      final book = await _db.getBookById(bookId);
      if (book == null) {
        _message = 'الكتاب غير موجود';
        return;
      }
      if (!book.isAvailable) {
        _message = 'الكتاب غير متاح حالياً';
        return;
      }

      final studentLoans = await _db.getBorrowingsByStudent(studentId);
      final activeCount = studentLoans.where((b) => b.status == BorrowingStatus.Active).length;
      if (activeCount >= 3) {
        _message = 'هذا الطالب لديه ٣ كتب حالياً، لا يمكنه استعارة المزيد';
        return;
      }

      final newBorrowing = Borrowing(
        id: 'borrow_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        bookId: bookId,
        borrowDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        returnDate: null,
        status: BorrowingStatus.Active,
      );

      await _db.insertBorrowing(newBorrowing);
      await _db.updateBookAvailability(bookId, false);

      _message = 'تمت الإعارة بنجاح';
      await loadActiveLoans();
      await loadOverdue();
    } catch (e) {
      _message = 'فشلت عملية الإعارة: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> returnBook(String borrowingId) async {
    _isLoading = true;
    _message = '';
    notifyListeners();

    try {
      final db = await _db.database;
      final result = await db.query('borrowings', where: 'id = ?', whereArgs: [borrowingId]);
      if (result.isEmpty) {
        _message = 'سجل الإعارة غير موجود';
        return;
      }
      final borrowing = Borrowing.fromMap(result.first);

      final updatedBorrowing = Borrowing(
        id: borrowing.id,
        studentId: borrowing.studentId,
        bookId: borrowing.bookId,
        borrowDate: borrowing.borrowDate,
        dueDate: borrowing.dueDate,
        returnDate: DateTime.now(),
        status: BorrowingStatus.Returned,
      );
      await _db.updateBorrowing(updatedBorrowing);
      await _db.updateBookAvailability(borrowing.bookId, true);

      _message = 'تم إرجاع الكتاب بنجاح';
      await loadActiveLoans();
      await loadOverdue();
    } catch (e) {
      _message = 'فشلت عملية الإرجاع: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}