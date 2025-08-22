import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class AppConfig {
  final Brightness brightness;
  final ThemeData theme;

  AppConfig({
    required this.brightness,
    required this.theme,
  });
}

final configProvider = StateProvider<AppConfig>((ref) {
  return AppConfig(
    brightness: Brightness.light,
    theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
  );
});
