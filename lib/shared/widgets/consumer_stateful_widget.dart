import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widget base que extiende ConsumerStatefulWidget de Riverpod
abstract class BaseConsumerStatefulWidget extends ConsumerStatefulWidget {
  const BaseConsumerStatefulWidget({super.key});
}

// State base que extiende ConsumerState de Riverpod
abstract class BaseConsumerState<T extends BaseConsumerStatefulWidget> extends ConsumerState<T> {
  @override
  Widget build(BuildContext context);
}
