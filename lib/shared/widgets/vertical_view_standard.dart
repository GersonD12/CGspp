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
  final bool showAppBar;

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
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBgColor = headerColor ?? theme.primaryColor;
    final textColor = foregroundColor ?? theme.primaryColor;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                title,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              centerTitle: centerTitle,
              backgroundColor: headerBgColor,
              foregroundColor: textColor,
              elevation: 0,
              automaticallyImplyLeading: showBackButton,
              leading: showBackButton
                  ? (leading ??
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed:
                              onBackPressed ??
                              () => Navigator.of(context).pop(),
                        ))
                  : null,
              actions: actions,
            )
          : null,
      body: Container(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (showAppBar) SizedBox(height: separationHeight),
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
  final bool appBarFloats;
  final double separationHeight;
  final Color? headerColor;
  final Color? foregroundColor;
  final Color? backgroundColor; //agregado
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final EdgeInsets? padding;
  final bool centerTitle;
  final ScrollPhysics? physics; // Restaurado
  final bool hasFloatingNavBar; // Nuevo parámetro
  final bool showAppBar;

  const VerticalViewStandardScrollable({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.separationHeight = 16.0,
    this.headerColor,
    this.foregroundColor,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.padding,
    this.centerTitle = true,
    this.physics, // Restaurado
    this.appBarFloats = false,
    this.hasFloatingNavBar = false, // Por defecto desactivado
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBgColor = headerColor ?? theme.primaryColor;
    final textColor = foregroundColor ?? theme.primaryColor;
    final bodyBgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    // Calcular el padding final
    final basePadding = padding ?? const EdgeInsets.all(16.0);
    final finalPadding = hasFloatingNavBar
        ? basePadding.add(const EdgeInsets.only(bottom: 100.0)) // Espacio extra
        : basePadding;

    return Scaffold(
      backgroundColor: bodyBgColor,
      body: Container(
        color: bodyBgColor,
        child: CustomScrollView(
          physics: physics,
          slivers: <Widget>[
            if (showAppBar)
              SliverAppBar(
                title: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: centerTitle,
                backgroundColor: headerBgColor,
                foregroundColor: textColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                floating: appBarFloats,
                snap: appBarFloats,
                pinned: !appBarFloats,
                leading: showBackButton
                    ? (leading ??
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: textColor),
                            onPressed:
                                onBackPressed ??
                                () => Navigator.of(context).pop(),
                          ))
                    : null,
                automaticallyImplyLeading: false,
                actions: actions,
              ),

            // 2. CONTENIDO DE LA LISTA (SLIVER)
            SliverToBoxAdapter(
              child: Container(
                color: bodyBgColor,
                child: Padding(padding: finalPadding, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
