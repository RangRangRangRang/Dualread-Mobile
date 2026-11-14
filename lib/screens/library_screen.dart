import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/book_item.dart';
import '../services/album_service.dart';
import '../services/epub_service.dart';
import '../services/storage_service.dart';
import '../widgets/book_tile.dart';
import 'album_screen.dart';
import 'reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<BookItem> books = [];
  bool loading = true;
  bool importing = false;
  String keyword = '';

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

  Future<void> confirmDelete(BookItem book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sách'),
        content: Text('Bạn có chắc muốn xóa "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await StorageService.deleteBook(book);
      await loadData();
    }
  }

  Future<void> pickDate(BookItem book) async {
    final date = await showDatePicker(
      context: context,
      initialDate: book.targetDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    await StorageService.saveTargetDate(book.id, date);
    await loadData();
  }

  Future<void> chooseAlbums(BookItem book) async {
    final albums = await AlbumService.loadAlbums();
    if (!mounted) return;

    if (albums.isEmpty) {
      showMessage('Chưa có album nào. Hãy tạo album trước.');
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm vào album'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: albums.map((Album a) {
                    return CheckboxListTile(
                      title: Text(a.name),
                      value: a.bookIds.contains(book.id),
                      onChanged: (value) async {
                        await AlbumService.toggleBookInAlbum(
                            a.id, book.id, value == true);
                        setDialogState(() {
                          if (value == true) {
                            a.bookIds.add(book.id);
                          } else {
                            a.bookIds.remove(book.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Xong'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showStats() async {
    final albums = await AlbumService.loadAlbums();
    if (!mounted) return;

    final Map<String, int> byAuthor = {};
    for (final b in books) {
      byAuthor[b.author] = (byAuthor[b.author] ?? 0) + 1;
    }
    final reading = books.where((b) => b.lastChapter > 0).length;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thống kê'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tổng số sách: ${books.length}'),
              Text('Đang đọc: $reading'),
              Text('Chưa đọc: ${books.length - reading}'),
              Text('Số album: ${albums.length}'),
              const SizedBox(height: 12),
              const Text(
                'Số sách theo tác giả',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...byAuthor.entries.map((e) => Text('${e.key}: ${e.value}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void handleMenu(String value, BookItem book) {
    switch (value) {
      case 'album':
        chooseAlbums(book);
        break;
      case 'date':
        pickDate(book);
        break;
      case 'delete':
        confirmDelete(book);
        break;
    }
  }

  Future<void> openReader(BookItem book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
    );
    await loadData();
  }

  Future<void> openAlbums() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlbumScreen()),
    );
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    final shown = books
        .where((b) =>
            b.title.toLowerCase().contains(keyword.toLowerCase()) ||
            b.author.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Thống kê',
            onPressed: showStats,
          ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark),
            tooltip: 'Album',
            onPressed: openAlbums,
          ),
        ],
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
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tìm theo tên sách hoặc tác giả',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => keyword = value),
                  ),
                ),
                Expanded(
                  child: shown.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/book.png', width: 90),
                              const SizedBox(height: 12),
                              const Text('Chưa có sách nào'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: shown.length,
                          itemBuilder: (ctx, i) {
                            final book = shown[i];
                            return BookTile(
                              book: book,
                              onTap: () => openReader(book),
                              onMenu: (value) => handleMenu(value, book),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}