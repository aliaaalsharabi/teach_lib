import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teach_lib/viewmodels/student_viewmodel.dart';
import 'package:teach_lib/models/enums/student.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentViewModel>(context, listen: false).loadStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _classController.dispose();
    _divisionController.dispose();
    super.dispose();
  }

  // دالة عرض نافذة إضافة طالب جديد
  Future<void> _showAddStudentDialog() async {
    _nameController.clear();
    _classController.clear();
    _divisionController.clear();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة طالب جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'الصف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _divisionController,
                decoration: const InputDecoration(
                  labelText: 'الشعبة',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final student = Student(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text.trim(),
                    classRoom: _classController.text.trim(),
                    division: _divisionController.text.trim(),
                  );
                  Provider.of<StudentViewModel>(context, listen: false)
                      .addStudent(student)
                      .then((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تمت إضافة الطالب بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إدخال اسم الطالب'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  // دالة عرض نافذة تعديل طالب
  Future<void> _showEditStudentDialog(Student student) async {
    _nameController.text = student.name;
    _classController.text = student.classRoom;
    _divisionController.text = student.division;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل بيانات الطالب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'الصف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _divisionController,
                decoration: const InputDecoration(
                  labelText: 'الشعبة',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final updatedStudent = Student(
                    id: student.id,
                    name: _nameController.text.trim(),
                    classRoom: _classController.text.trim(),
                    division: _divisionController.text.trim(),
                  );
                  Provider.of<StudentViewModel>(context, listen: false)
                      .editStudent(updatedStudent)
                      .then((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تعديل بيانات الطالب بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إدخال اسم الطالب'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  // دالة تأكيد الحذف
  void _showDeleteDialog(String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الطالب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<StudentViewModel>(context, listen: false)
                  .deleteStudent(studentId)
                  .then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف الطالب بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudentViewModel>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلاب'),
        centerTitle: true,
        actions: [
          // زر استيراد CSV (يمكن تفعيله لاحقاً)
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ميزة استيراد CSV قريباً'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'بحث عن طالب...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) => viewModel.searchStudents(query),
            ),
          ),

          // عرض قائمة الطلاب أو رسالة التحميل
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.students.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد طلاب',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على زر + لإضافة طالب جديد',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () => viewModel.loadStudents(),
              child: isDesktop
                  ? _buildDataTable(viewModel)
                  : _buildCardList(viewModel),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // عرض الطلاب كجدول (مناسب للابتوب)
  Widget _buildDataTable(StudentViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الاسم', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الصف', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الشعبة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: viewModel.students.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(student.name)),
                DataCell(Text(student.classRoom)),
                DataCell(Text(student.division)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditStudentDialog(student),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(student.id),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // عرض الطلاب كبطاقات (مناسب للجوال)
  Widget _buildCardList(StudentViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.students.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final student = viewModel.students[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${student.classRoom} - ${student.division}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _showEditStudentDialog(student),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteDialog(student.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}