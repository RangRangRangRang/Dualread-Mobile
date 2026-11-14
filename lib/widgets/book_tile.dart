import 'package:flutter/material.dart';
import '../models/book_item.dart';
import '../utils/app_strings.dart';
import '../utils/date_helper.dart';

class BookTile extends StatelessWidget {
  final BookItem book;
  final VoidCallback onTap;
  final void Function(String) onMenu;

  const BookTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final date = book.targetDate;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/book.png',
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(book.author),
                    Text(
                      book.describe(),
                      style: const TextStyle(color: Colors.indigo),
                    ),
                    if (date != null)
                      Text(AppStrings.format('targetDate', [formatDate(date)])),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: onMenu,
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'album',
                    child: Text(AppStrings.get('addToAlbum')),
                  ),
                  PopupMenuItem(
                    value: 'date',
                    child: Text(AppStrings.get('pickDate')),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(AppStrings.get('delete')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
