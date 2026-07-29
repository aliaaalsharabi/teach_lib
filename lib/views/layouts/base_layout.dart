import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/borrowing_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../viewmodels/book_viewmodel.dart';
import '../screens/dashboard_screen.dart';
import '../screens/students_screen.dart';
import '../screens/book_screen.dart';
import '../screens/borrow_screen.dart';
import '../screens/report_screen.dart';

class BaseLayout extends StatefulWidget {
  const BaseLayout({super.key});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;

  // ✅ الحل: إزالة const من جميع الشاشات
  final List<Widget> _screens = [
    DashboardScreen(),
    StudentsScreen(),
    BooksScreen(),
    BorrowScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        return Scaffold(
          body: isDesktop
              ? Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard),
                    label: Text('الرئيسية'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people),
                    label: Text('الطلاب'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book),
                    label: Text('الكتب'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.swap_horiz),
                    label: Text('الإعارة'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.print),
                    label: Text('التقارير'),
                  ),
                ],
              ),
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          )
              : Column(
            children: [
              Expanded(
                child: _screens[_selectedIndex],
              ),
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'الرئيسية',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'الطلاب',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: 'الكتب',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.swap_horiz),
                    label: 'الإعارة',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.print),
                    label: 'التقارير',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}