import 'package:flutter/material.dart';
import '../utils/app_strings.dart';

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  Widget item(String code, String label, String current) {
    final selected = current == code;
    return GestureDetector(
      onTap: () => AppStrings.setLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.language,
      builder: (context, lang, child) {
        return Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC5CAE9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              item('en', 'EN', lang),
              item('vi', 'VI', lang),
            ],
          ),
        );
      },
    );
  }
}