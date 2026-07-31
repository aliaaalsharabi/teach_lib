import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/enums/student.dart';
import '../models/enums/book.dart';
import '../models/enums/borrowing.dart';
import '../models/enums/borrowing_status.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'library_school.db');
    return await openDatabase(
      path,
      version: 2, // تم رفع الإصدار بسبب تغيير اسم العمود
      onCreate: (db, version) async {
        // جدول الطلاب
        await db.execute('''
          CREATE TABLE students(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            classRoom TEXT,
            division TEXT
          )
        ''');
        // جدول الكتب (تم تغيير index -> bookIndex)
        await db.execute('''
          CREATE TABLE books(
            id TEXT PRIMARY KEY,
            bookIndex INTEGER UNIQUE NOT NULL,
            title TEXT NOT NULL,
            section TEXT,
            isAvailable INTEGER DEFAULT 1
          )
        ''');
        // جدول الإعارات
        await db.execute('''
          CREATE TABLE borrowings(
            id TEXT PRIMARY KEY,
            studentId TEXT NOT NULL,
            bookId TEXT NOT NULL,
            borrowDate TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            returnDate TEXT,
            status TEXT DEFAULT 'Active',
            FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE,
            FOREIGN KEY (bookId) REFERENCES books(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // في حالة الترقية من الإصدار 1 إلى 2
        if (oldVersion < 2) {
          // ننشئ جدولاً مؤقتاً بالهيكل الجديد
          await db.execute('''
            CREATE TABLE books_temp(
              id TEXT PRIMARY KEY,
              bookIndex INTEGER UNIQUE NOT NULL,
              title TEXT NOT NULL,
              section TEXT,
              isAvailable INTEGER DEFAULT 1
            )
          ''');
          // ننسخ البيانات مع تغيير اسم العمود (إذا كانت هناك بيانات)
          await db.execute('''
            INSERT INTO books_temp (id, bookIndex, title, section, isAvailable)
            SELECT id, index, title, section, isAvailable FROM books
          ''');
          // نحذف الجدول القديم ونعيد تسمية الجديد
          await db.execute('DROP TABLE books');
          await db.execute('ALTER TABLE books_temp RENAME TO books');
        }
      },
    );
  }

  // ========== عمليات الطلاب ==========
  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final result = await db.query('students', orderBy: 'name');
    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<List<Student>> searchStudents(String query) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name',
    );
    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<void> updateStudent(Student student) async {
    final db = await database;
    await db.update('students', student.toMap(), where: 'id = ?', whereArgs: [student.id]);
  }

  Future<void> deleteStudent(String id) async {
    final db = await database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // ========== عمليات الكتب ==========
  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert('books', book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final result = await db.query('books', orderBy: 'bookIndex');
    return result.map((e) => Book.fromMap(e)).toList();
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'title LIKE ? OR section LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title',
    );
    return result.map((e) => Book.fromMap(e)).toList();
  }

  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
  }

  Future<void> deleteBook(String id) async {
    final db = await database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<Book?> getBookById(String id) async {
    final db = await database;
    final result = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Book.fromMap(result.first);
    return null;
  }

  Future<void> updateBookAvailability(String bookId, bool isAvailable) async {
    final db = await database;
    await db.update(
      'books',
      {'isAvailable': isAvailable ? 1 : 0},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // ========== عمليات الإعارة ==========
  Future<void> insertBorrowing(Borrowing borrowing) async {
    final db = await database;
    await db.insert('borrowings', borrowing.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBorrowing(Borrowing borrowing) async {
    final db = await database;
    await db.update('borrowings', borrowing.toMap(), where: 'id = ?', whereArgs: [borrowing.id]);
  }

  Future<List<Borrowing>> getBorrowingsByStudent(String studentId) async {
    final db = await database;
    final result = await db.query(
      'borrowings',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'borrowDate DESC',
    );
    return result.map((e) => Borrowing.fromMap(e)).toList();
  }

  Future<List<Borrowing>> getActiveLoans() async {
    final db = await database;
    final result = await db.query(
      'borrowings',
      where: 'status = ?',
      whereArgs: ['Active'],
      orderBy: 'dueDate ASC',
    );
    return result.map((e) => Borrowing.fromMap(e)).toList();
  }

  Future<List<Borrowing>> getOverdueList() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'borrowings',
      where: 'status = ? AND dueDate < ?',
      whereArgs: ['Active', now],
      orderBy: 'dueDate ASC',
    );
    return result.map((e) => Borrowing.fromMap(e)).toList();
  }

  Future<List<Borrowing>> getBorrowingsBetween(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    final result = await db.query(
      'borrowings',
      where: 'borrowDate >= ? AND borrowDate <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'borrowDate DESC',
    );
    return result.map((e) => Borrowing.fromMap(e)).toList();
  }
}