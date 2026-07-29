import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teach_lib/viewmodels/borrowing_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final borrowVM = Provider.of<BorrowingViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.people,
              title: 'الطلاب',
              subtitle: 'إدارة الطلاب',
              color: Colors.blue,
              onTap: () {
                // التنقل إلى شاشة الطلاب
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.menu_book,
              title: 'الكتب',
              subtitle: 'إدارة الكتب',
              color: Colors.green,
              onTap: () {
                // التنقل إلى شاشة الكتب
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.swap_horiz,
              title: 'الإعارة',
              subtitle: 'تسجيل الإعارات',
              color: Colors.orange,
              onTap: () {
                // التنقل إلى شاشة الإعارة
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.warning_amber,
              title: 'الكتب المتأخرة',
              subtitle: '${borrowVM.overdueList.length} كتاب متأخر',
              color: Colors.red,
              onTap: () {
                // التنقل إلى شاشة التقارير
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}