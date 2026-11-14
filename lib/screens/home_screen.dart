import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'album_screen.dart';
import 'library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    LibraryScreen(),
    AlbumScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Thư viện'),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark),
            label: 'Album',
          ),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Thông tin nhóm'),
        ],
      ),
    );
  }
}
