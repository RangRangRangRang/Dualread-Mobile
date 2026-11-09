import 'package:flutter/material.dart';
import 'screens/library_screen.dart';

void main() {
  runApp(const DualReadApp());
}

class DualReadApp extends StatelessWidget {
  const DualReadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DualRead',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Tinos',
      ),
      home: const LibraryScreen(),
    );
  }
}