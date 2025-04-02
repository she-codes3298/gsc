import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';
import '../../../services/translation_service.dart';
import 'package:gsc/app/central/common/translatable_text.dart';


class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return AlertDialog(
      title: const TranslatableText('Select Language'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: TranslationService.availableLanguages.length,
          itemBuilder: (context, index) {
            final language = TranslationService.availableLanguages[index];
            final isSelected = language.code == languageProvider.currentLanguage;
            
            return ListTile(
              title: TranslatableText(language.name),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                languageProvider.changeLanguage(language.code);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}
