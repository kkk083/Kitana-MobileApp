import 'package:flutter/material.dart';

/// Couleurs du thème Kintana
class KintanaColors {
  // Couleurs principales
  static const Color primary = Color(0xFFB8956A); // Doré
  static const Color secondary = Color(0xFFCCAA7F); // Doré clair
  static const Color background = Color(0xFFEFCBB3); // Beige/Pêche

  // Couleurs des champs de saisie
  static const Color inputEmailBackground = Color(0xFFE8EEF7); // Bleu clair
  static const Color inputBorder = Color(0xFFE5E5E5); // Gris clair
  static const Color inputText = Color(0xFF5C6B7E); // Gris foncé

  // Couleurs d'erreur
  static const Color errorBackground = Color(0xFFFFF5F5); // Rouge très clair
  static const Color errorBorder = Color(0xFFFFE5E5); // Rouge clair
  static const Color errorText = Color(0xFFE74C3C); // Rouge

  // Couleurs neutres
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color placeholderGray = Color(0xFFCCCCCC);
}

/// Styles de texte du thème Kintana
class KintanaTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: KintanaColors.primary,
    letterSpacing: 2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.italic,
    color: KintanaColors.primary,
  );

  static const TextStyle tabActive = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: KintanaColors.white,
  );

  static const TextStyle tabInactive = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: KintanaColors.primary,
  );

  static const TextStyle inputHint = TextStyle(
    color: KintanaColors.inputText,
    fontSize: 15,
  );

  static const TextStyle inputPassword = TextStyle(
    color: KintanaColors.placeholderGray,
    fontSize: 15,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle link = TextStyle(
    color: KintanaColors.primary,
    fontSize: 14,
  );

  static const TextStyle error = TextStyle(
    color: KintanaColors.errorText,
    fontSize: 14,
  );
}

/// Dimensions et espacements
class KintanaDimensions {
  // Rayons de bordure
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Espacements
  static const double spacingXSmall = 8.0;
  static const double spacingSmall = 16.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;
  static const double spacingXLarge = 40.0;

  // Tailles
  static const double logoSize = 70.0;
  static const double logoIconSize = 40.0;
  static const double inputPadding = 16.0;
  static const double buttonPadding = 16.0;

  // Largeur maximale du conteneur
  static const double maxContainerWidth = 450.0;
}
