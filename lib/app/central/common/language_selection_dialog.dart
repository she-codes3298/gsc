import 'package:flutter/material.dart';
import 'package:gsc/services/translation_service.dart';


class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: TranslationService.availableLanguages.length,
          itemBuilder: (context, index) {
            final language = TranslationService.availableLanguages[index];
            return ListTile(
              title: Row(
                children: [
                  Text(language.name), // Native script
                  const SizedBox(width: 8),
                  Text(
                    '(${language.englishName})', // English name
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                // Handle language selection
                TranslationService.setLanguage(language.code);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}