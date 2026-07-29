import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:teach_lib/models/enums/student.dart';

class StudentViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Student> _students = [];
  bool _isLoading = false;
  String _message = '';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get message => _message;

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      _students = await _db.getAllStudents();
      _message = '';
    } catch (e) {
      _message = 'فشل التحميل: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchStudents(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (query.isEmpty) {
        _students = await _db.getAllStudents();
      } else {
        _students = await _db.searchStudents(query);
      }
      _message = '';
    } catch (e) {
      _message = 'فشل البحث: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    try {
      await _db.insertStudent(student);
      await loadStudents();
      _message = 'تمت إضافة الطالب بنجاح';
    } catch (e) {
      _message = 'فشل الإضافة: $e';
    }
    notifyListeners();
  }

  Future<void> editStudent(Student student) async {
    try {
      await _db.updateStudent(student);
      await loadStudents();
      _message = 'تم التعديل بنجاح';
    } catch (e) {
      _message = 'فشل التعديل: $e';
    }
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _db.deleteStudent(id);
      await loadStudents();
      _message = 'تم الحذف بنجاح';
    } catch (e) {
      _message = 'فشل الحذف: $e';
    }
    notifyListeners();
  }
}