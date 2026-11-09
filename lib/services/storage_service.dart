import '../models/book_item.dart';
import 'json_storage.dart';

class StorageService {
  static const String booksKey = 'books';

  static Future<List<BookItem>> loadBooks() {
    return loadList<BookItem>(booksKey, (m) => BookItem.fromMap(m));
  }

  static Future<void> saveBooks(List<BookItem> books) {
    return saveList<BookItem>(booksKey, books);
  }

  static Future<void> addBook(BookItem book) async {
    final books = await loadBooks();
    books.add(book);
    await saveBooks(books);
  }

  static Future<void> saveLastChapter(String bookId, int chapter) async {
    final books = await loadBooks();
    for (final b in books) {
      if (b.id == bookId) {
        b.lastChapter = chapter;
      }
    }
    await saveBooks(books);
  }
}