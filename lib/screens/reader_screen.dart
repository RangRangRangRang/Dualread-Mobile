import 'package:flutter/material.dart';
import '../models/book_item.dart';
import '../services/epub_service.dart';

class ReaderScreen extends StatefulWidget {
  final BookItem book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  List<ChapterData> chapters = [];
  bool loading = true;
  bool error = false;
  int current = 0;

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  Future<void> loadChapters() async {
    try {
      final data = await EpubService.loadChapters(widget.book.path);
      setState(() {
        chapters = data;
        current = 0;
        loading = false;
        error = data.isEmpty;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.book.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.book.title)),
        body: const Center(child: Text('Không đọc được nội dung sách này')),
      );
    }

    final chapter = chapters[current];

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chapter.paragraphs.length,
        itemBuilder: (ctx, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SelectableText(
              chapter.paragraphs[i],
              style: const TextStyle(fontSize: 18, height: 1.6),
            ),
          );
        },
      ),
    );
  }
}