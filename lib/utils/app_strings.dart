import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStrings {
  static final ValueNotifier<String> language = ValueNotifier<String>('vi');

  static const Map<String, Map<String, String>> data = {
    'vi': {
    'cancel': 'Hủy',
    'delete': 'Xóa',
    'save': 'Lưu',
    'close': 'Đóng',
    'done': 'Xong',
    'ok': 'Đồng ý',
    'rename': 'Đổi tên',
    'aboutTitle': 'Thông tin nhóm',
    'groupName': 'Nhóm 2',
    'appSubtitle': 'DualRead Mobile - Lập trình thiết bị di động',
    'colStudentId': 'MSSV',
    'colName': 'Họ và tên',
    'library': 'Thư viện',
    'noBooks': 'Chưa có sách nào',
    'addEpub': 'Thêm EPUB',
    'searchHint': 'Tìm theo tên sách hoặc tác giả',
    'bookAdded': 'Đã thêm sách: {0}',
    'epubError': 'Không đọc được file EPUB này',
    'deleteBook': 'Xóa sách',
    'deleteBookAsk': 'Bạn có chắc muốn xóa "{0}"?',
    'addToAlbum': 'Thêm vào album',
    'noAlbumYet': 'Chưa có album nào. Hãy tạo album trước.',
    'statistics': 'Thống kê',
    'totalBooks': 'Tổng số sách: {0}',
    'readingCount': 'Đang đọc: {0}',
    'unreadCount': 'Chưa đọc: {0}',
    'albumCount': 'Số album: {0}',
    'booksByAuthor': 'Số sách theo tác giả',
    'pickDate': 'Chọn ngày đọc xong',
    'targetDate': 'Dự định đọc xong: {0}',
    'statusUnread': 'Chưa đọc',
    'statusReading': 'Đang đọc (chương {0})',
    'cannotReadBook': 'Không đọc được nội dung sách này',
    'contents': 'Mục lục',
    'prev': 'Trước',
    'next': 'Sau',
    'chapterN': 'Chương {0}',
    'unknownTitle': 'Không rõ tiêu đề',
    'unknownAuthor': 'Không rõ tác giả',
    'albumTitle': 'Album',
    'noAlbums': 'Chưa có album nào',
    'albumNameHint': 'Tên album',
    'createAlbumTitle': 'Tạo album mới',
    'renameAlbumTitle': 'Đổi tên album',
    'deleteAlbumTitle': 'Xóa album',
    'deleteAlbumAsk': 'Xóa album "{0}"? Sách vẫn được giữ lại.',
    'albumCreated': 'Đã tạo album "{0}"',
    'albumRenamed': 'Đã đổi tên album',
    'albumDeleted': 'Đã xóa album',
    'albumBooks': '{0} sách',
    'createdOn': 'tạo {0}',
    'removeFromAlbum': 'Gỡ khỏi album',
    'albumEmpty': 'Album trống',
    'backToLibrary': 'Về thư viện',
    'addBooks': 'Thêm sách',
    },
    'en': {
    'cancel': 'Cancel',
    'delete': 'Delete',
    'save': 'Save',
    'close': 'Close',
    'done': 'Done',
    'ok': 'OK',
    'rename': 'Rename',
    'aboutTitle': 'Group information',
    'groupName': 'Group 2',
    'appSubtitle': 'DualRead Mobile - Mobile Device Programming',
    'colStudentId': 'Student ID',
    'colName': 'Full name',
    'library': 'Library',
    'noBooks': 'No books yet',
    'addEpub': 'Add EPUB',
    'searchHint': 'Search by title or author',
    'bookAdded': 'Book added: {0}',
    'epubError': 'Cannot read this EPUB file',
    'deleteBook': 'Delete book',
    'deleteBookAsk': 'Are you sure you want to delete "{0}"?',
    'addToAlbum': 'Add to album',
    'noAlbumYet': 'No albums yet. Create an album first.',
    'statistics': 'Statistics',
    'totalBooks': 'Total books: {0}',
    'readingCount': 'Reading: {0}',
    'unreadCount': 'Unread: {0}',
    'albumCount': 'Albums: {0}',
    'booksByAuthor': 'Books by author',
    'pickDate': 'Pick finish date',
    'targetDate': 'Planned finish: {0}',
    'statusUnread': 'Not started',
    'statusReading': 'Reading (chapter {0})',
    'cannotReadBook': 'Cannot read the content of this book',
    'contents': 'Contents',
    'prev': 'Previous',
    'next': 'Next',
    'chapterN': 'Chapter {0}',
    'unknownTitle': 'Unknown title',
    'unknownAuthor': 'Unknown author',
    'albumTitle': 'Albums',
    'noAlbums': 'No albums yet',
    'albumNameHint': 'Album name',
    'createAlbumTitle': 'Create new album',
    'renameAlbumTitle': 'Rename album',
    'deleteAlbumTitle': 'Delete album',
    'deleteAlbumAsk': 'Delete album "{0}"? Books are kept.',
    'albumCreated': 'Album "{0}" created',
    'albumRenamed': 'Album renamed',
    'albumDeleted': 'Album deleted',
    'albumBooks': '{0} books',
    'createdOn': 'created {0}',
    'removeFromAlbum': 'Remove from album',
    'albumEmpty': 'This album is empty',
    'backToLibrary': 'Back to library',
    'addBooks': 'Add books',
    },
  };

  static String get(String key) {
    final table = data[language.value] ?? {};
    return table[key] ?? key;
  }

  static String format(String key, List<String> args) {
    String text = get(key);
    for (int i = 0; i < args.length; i++) {
      text = text.replaceAll('{$i}', args[i]);
    }
    return text;
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    language.value = prefs.getString('language') ?? 'vi';
  }

  static Future<void> setLanguage(String code) async {
    language.value = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
  }
}
