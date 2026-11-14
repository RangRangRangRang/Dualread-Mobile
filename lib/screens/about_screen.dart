import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../widgets/group_title.dart';
import '../widgets/language_switch.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final List<List<String>> members = [
    ['23010721', 'Lê Trường Giang'],
    ['23010446', 'Nguyễn Quang Huy'],
    ['23010412', 'Nguyễn Minh Tùng'],
  ];

  @override
  void initState() {
    super.initState();
    AppStrings.language.addListener(refresh);
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    AppStrings.language.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('aboutTitle')),
        actions: const [LanguageSwitch()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GroupTitle(
            title: AppStrings.get('groupName'),
            subtitle: AppStrings.get('appSubtitle'),
          ),
          const SizedBox(height: 16),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(AppStrings.get('colStudentId'))),
                  DataColumn(label: Text(AppStrings.get('colName'))),
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
