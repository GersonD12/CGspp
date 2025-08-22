import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuración para tests que incluye Riverpod
class TestApp extends StatelessWidget {
  final Widget child;
  
  const TestApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

/// Widget de test que incluye ProviderScope
Widget createTestApp(Widget child) {
  return TestApp(child: child);
}

/// Helper para crear un ProviderContainer de test
ProviderContainer createTestProviderContainer() {
  return ProviderContainer();
}
