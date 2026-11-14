import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
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
  void initState() {
    super.initState();
    AppStrings.language.addListener(refresh);
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    AppStrings.language.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book),
            label: AppStrings.get('library'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.collections_bookmark),
            label: AppStrings.get('albumTitle'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups),
            label: AppStrings.get('aboutTitle'),
          ),
        ],
      ),
    );
  }
}
