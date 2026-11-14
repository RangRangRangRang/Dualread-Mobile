import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/book_item.dart';
import '../services/album_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import '../widgets/add_books_dialog.dart';
import '../widgets/album_tile.dart';
import '../widgets/language_switch.dart';
import 'reader_screen.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Album> albums = [];

  @override
  void initState() {
    super.initState();
    AppStrings.language.addListener(refresh);
    loadData();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    AppStrings.language.removeListener(refresh);
    super.dispose();
  }

  Future<void> loadData() async {
    final data = await AlbumService.loadAlbums();
    setState(() => albums = data);
  }

  void showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<String?> askName(String title, String oldName) async {
    final controller = TextEditingController(text: oldName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: AppStrings.get('albumNameHint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(AppStrings.get('save')),
          ),
        ],
      ),
    );
  }

  Future<void> createAlbum() async {
    final name = await askName(AppStrings.get('createAlbumTitle'), '');
    if (name == null || name.isEmpty) return;
    await AlbumService.createAlbum(name);
    await loadData();
    showMessage(AppStrings.format('albumCreated', [name]));
  }

  Future<void> renameAlbum(Album album) async {
    final name = await askName(AppStrings.get('renameAlbumTitle'), album.name);
    if (name == null || name.isEmpty) return;
    await AlbumService.renameAlbum(album.id, name);
    await loadData();
    showMessage(AppStrings.get('albumRenamed'));
  }

  Future<void> deleteAlbum(Album album) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('deleteAlbumTitle')),
        content: Text(AppStrings.format('deleteAlbumAsk', [album.name])),
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
      await AlbumService.deleteAlbum(album.id);
      await loadData();
      showMessage(AppStrings.get('albumDeleted'));
    }
  }

  Future<void> addBooks(Album album) async {
    await showAddBooksDialog(context, album.id);
    await loadData();
  }

  Future<void> openAlbum(Album album) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AlbumDetailScreen(albumId: album.id)),
    );
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('albumTitle')),
        actions: const [LanguageSwitch()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createAlbum,
        child: const Icon(Icons.add),
      ),
      body: albums.isEmpty
          ? Center(child: Text(AppStrings.get('noAlbums')))
          : ListView.builder(
              itemCount: albums.length,
              itemBuilder: (ctx, i) {
                final album = albums[i];
                return AlbumTile(
                  album: album,
                  onTap: () => openAlbum(album),
                  onMenu: (value) {
                    if (value == 'add') addBooks(album);
                    if (value == 'rename') renameAlbum(album);
                    if (value == 'delete') deleteAlbum(album);
                  },
                );
              },
            ),
    );
  }
}

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  String albumName = '';
  List<BookItem> books = [];

  @override
  void initState() {
    super.initState();
    AppStrings.language.addListener(refresh);
    loadData();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    AppStrings.language.removeListener(refresh);
    super.dispose();
  }

  Future<void> loadData() async {
    final albums = await AlbumService.loadAlbums();
    final allBooks = await StorageService.loadBooks();
    final album = albums.firstWhere((a) => a.id == widget.albumId);
    setState(() {
      albumName = album.name;
      books = allBooks.where((b) => album.bookIds.contains(b.id)).toList();
    });
  }

  Future<void> removeBook(BookItem book) async {
    await AlbumService.toggleBookInAlbum(widget.albumId, book.id, false);
    await loadData();
  }

  Future<void> addBooks() async {
    await showAddBooksDialog(context, widget.albumId);
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(albumName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addBooks,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.get('addBooks')),
      ),
      body: books.isEmpty
          ? Center(child: Text(AppStrings.get('albumEmpty')))
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (ctx, i) {
                final book = books[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Image.asset('assets/images/book.png', width: 36),
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ReaderScreen(book: book)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: AppStrings.get('removeFromAlbum'),
                      onPressed: () => removeBook(book),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
