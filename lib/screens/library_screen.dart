import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/book_item.dart';
import '../services/album_service.dart';
import '../services/epub_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import '../widgets/book_tile.dart';
import '../widgets/language_switch.dart';
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
    AppStrings.language.addListener(refresh);
    loadData();
  }

  @override
  void dispose() {
    AppStrings.language.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {});
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
      showMessage(AppStrings.format('bookAdded', [book.title]));
    } catch (e) {
      showMessage(AppStrings.get('epubError'));
    }
    setState(() => importing = false);
  }

  Future<void> confirmDelete(BookItem book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('deleteBook')),
        content: Text(AppStrings.format('deleteBookAsk', [book.title])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.get('delete')),
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
      helpText: AppStrings.get('pickDate'),
      cancelText: AppStrings.get('cancel'),
      confirmText: AppStrings.get('ok'),
    );
    if (date == null) return;
    await StorageService.saveTargetDate(book.id, date);
    await loadData();
  }

  Future<void> chooseAlbums(BookItem book) async {
    final albums = await AlbumService.loadAlbums();
    if (!mounted) return;

    if (albums.isEmpty) {
      showMessage(AppStrings.get('noAlbumYet'));
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(AppStrings.get('addToAlbum')),
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
                  child: Text(AppStrings.get('done')),
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
        title: Text(AppStrings.get('statistics')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.format('totalBooks', ['${books.length}'])),
              Text(AppStrings.format('readingCount', ['$reading'])),
              Text(AppStrings.format('unreadCount', ['${books.length - reading}'])),
              Text(AppStrings.format('albumCount', ['${albums.length}'])),
              const SizedBox(height: 12),
              Text(
                AppStrings.get('booksByAuthor'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...byAuthor.entries.map((e) => Text('${e.key}: ${e.value}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('close')),
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

  @override
  Widget build(BuildContext context) {
    final shown = books
        .where((b) =>
            b.title.toLowerCase().contains(keyword.toLowerCase()) ||
            b.author.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('library')),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: AppStrings.get('statistics'),
            onPressed: showStats,
          ),
          const LanguageSwitch(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: importing ? null : pickBook,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.get('addEpub')),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (importing) const LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppStrings.get('searchHint'),
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
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
                              Text(AppStrings.get('noBooks')),
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
