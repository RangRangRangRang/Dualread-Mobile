import 'package:flutter/material.dart';
import '../services/album_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';

Future<void> showAddBooksDialog(BuildContext context, String albumId) async {
  final books = await StorageService.loadBooks();
  final albums = await AlbumService.loadAlbums();
  final album = albums.firstWhere((a) => a.id == albumId);
  if (!context.mounted) return;

  if (books.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('noBooks'))),
    );
    return;
  }

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(AppStrings.get('addBooks')),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: books.map((b) {
                  return CheckboxListTile(
                    title: Text(b.title),
                    subtitle: Text(b.author),
                    value: album.bookIds.contains(b.id),
                    onChanged: (value) async {
                      await AlbumService.toggleBookInAlbum(
                          albumId, b.id, value == true);
                      setDialogState(() {
                        if (value == true) {
                          album.bookIds.add(b.id);
                        } else {
                          album.bookIds.remove(b.id);
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
