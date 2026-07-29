import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import '../models/enums/borrowing.dart';
import '../models/enums/book.dart';
import '../models/enums/borrowing_status.dart';  // ✅ استيراد الـ enum مع الـ extension

class ReportService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Borrowing>> _fetchBorrowings(DateTime start, DateTime end) async {
    return await _db.getBorrowingsBetween(start, end);
  }

  Future<File> generateReport(DateTime startDate, DateTime endDate) async {
    final borrowings = await _fetchBorrowings(startDate, endDate);
    final studentNames = <String, String>{};
    final bookTitles = <String, String>{};

    for (var b in borrowings) {
      if (!studentNames.containsKey(b.studentId)) {
        final students = await _db.getAllStudents();
        final student = students.firstWhere(
              (s) => s.id == b.studentId,
          orElse: () => throw Exception('Student not found'),
        );
        studentNames[b.studentId] = student.name;
      }
      if (!bookTitles.containsKey(b.bookId)) {
        final books = await _db.getAllBooks();
        final book = books.firstWhere(
              (b) => b.id == b.id,
          orElse: () => throw Exception('Book not found'),
        );
        bookTitles[b.bookId] = book.title;
      }
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تقرير المكتبة المدرسية', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('من: ${startDate.toLocal()}  إلى: ${endDate.toLocal()}'),
              pw.SizedBox(height: 20),
              pw.Text('إجمالي عدد المعاملات: ${borrowings.length}', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('#', textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('الطالب', textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('الكتاب', textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('تاريخ الإعارة', textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('الحالة', textAlign: pw.TextAlign.center)),
                    ],
                  ),
                  for (int i = 0; i < borrowings.length; i++)
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('${i+1}', textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(studentNames[borrowings[i].studentId] ?? '---', textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(bookTitles[borrowings[i].bookId] ?? '---', textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(borrowings[i].borrowDate.toLocal().toString().split(' ')[0], textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text(borrowings[i].status.stringValue, textAlign: pw.TextAlign.center)), // ✅ الآن يعمل
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('تم التوليد بواسطة نظام إدارة المكتبة', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/تقرير_المكتبة_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> shareReport(DateTime startDate, DateTime endDate) async {
    final file = await generateReport(startDate, endDate);
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'تقرير_المكتبة.pdf');
  }

  Future<void> printReport(DateTime startDate, DateTime endDate) async {
    final file = await generateReport(startDate, endDate);
    await Printing.layoutPdf(onLayout: (_) => file.readAsBytes());
  }
}