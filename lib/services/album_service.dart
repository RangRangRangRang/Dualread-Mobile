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
}
