import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/student_viewmodel.dart';
import 'viewmodels/book_viewmodel.dart';
import 'viewmodels/borrowing_viewmodel.dart';
import 'views/layouts/base_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentViewModel()..loadStudents()),
        ChangeNotifierProvider(create: (_) => BookViewModel()..loadBooks()),
        ChangeNotifierProvider(create: (_) => BorrowingViewModel()..loadActiveLoans()..loadOverdue()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام المكتبة المدرسية',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Cairo', // تأكد من إضافة الخط في pubspec.yaml
      ),
      debugShowCheckedModeBanner: false,
      home: const BaseLayout(),
    );
  }
}