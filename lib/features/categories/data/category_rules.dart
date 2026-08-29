import '../models/category_model.dart';

class CategoryRules {
  /// Calcola l'età compiuta alla data della gara.
  static int calculateAgeAtDate({
    required DateTime birthDate,
    required DateTime referenceDate,
  }) {
    int age = referenceDate.year - birthDate.year;

    final birthdayReached =
        referenceDate.month > birthDate.month ||
        (referenceDate.month == birthDate.month &&
            referenceDate.day >= birthDate.day);

    if (!birthdayReached) {
      age--;
    }

    return age;
  }

  /// Verifica se una categoria è compatibile con atleta.
  static bool matches({
    required CategoryModel category,
    required int age,
    String? sesso,
  }) {
    // Controllo sesso
    if (category.sesso != null &&
        category.sesso != sesso) {
      return false;
    }

    // Età minima
    if (category.etaMin != null &&
        age < category.etaMin!) {
      return false;
    }

    // Età massima
    if (category.etaMax != null &&
        age > category.etaMax!) {
      return false;
    }

    return true;
  }

  /// Restituisce la prima categoria compatibile.
  static CategoryModel? findMatchingCategory({
    required List<CategoryModel> categories,
    required DateTime birthDate,
    required DateTime competitionDate,
    String? sesso,
  }) {
    final age = calculateAgeAtDate(
      birthDate: birthDate,
      referenceDate: competitionDate,
    );

    for (final category in categories) {
      if (matches(
        category: category,
        age: age,
        sesso: sesso,
      )) {
        return category;
      }
    }

    return null;
  }
}