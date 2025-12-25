import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/core/presentation/widgets/protected_widget.dart';
import 'package:calet/shared/widgets/widgets.dart';

class ProtectedHomeScreen extends BaseConsumerStatelessWidget {
  const ProtectedHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProtectedWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pantalla Protegida'),
        ),
        body: const Center(
          child: Text('¡Bienvenido! Esta es una pantalla protegida.'),
        ),
      ),
    );
  }
}
