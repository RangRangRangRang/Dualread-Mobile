import 'package:flutter/material.dart';
import '../models/album.dart';
import '../utils/date_helper.dart';

class AlbumTile extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;
  final void Function(String) onMenu;

  const AlbumTile({
    super.key,
    required this.album,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.folder, size: 36, color: Colors.indigo),
        title: Text(
          album.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${album.describe()} • tạo ${formatDate(album.createdAt)}',
        ),
        onTap: onTap,
        trailing: PopupMenuButton<String>(
          onSelected: onMenu,
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
            PopupMenuItem(value: 'delete', child: Text('Xóa')),
          ],
        ),
      ),
    );
  }
}
