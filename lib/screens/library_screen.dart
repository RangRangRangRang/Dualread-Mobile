import 'package:flutter/material.dart';
import '../models/book_item.dart';
import '../services/storage_service.dart';
import '../widgets/book_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<BookItem> books = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await StorageService.loadBooks();
    setState(() {
      books = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shown = books;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: shown.isEmpty
                      ? const Center(child: Text('Chưa có sách nào'))
                      : ListView.builder(
                          itemCount: shown.length,
                          itemBuilder: (ctx, i) {
                            final book = shown[i];
                            return BookTile(
                              book: book,
                              onTap: () {},
                              onMenu: (value) {},
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}