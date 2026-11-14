import 'package:flutter/material.dart';
import '../models/album.dart';
import '../utils/app_strings.dart';
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
          '${album.describe()} • ${AppStrings.format('createdOn', [formatDate(album.createdAt)])}',
        ),
        onTap: onTap,
        trailing: PopupMenuButton<String>(
          onSelected: onMenu,
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'add',
              child: Text(AppStrings.get('addBooks')),
            ),
            PopupMenuItem(
              value: 'rename',
              child: Text(AppStrings.get('rename')),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(AppStrings.get('delete')),
            ),
          ],
        ),
      ),
    );
  }
}
