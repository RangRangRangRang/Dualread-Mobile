import 'item.dart';

class Album extends Item {
  List<String> bookIds;
  DateTime createdAt;

  Album({
    required String id,
    required String name,
    List<String>? bookIds,
    DateTime? createdAt,
  })  : bookIds = bookIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        super(id, name);

  @override
  String describe() {
    return '${bookIds.length} sách';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bookIds': bookIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    final date = map['createdAt'];
    return Album(
      id: map['id'],
      name: map['name'],
      bookIds: List<String>.from(map['bookIds'] ?? []),
      createdAt: date == null ? null : DateTime.parse(date),
    );
  }
}