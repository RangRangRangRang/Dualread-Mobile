import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/book_item.dart';
import '../services/epub_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import '../utils/sound_helper.dart';

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
  bool showBars = true;
  Timer? hideTimer;
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AppStrings.language.addListener(refresh);
    loadChapters();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    AppStrings.language.removeListener(refresh);
    hideTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadChapters() async {
    try {
      final data = await EpubService.loadChapters(widget.book.path);
      setState(() {
        chapters = data;
        current = widget.book.lastChapter < data.length
            ? widget.book.lastChapter
            : 0;
        loading = false;
        error = data.isEmpty;
      });
      restartTimer();
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  void restartTimer() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showBars = false);
    });
  }

  void toggleBars() {
    if (showBars) {
      hideTimer?.cancel();
      setState(() => showBars = false);
    } else {
      setState(() => showBars = true);
      restartTimer();
    }
  }

  void goToChapter(int index) {
    if (index < 0 || index >= chapters.length) return;
    setState(() => current = index);
    widget.book.lastChapter = index;
    StorageService.saveLastChapter(widget.book.id, index);
    SoundHelper.playPage();
    restartTimer();
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
        body: Center(child: Text(AppStrings.get('cannotReadBook'))),
      );
    }

    final chapter = chapters[current];

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgColor,
      appBar: showBars
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: AppStrings.get('backToLibrary'),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.list),
                  tooltip: AppStrings.get('contents'),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                IconButton(
                  icon: const Icon(Icons.text_decrease),
                  onPressed: () {
                    if (fontSize > 12) setState(() => fontSize -= 2);
                    restartTimer();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase),
                  onPressed: () {
                    if (fontSize < 32) setState(() => fontSize += 2);
                    restartTimer();
                  },
                ),
                IconButton(
                  icon: Icon(darkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    setState(() => darkMode = !darkMode);
                    restartTimer();
                  },
                ),
              ],
            )
          : null,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.get('contents'),
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
      body: NotificationListener<UserScrollNotification>(
        onNotification: (n) {
          if (n.direction == ScrollDirection.reverse && showBars) {
            hideTimer?.cancel();
            setState(() => showBars = false);
          }
          if (n.direction == ScrollDirection.forward && !showBars) {
            setState(() => showBars = true);
            restartTimer();
          }
          return false;
        },
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: chapter.paragraphs.length,
          itemBuilder: (ctx, i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SelectableText(
                chapter.paragraphs[i],
                onTap: toggleBars,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: showBars
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: current > 0 ? () => goToChapter(current - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                    label: Text(AppStrings.get('prev')),
                  ),
                  Text('${current + 1} / ${chapters.length}'),
                  TextButton.icon(
                    onPressed: current < chapters.length - 1
                        ? () => goToChapter(current + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: Text(AppStrings.get('next')),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
