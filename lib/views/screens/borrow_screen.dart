import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teach_lib/viewmodels/borrowing_viewmodel.dart';
import 'package:teach_lib/viewmodels/student_viewmodel.dart';
import 'package:teach_lib/viewmodels/book_viewmodel.dart';
import 'package:teach_lib/models/enums/student.dart';
import 'package:teach_lib/models/enums/book.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  String? _selectedStudentId;
  String? _selectedBookId;
  final TextEditingController _studentSearchController = TextEditingController();
  final TextEditingController _bookSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentVM = Provider.of<StudentViewModel>(context, listen: false);
      final bookVM = Provider.of<BookViewModel>(context, listen: false);
      final borrowVM = Provider.of<BorrowingViewModel>(context, listen: false);

      studentVM.loadStudents();
      bookVM.loadBooks();
      borrowVM.loadActiveLoans();
      borrowVM.loadOverdue();
    });
  }

  @override
  void dispose() {
    _studentSearchController.dispose();
    _bookSearchController.dispose();
    super.dispose();
  }

  Future<void> _performBorrow(BuildContext context) async {
    if (_selectedStudentId == null || _selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار طالب وكتاب'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final borrowVM = Provider.of<BorrowingViewModel>(context, listen: false);
    await borrowVM.borrowBook(_selectedStudentId!, _selectedBookId!);

    if (borrowVM.message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(borrowVM.message),
          backgroundColor: borrowVM.message.contains('نجاح') ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      _selectedStudentId = null;
      _selectedBookId = null;
      _studentSearchController.clear();
      _bookSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final borrowVM = Provider.of<BorrowingViewModel>(context);
    final studentVM = Provider.of<StudentViewModel>(context);
    final bookVM = Provider.of<BookViewModel>(context);

    final availableBooks = bookVM.books.where((b) => b.isAvailable).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الإعارة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              studentVM.loadStudents();
              bookVM.loadBooks();
              borrowVM.loadActiveLoans();
              borrowVM.loadOverdue();
            },
          ),
        ],
      ),
      body: borrowVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          // حساب الارتفاع المتاح بعد خصم الـ AppBar والـ Padding
          final availableHeight = constraints.maxHeight;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---------- اختيار الطالب ----------
                  const Text(
                    'اختر الطالب:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _studentSearchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن طالب...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (query) {
                      if (query.isEmpty) {
                        studentVM.loadStudents();
                      } else {
                        studentVM.searchStudents(query);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('-- اختر طالباً --'),
                        ),
                        value: _selectedStudentId,
                        items: studentVM.students.map((student) {
                          return DropdownMenuItem(
                            value: student.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '${student.name} (${student.classRoom} - ${student.division})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedStudentId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- اختيار الكتاب ----------
                  const Text(
                    'اختر الكتاب:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bookSearchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن كتاب...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (query) {
                      if (query.isEmpty) {
                        bookVM.loadBooks();
                      } else {
                        bookVM.searchBooks(query);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('-- اختر كتاباً --'),
                        ),
                        value: _selectedBookId,
                        items: availableBooks.map((book) {
                          return DropdownMenuItem(
                            value: book.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '${book.bookIndex} - ${book.title} (${book.section})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedBookId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- زر الإعارة ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: borrowVM.isLoading ? null : () => _performBorrow(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: borrowVM.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'تسجيل الإعارة',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- عرض الإعارات النشطة ----------
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإعارات النشطة:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${borrowVM.activeLoans.length} كتاب',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // قائمة الإعارات النشطة بارتفاع محدد
                  SizedBox(
                    height: availableHeight * 0.35, // 35% من ارتفاع الشاشة
                    child: borrowVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : borrowVM.activeLoans.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد إعارات نشطة',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      itemCount: borrowVM.activeLoans.length,
                      itemBuilder: (context, index) {
                        final borrowing = borrowVM.activeLoans[index];
                        final student = studentVM.students.firstWhere(
                              (s) => s.id == borrowing.studentId,
                          orElse: () => Student(
                            id: '',
                            name: 'غير معروف',
                            classRoom: '',
                            division: '',
                          ),
                        );
                        final book = bookVM.books.firstWhere(
                              (b) => b.id == borrowing.bookId,
                          orElse: () => Book(
                            id: '',
                            bookIndex: 0,
                            title: 'غير معروف',
                            section: '',
                            isAvailable: false,
                          ),
                        );
                        final daysLeft = borrowing.dueDate.difference(DateTime.now()).inDays;
                        final isOverdue = daysLeft < 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isOverdue ? Colors.red : Colors.blue,
                              child: Text(
                                '${book.bookIndex}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(
                              book.title,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الطالب: ${student.name}'),
                                Text(
                                  'تاريخ الاستحقاق: ${borrowing.dueDate.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(
                                    color: isOverdue ? Colors.red : Colors.grey[600],
                                  ),
                                ),
                                if (isOverdue)
                                  Text(
                                    'متأخر ${daysLeft.abs()} يوم',
                                    style: const TextStyle(
                                        color: Colors.red, fontWeight: FontWeight.bold),
                                  )
                                else
                                  Text(
                                    'متبقي $daysLeft يوم',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تأكيد الإرجاع'),
                                    content: Text(
                                        'هل أنت متأكد من إرجاع كتاب "${book.title}"؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          borrowVM.returnBook(borrowing.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('تأكيد الإرجاع'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}