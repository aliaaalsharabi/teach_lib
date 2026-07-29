import 'package:flutter/material.dart';
import 'package:teach_lib/database//database_helper.dart';
import 'package:teach_lib/models/enums/book.dart';

class BookViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Book> _books = [];
  bool _isLoading = false;
  String _message = '';

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String get message => _message;

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _books = await _db.getAllBooks();
      _message = '';
    } catch (e) {
      _message = 'فشل التحميل: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchBooks(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (query.isEmpty) {
        _books = await _db.getAllBooks();
      } else {
        _books = await _db.searchBooks(query);
      }
      _message = '';
    } catch (e) {
      _message = 'فشل البحث: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    try {
      await _db.insertBook(book);
      await loadBooks();
      _message = 'تمت إضافة الكتاب بنجاح';
    } catch (e) {
      _message = 'فشل الإضافة: $e';
    }
    notifyListeners();
  }

  Future<void> editBook(Book book) async {
    try {
      await _db.updateBook(book);
      await loadBooks();
      _message = 'تم التعديل بنجاح';
    } catch (e) {
      _message = 'فشل التعديل: $e';
    }
    notifyListeners();
  }

  Future<void> deleteBook(String id) async {
    try {
      await _db.deleteBook(id);
      await loadBooks();
      _message = 'تم الحذف بنجاح';
    } catch (e) {
      _message = 'فشل الحذف: $e';
    }
    notifyListeners();
  }
}