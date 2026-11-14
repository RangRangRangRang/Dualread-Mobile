import 'package:flutter/material.dart';
import '../widgets/group_title.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final members = [
      ['23010721', 'Lê Trường Giang'],
      ['23010446', 'Nguyễn Quang Huy'],
      ['23010412', 'Nguyễn Minh Tùng'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin nhóm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const GroupTitle(
            title: 'Nhóm 2',
            subtitle: 'DualRead Mobile - Lập trình thiết bị di động',
          ),
          const SizedBox(height: 16),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('MSSV')),
                  DataColumn(label: Text('Họ và tên')),
                ],
                rows: members
                    .map((m) => DataRow(
                          cells: [DataCell(Text(m[0])), DataCell(Text(m[1]))],
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
