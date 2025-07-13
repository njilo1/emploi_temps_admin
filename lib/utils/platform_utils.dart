import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isDesktop => isMacOS || isWindows || isLinux;
  static bool get isMobile => isAndroid || isIOS;

  /// Retourne le nom de la plateforme pour l'affichage
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Vérifie si une fonctionnalité est supportée sur la plateforme actuelle
  static bool isFeatureSupported(String feature) {
    switch (feature) {
      case 'file_picker':
        // file_picker est supporté sur toutes les plateformes
        return true;
      case 'path_provider':
        // path_provider n'est pas supporté sur Web
        return !isWeb;
      case 'permission_handler':
        // permission_handler n'est supporté que sur mobile
        return isMobile;
      default:
        return true;
    }
  }

  /// Retourne un message d'erreur adapté à la plateforme
  static String getPlatformErrorMessage(String feature) {
    if (isWeb) {
      return 'Cette fonctionnalité n\'est pas disponible sur le Web';
    } else if (isDesktop) {
      return 'Cette fonctionnalité n\'est pas disponible sur Desktop';
    } else {
      return 'Cette fonctionnalité n\'est pas disponible sur cette plateforme';
    }
  }

  /// Adapte la taille des widgets selon la plateforme
  static double getAdaptiveSize(double mobileSize, double desktopSize) {
    return isMobile ? mobileSize : desktopSize;
  }

  /// Adapte le padding selon la plateforme
  static EdgeInsets getAdaptivePadding() {
    if (isWeb) {
      return const EdgeInsets.all(16.0);
    } else if (isDesktop) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Adapte la taille de police selon la plateforme
  static double getAdaptiveFontSize(double mobileSize, double desktopSize) {
    return isMobile ? mobileSize : desktopSize;
  }
} 