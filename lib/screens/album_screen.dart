import 'package:flutter/material.dart';
import '../models/album.dart';
import '../services/album_service.dart';
import '../widgets/album_tile.dart';

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
                  onTap: () {},
                  onMenu: (value) {},
                );
              },
            ),
    );
  }
}
