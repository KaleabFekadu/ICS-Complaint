import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final selectedLanguage = 'English'.obs; // Default language
  final GetStorage _storage = GetStorage(); // Persistent storage

  // List of Ethiopian languages
  final List<String> languages = [
    'English',
    'Amharic',
    'Afaan Oromo',
    'Tigrega',
    'Somali',

  ];

  @override
  void onInit() {
    super.onInit();
    // Load saved language from storage
    final savedLanguage = _storage.read<String>('selectedLanguage');
    if (savedLanguage != null && languages.contains(savedLanguage)) {
      selectedLanguage.value = savedLanguage;
    }
  }

  // Set the selected language and save it
  void setLanguage(String language) {
    selectedLanguage.value = language;
    _storage.write('selectedLanguage', language);
    // Optionally update app locale here if using GetX localization
    // Get.updateLocale(Locale(languageCode));
  }

  // Mark language selection as complete
  void completeLanguageSelection() {
    _storage.write('language_selection_completed', true);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}