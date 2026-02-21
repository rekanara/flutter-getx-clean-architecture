import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/config.dart';
import '../platform/storage/get_storage_impl.dart';

class RkTheme {
  RkTheme();

  static ThemeMode themeLight = ThemeMode.light;
  static ThemeMode themeDark = ThemeMode.dark;
  static ThemeMode themeSystem = ThemeMode.system;

  /// update app theme and save theme type to shared pref
  /// (so when the app is killed and up again theme will remain the same)
  static Future<void> changeTheme({required bool isLightTheme}) async {
    GetStorageImpl storage = GetStorageImpl();

    // *) store the new theme mode on get storage
    await storage.write(StorageValue.themeIsLight, !isLightTheme);

    // *) let GetX change theme
    Get.changeThemeMode(!isLightTheme ? ThemeMode.light : ThemeMode.dark);
  }

  // The defined light theme.
  static ThemeData light = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    // scheme: FlexScheme.shadRose,
    colors: const FlexSchemeColor(
      primary: Color(0xFF00296B),
      primaryContainer: Color(0xFFA0C2ED),
      secondary: Color(0xFFD26900),
      secondaryContainer: Color(0xFFFFD270),
      tertiary: Color(0xFF5C5C95),
      tertiaryContainer: Color(0xFFC8DBF8),
      appBarColor: Color(0xFFC8DCF8),
      swapOnMaterial3: true,
    ),
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 22.0,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      snackBarRadius: 20,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    fontFamily: FontFamilyType.primary,
    typography: Typography.material2021(
      englishLike: Typography.englishLike2021,
      dense: Typography.dense2021,
      tall: Typography.tall2021,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The defined dark theme.
  static ThemeData dark = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    // scheme: FlexScheme.shadRose,
    colors: const FlexSchemeColor(
      primary: Color(0xFFB1CFF5),
      primaryContainer: Color(0xFF3873BA),
      primaryLightRef: Color(0xFF00296B), // The color of light mode primary
      secondary: Color(0xFFFFD270),
      secondaryContainer: Color(0xFFD26900),
      secondaryLightRef: Color(0xFFD26900), // The color of light mode secondary
      tertiary: Color(0xFFC9CBFC),
      tertiaryContainer: Color(0xFF535393),
      tertiaryLightRef: Color(0xFF5C5C95), // The color of light mode tertiary
      appBarColor: Color(0xFF00102B),
      swapOnMaterial3: true,
    ),
    // Convenience direct styling properties.
    appBarStyle: FlexAppBarStyle.scaffoldBackground,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 22.0,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      snackBarRadius: 20,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    fontFamily: FontFamilyType.primary,
    typography: Typography.material2021(
      englishLike: Typography.englishLike2021,
      dense: Typography.dense2021,
      tall: Typography.tall2021,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
