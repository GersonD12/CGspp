import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:calet/core/theme/app_theme_extension.dart';

/// Widget que construye un contenedor con efecto glass similar al menú
class GlassContainerWidget extends StatelessWidget {
  final Widget child;

  const GlassContainerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>();
    final barColor = appTheme?.barColor ?? theme.colorScheme.surfaceContainerHighest;
    final barBorder = appTheme?.barBorder ?? theme.colorScheme.outline;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: barColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: barBorder.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: barColor.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

