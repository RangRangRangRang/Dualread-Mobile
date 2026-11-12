import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/book_item.dart';
import '../services/album_service.dart';
import '../services/storage_service.dart';
import '../widgets/album_tile.dart';
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
    loadData();
  }

  Future<void> loadData() async {
    final data = await AlbumService.loadAlbums();
    setState(() => albums = data);
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
          decoration: const InputDecoration(hintText: 'Tên album'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> createAlbum() async {
    final name = await askName('Tạo album mới', '');
    if (name == null || name.isEmpty) return;
    await AlbumService.createAlbum(name);
    await loadData();
  }

  Future<void> renameAlbum(Album album) async {
    final name = await askName('Đổi tên album', album.name);
    if (name == null || name.isEmpty) return;
    await AlbumService.renameAlbum(album.id, name);
    await loadData();
  }

  Future<void> deleteAlbum(Album album) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa album'),
        content: Text('Xóa album "${album.name}"? Sách vẫn được giữ lại.'),
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
      await AlbumService.deleteAlbum(album.id);
      await loadData();
    }
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
      appBar: AppBar(title: const Text('Album')),
      floatingActionButton: FloatingActionButton(
        onPressed: createAlbum,
        child: const Icon(Icons.add),
      ),
      body: albums.isEmpty
          ? const Center(child: Text('Chưa có album nào'))
          : ListView.builder(
              itemCount: albums.length,
              itemBuilder: (ctx, i) {
                final album = albums[i];
                return AlbumTile(
                  album: album,
                  onTap: () => openAlbum(album),
                  onMenu: (value) {
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
    loadData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(albumName)),
      body: books.isEmpty
          ? const Center(
              child: Text('Album trống. Thêm sách từ màn hình Thư viện.'),
            )
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (ctx, i) {
                final book = books[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Image.asset('assets/images/book.png', width: 36),
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen(book: book),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Gỡ khỏi album',
                      onPressed: () => removeBook(book),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
