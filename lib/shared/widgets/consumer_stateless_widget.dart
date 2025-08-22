import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widget base que extiende ConsumerWidget de Riverpod
abstract class BaseConsumerStatelessWidget extends ConsumerWidget {
  const BaseConsumerStatelessWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref);
}
