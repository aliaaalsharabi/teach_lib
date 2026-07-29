import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teach_lib/services/report_service.dart';
import 'package:teach_lib/viewmodels/borrowing_viewmodel.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BorrowingViewModel>(context, listen: false).loadOverdue();
    });
  }

  Future<void> _generateAndShareReport(DateTime start, DateTime end) async {
    setState(() => _isGenerating = true);
    try {
      await _reportService.shareReport(start, end);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء التقرير ومشاركته بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إنشاء التقرير: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borrowVM = Provider.of<BorrowingViewModel>(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الكتب المتأخرة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الكتب المتأخرة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('عدد الكتب المتأخرة: ${borrowVM.overdueList.length}'),
                    const SizedBox(height: 16),
                    if (borrowVM.overdueList.isNotEmpty)
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: borrowVM.overdueList.length,
                          itemBuilder: (context, index) {
                            final borrowing = borrowVM.overdueList[index];
                            return ListTile(
                              title: Text('معرف الطالب: ${borrowing.studentId}'),
                              subtitle: Text('تاريخ الاستحقاق: ${borrowing.dueDate.toLocal().toString().split(' ')[0]}'),
                              leading: const Icon(Icons.warning, color: Colors.orange),
                            );
                          },
                        ),
                      )
                    else
                      const Text('لا توجد كتب متأخرة', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // أزرار التقارير
            const Text(
              'إنشاء تقرير',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateAndShareReport(
                      now.subtract(const Duration(days: 7)),
                      now,
                    ),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('تقرير أسبوعي'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateAndShareReport(
                      DateTime(now.year, now.month, 1),
                      now,
                    ),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('تقرير شهري'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _generateAndShareReport(
                  DateTime(now.year, 1, 1),
                  now,
                ),
                icon: const Icon(Icons.calendar_view_day),
                label: const Text('تقرير سنوي'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}