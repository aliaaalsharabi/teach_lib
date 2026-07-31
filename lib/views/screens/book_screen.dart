import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teach_lib/viewmodels/book_viewmodel.dart';
import 'package:teach_lib/models/enums/book.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookViewModel>(context, listen: false).loadBooks();
    });
  }

  Future<void> _showAddBookDialog() async {
    final indexController = TextEditingController();
    final titleController = TextEditingController();
    final sectionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة كتاب جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: indexController, decoration: const InputDecoration(labelText: 'رقم الفهرس'), keyboardType: TextInputType.number),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'العنوان')),
              TextField(controller: sectionController, decoration: const InputDecoration(labelText: 'القسم')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final book = Book(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    bookIndex: int.tryParse(indexController.text) ?? 0,
                    title: titleController.text,
                    section: sectionController.text,
                    isAvailable: true,
                  );
                  Provider.of<BookViewModel>(context, listen: false).addBook(book);
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الكتب'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'بحث عن كتاب...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (query) => viewModel.searchBooks(query),
            ),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.books.isEmpty
                ? const Center(child: Text('لا يوجد كتب'))
                : ListView.builder(
              itemCount: viewModel.books.length,
              itemBuilder: (context, index) {
                final book = viewModel.books[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${book.bookIndex}'),
                  ),
                  title: Text(book.title),
                  subtitle: Text(book.section),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        book.isAvailable ? Icons.check_circle : Icons.block,
                        color: book.isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('تأكيد الحذف'),
                              content: const Text('هل أنت متأكد من حذف هذا الكتاب؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                                TextButton(
                                  onPressed: () {
                                    viewModel.deleteBook(book.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('حذف', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}