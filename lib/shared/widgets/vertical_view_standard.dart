import 'package:flutter/material.dart';

/// Widget estándar para vistas verticales con header personalizable
class VerticalViewStandard extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final double separationHeight;
  final Color? headerColor;
  final Color? foregroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final EdgeInsets? padding;
  final bool centerTitle;

  const VerticalViewStandard({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.separationHeight = 16.0,
    this.headerColor,
    this.foregroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.padding,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBgColor = headerColor ?? theme.primaryColor;
    final textColor = foregroundColor ?? theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: centerTitle,
        backgroundColor: headerBgColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: showBackButton
            ? (leading ??
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  ))
            : null,
        actions: actions,
      ),
      body: Container(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: separationHeight),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Variante con scroll automático
class VerticalViewStandardScrollable extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final double separationHeight;
  final Color? headerColor;
  final Color? foregroundColor;
  final Color? backgroundColor; //agregado
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final EdgeInsets? padding;
  final bool centerTitle;
  final ScrollPhysics? physics;

  const VerticalViewStandardScrollable({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.separationHeight = 16.0,
    this.headerColor,
    this.foregroundColor,
    this.backgroundColor, //agregado para tener un color de fondo personalizado
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.padding,
    this.centerTitle = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBgColor = headerColor ?? theme.primaryColor;
    final textColor = foregroundColor ?? theme.primaryColor;
    final bodyBgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bodyBgColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: centerTitle,
        backgroundColor: headerBgColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: showBackButton
            ? (leading ??
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  ))
            : null,
        actions: actions,
      ),
      body: SingleChildScrollView(
        physics: physics,
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: separationHeight),
            child,
            SizedBox(height: separationHeight),
          ],
        ),
      ),
    );
  }
}
