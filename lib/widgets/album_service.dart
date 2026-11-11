import '../models/album.dart';
import 'json_storage.dart';

class AlbumService {
  static const String albumsKey = 'albums';

  static Future<List<Album>> loadAlbums() {
    return loadList<Album>(albumsKey, (m) => Album.fromMap(m));
  }

  static Future<void> saveAlbums(List<Album> albums) {
    return saveList<Album>(albumsKey, albums);
  }

  static Future<void> createAlbum(String name) async {
    final albums = await loadAlbums();
    albums.add(
      Album(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name),
    );
    await saveAlbums(albums);
  }

  static Future<void> renameAlbum(String albumId, String name) async {
    final albums = await loadAlbums();
    for (final a in albums) {
      if (a.id == albumId) {
        a.name = name;
      }
    }
    await saveAlbums(albums);
  }

  static Future<void> deleteAlbum(String albumId) async {
    final albums = await loadAlbums();
    albums.removeWhere((a) => a.id == albumId);
    await saveAlbums(albums);
  }

  static Future<void> toggleBookInAlbum(
    String albumId,
    String bookId,
    bool add,
  ) async {
    final albums = await loadAlbums();
    for (final a in albums) {
      if (a.id == albumId) {
        if (add && !a.bookIds.contains(bookId)) {
          a.bookIds.add(bookId);
        }
        if (!add) {
          a.bookIds.remove(bookId);
        }
      }
    }
    await saveAlbums(albums);
  }

  static Future<void> removeBookFromAllAlbums(String bookId) async {
    final albums = await loadAlbums();
    for (final a in albums) {
      a.bookIds.remove(bookId);
    }
    await saveAlbums(albums);
  }
}
