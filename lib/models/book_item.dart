import 'item.dart';

class BookItem extends Item {
  String author;
  String path;
  int lastChapter;
  DateTime? targetDate;

  BookItem({
    required String id,
    required String title,
    required this.author,
    required this.path,
    this.lastChapter = 0,
    this.targetDate,
  }) : super(id, title);

  String get title => name;

  @override
  String describe() {
    return lastChapter == 0 ? 'Chưa đọc' : 'Đang đọc (chương ${lastChapter + 1})';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': name,
      'author': author,
      'path': path,
      'lastChapter': lastChapter,
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  factory BookItem.fromMap(Map<String, dynamic> map) {
    final date = map['targetDate'];
    return BookItem(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      path: map['path'],
      lastChapter: map['lastChapter'] ?? 0,
      targetDate: date == null ? null : DateTime.parse(date),
    );
  }
}