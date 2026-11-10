import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book_item.dart';

class EpubService {
  static Future<BookItem> importBook(String sourcePath) async {
    final bytes = await File(sourcePath).readAsBytes();
    final epub = await EpubReader.readBook(bytes);

    final dir = await getApplicationDocumentsDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final savePath = '${dir.path}/$id.epub';
    await File(savePath).writeAsBytes(bytes);

    String title = epub.Title ?? '';
    String author = epub.Author ?? '';
    if (title.trim().isEmpty) title = 'Không rõ tiêu đề';
    if (author.trim().isEmpty) author = 'Không rõ tác giả';

    return BookItem(
      id: id,
      title: title.trim(),
      author: author.trim(),
      path: savePath,
    );
  }
}