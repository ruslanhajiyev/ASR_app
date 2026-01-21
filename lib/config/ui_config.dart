import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class UIConfig {
  final String style;
  final String density;
  final String contrast;
  final String shape;

  UIConfig({
    required this.style,
    required this.density,
    required this.contrast,
    required this.shape,
  });

  factory UIConfig.fromJson(Map<String, dynamic> json) {
    return UIConfig(
      style: json['style'] as String? ?? 'modern',
      density: json['density'] as String? ?? 'normal',
      contrast: json['contrast'] as String? ?? 'normal',
      shape: json['shape'] as String? ?? 'rounded',
    );
  }

  static Future<UIConfig> load() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/ui_config.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UIConfig.fromJson(json);
    } catch (e) {
      // Return default config if loading fails
      return UIConfig(
        style: 'modern',
        density: 'normal',
        contrast: 'normal',
        shape: 'rounded',
      );
    }
  }
}

class ThemeConfig {
  static ThemeData getTheme(UIConfig config) {
    final colorScheme = _getColorScheme(config);
    final textTheme = _getTextTheme(config);
    final shape = _getShape(config);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: config.density == 'compact' ? 2 : 4,
        shape: shape,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: shape,
          padding: _getPadding(config),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          padding: _getPadding(config),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: _getBorderRadius(config),
        ),
        contentPadding: _getPadding(config),
      ),
    );
  }

  static ColorScheme _getColorScheme(UIConfig config) {
    final brightness = config.contrast == 'high'
        ? Brightness.dark
        : Brightness.light;

    switch (config.style) {
      case 'minimal':
        return ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: brightness,
        );
      case 'classic':
        return ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        );
      case 'modern':
      default:
        return ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: brightness,
        );
    }
  }

  static TextTheme _getTextTheme(UIConfig config) {
    final baseSize = config.density == 'compact'
        ? 12.0
        : config.density == 'spacious'
            ? 16.0
            : 14.0;

    return TextTheme(
      displayLarge: TextStyle(fontSize: baseSize * 2.5),
      displayMedium: TextStyle(fontSize: baseSize * 2.0),
      displaySmall: TextStyle(fontSize: baseSize * 1.75),
      headlineLarge: TextStyle(fontSize: baseSize * 1.5),
      headlineMedium: TextStyle(fontSize: baseSize * 1.25),
      headlineSmall: TextStyle(fontSize: baseSize * 1.1),
      bodyLarge: TextStyle(fontSize: baseSize),
      bodyMedium: TextStyle(fontSize: baseSize * 0.9),
      bodySmall: TextStyle(fontSize: baseSize * 0.8),
    );
  }

  static OutlinedBorder _getShape(UIConfig config) {
    final radius = config.shape == 'rounded'
        ? BorderRadius.circular(12)
        : BorderRadius.circular(4);

    return RoundedRectangleBorder(borderRadius: radius);
  }

  static BorderRadius _getBorderRadius(UIConfig config) {
    return config.shape == 'rounded'
        ? BorderRadius.circular(12)
        : BorderRadius.circular(4);
  }

  static EdgeInsets _getPadding(UIConfig config) {
    switch (config.density) {
      case 'compact':
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case 'spacious':
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case 'normal':
      default:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }
}

