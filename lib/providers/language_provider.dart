import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    // Load saved language preference on initialization
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    _currentLanguage = await TranslationService.getCurrentLanguage();
    notifyListeners();
  }

  // Change language and notify listeners
  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await TranslationService.setLanguage(languageCode);
    notifyListeners();
  }

  // Translate a given text to current language
  Future<String> translateText(String text) async {
    return await TranslationService.translateText(text, _currentLanguage);
  }
}