import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_tab.dart';
import 'scan_tab.dart';
import 'progress_tab.dart';
import 'reports_tab.dart';
import 'assistant_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    ScanTab(),
    ProgressTab(),
    ReportsTab(),
    AssistantTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.camera_viewfinder),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'AI Assistant',
          ),
        ],
      ),
    );
  }
}
