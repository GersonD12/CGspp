import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/core/providers/session_provider.dart';

class ProtectedWidget extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? unauthenticatedWidget;

  const ProtectedWidget({
    super.key,
    required this.child,
    this.loadingWidget,
    this.unauthenticatedWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return session.when(
      data: (user) {
        if (user != null) {
          return child;
        } else {
          return unauthenticatedWidget ?? 
                 const Scaffold(
                   body: Center(
                     child: Text('Acceso no autorizado'),
                   ),
                 );
        }
      },
      loading: () => loadingWidget ?? 
                     const Scaffold(
                       body: Center(
                         child: CircularProgressIndicator(),
                       ),
                     ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
} 