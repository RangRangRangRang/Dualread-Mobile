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
  double fontSize = 18;
  bool darkMode = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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

  void goToChapter(int index) {
    if (index < 0 || index >= chapters.length) return;
    setState(() => current = index);
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = darkMode ? const Color(0xFF121212) : const Color(0xFFFFFBF2);
    final textColor = darkMode ? Colors.white70 : Colors.black87;

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
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(chapter.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              if (fontSize > 12) setState(() => fontSize -= 2);
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              if (fontSize < 32) setState(() => fontSize += 2);
            },
          ),
          IconButton(
            icon: Icon(darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => darkMode = !darkMode),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Mục lục',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: chapters.length,
                  itemBuilder: (ctx, i) {
                    return ListTile(
                      title: Text(chapters[i].title,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      selected: i == current,
                      onTap: () {
                        Navigator.pop(context);
                        goToChapter(i);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chapter.paragraphs.length,
        itemBuilder: (ctx, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SelectableText(
              chapter.paragraphs[i],
              style: TextStyle(fontSize: fontSize, height: 1.6, color: textColor),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: current > 0 ? () => goToChapter(current - 1) : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Trước'),
            ),
            Text('${current + 1} / ${chapters.length}'),
            TextButton.icon(
              onPressed: current < chapters.length - 1
                  ? () => goToChapter(current + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Sau'),
            ),
          ],
        ),
      ),
    );
  }
}