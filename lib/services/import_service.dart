import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:teach_lib/database/database_helper.dart';
import 'package:teach_lib/models/enums/student.dart';
import 'package:teach_lib/models/enums/book.dart';

class ImportService {
  final DatabaseHelper _db = DatabaseHelper();

  // استيراد الطلاب من CSV
  Future<String> importStudentsFromCSV(File file) async {
    try {
      final input = file.openRead();
      final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();
      int count = 0;
      for (var row in fields.skip(1)) {
        if (row.length < 3) continue;
        final student = Student(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_${count++}',
          name: row[0].toString().trim(),
          classRoom: row[1].toString().trim(),
          division: row[2].toString().trim(),
        );
        await _db.insertStudent(student);
      }
      return 'تم استيراد ${fields.length - 1} طالب/طالبة بنجاح';
    } catch (e) {
      return 'فشل الاستيراد: $e';
    }
  }

  // استيراد الكتب من CSV
  Future<String> importBooksFromCSV(File file) async {
    try {
      final input = file.openRead();
      final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();
      int count = 0;
      for (var row in fields.skip(1)) {
        if (row.length < 3) continue;
        final book = Book(
          id: 'book_${DateTime.now().millisecondsSinceEpoch}_${count++}',
          bookIndex: int.tryParse(row[0].toString()) ?? 0,
          title: row[1].toString().trim(),
          section: row[2].toString().trim(),
          isAvailable: true,
        );
        await _db.insertBook(book);
      }
      return 'تم استيراد ${fields.length - 1} كتاب بنجاح';
    } catch (e) {
      return 'فشل الاستيراد: $e';
    }
  }

  // ✅ الطريقة الأولى: استخدام pickFiles مع withData: true
  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // ✅ مهم: يجلب الملف كـ bytes و path معاً
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('خطأ في pickFile: $e');
      return null;
    }
  }

  // ✅ الطريقة الثانية: استخدام pickFiles مع قراءة الملف مباشرة
  Future<String?> importStudentsFromCSVFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return 'لم يتم اختيار أي ملف';
      }

      final file = result.files.single;

      // إذا كان الملف موجود كـ bytes (يعمل على جميع المنصات)
      if (file.bytes != null) {
        final String content = utf8.decode(file.bytes!);
        final fields = const CsvToListConverter().convert(content);
        int count = 0;
        for (var row in fields.skip(1)) {
          if (row.length < 3) continue;
          final student = Student(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_${count++}',
            name: row[0].toString().trim(),
            classRoom: row[1].toString().trim(),
            division: row[2].toString().trim(),
          );
          await _db.insertStudent(student);
        }
        return 'تم استيراد ${fields.length - 1} طالب/طالبة بنجاح';
      }

      // إذا كان الملف موجود كـ path (للجوال وسطح المكتب)
      if (file.path != null) {
        final input = File(file.path!).openRead();
        final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();
        int count = 0;
        for (var row in fields.skip(1)) {
          if (row.length < 3) continue;
          final student = Student(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_${count++}',
            name: row[0].toString().trim(),
            classRoom: row[1].toString().trim(),
            division: row[2].toString().trim(),
          );
          await _db.insertStudent(student);
        }
        return 'تم استيراد ${fields.length - 1} طالب/طالبة بنجاح';
      }

      return 'فشل قراءة الملف';
    } catch (e) {
      return 'فشل الاستيراد: $e';
    }
  }

  // ✅ الطريقة الثالثة: اختيار ملف بطريقة بديلة (لـ Windows)
  Future<File?> pickFileAlternative() async {
    try {
      // استخدام طريقة مختلفة لاختيار الملف
      final result = await FilePicker.pickFiles(
        type: FileType.any, // أي نوع ملف
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        // التحقق من امتداد الملف
        if (filePath.endsWith('.csv')) {
          return File(filePath);
        }
      }
      return null;
    } catch (e) {
      print('خطأ في pickFileAlternative: $e');
      return null;
    }
  }
}