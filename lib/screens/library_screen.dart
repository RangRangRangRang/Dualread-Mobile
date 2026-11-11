import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/book_item.dart';
import '../services/epub_service.dart';
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
  bool importing = false;

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

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> pickBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => importing = true);
    try {
      final book = await EpubService.importBook(result.files.single.path!);
      await StorageService.addBook(book);
      await loadData();
      showMessage('Đã thêm sách: ${book.title}');
    } catch (e) {
      showMessage('Không đọc được file EPUB này');
    }
    setState(() => importing = false);
  }

  @override
  Widget build(BuildContext context) {
    final shown = books;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: importing ? null : pickBook,
        icon: const Icon(Icons.add),
        label: const Text('Thêm EPUB'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (importing) const LinearProgressIndicator(),
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
