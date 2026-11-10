import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path_provider/path_provider.dart';
import '../models/book_item.dart';

class ChapterData {
  String title;
  List<String> paragraphs;

  ChapterData(this.title, this.paragraphs);
}

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

  static Future<List<ChapterData>> loadChapters(String path) async {
    final bytes = await File(path).readAsBytes();
    final epub = await EpubReader.readBook(bytes);
    final result = <ChapterData>[];
    _addChapters(epub.Chapters ?? [], result);
    return result;
  }

  static void _addChapters(List<EpubChapter> list, List<ChapterData> result) {
    for (final c in list) {
      final paragraphs = _htmlToParagraphs(c.HtmlContent ?? '');
      if (paragraphs.isNotEmpty) {
        String title = c.Title ?? '';
        if (title.trim().isEmpty) title = 'Chương ${result.length + 1}';
        result.add(ChapterData(title.trim(), paragraphs));
      }
      _addChapters(c.SubChapters ?? [], result);
    }
  }

  static List<String> _htmlToParagraphs(String content) {
    final doc = html_parser.parse(content);
    final elements = doc.querySelectorAll('p, h1, h2, h3, h4, h5, h6');
    final result = <String>[];

    for (final e in elements) {
      final text = e.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isNotEmpty) result.add(text);
    }

    if (result.isEmpty) {
      final body = doc.body?.text ?? '';
      for (final line in body.split('\n')) {
        final text = line.trim();
        if (text.isNotEmpty) result.add(text);
      }
    }
    return result;
  }
}