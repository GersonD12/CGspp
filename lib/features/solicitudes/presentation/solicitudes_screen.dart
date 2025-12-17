import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/core/theme/app_theme_extension.dart';
import 'package:calet/features/cards/presentation/widgets/cards.dart';

class SolicitudesScreen extends StatelessWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandardScrollable(
      title: 'Solicitudes',
      showBackButton: true,
      headerColor: Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      showAppBar: true,
      padding: EdgeInsets.zero,
      separationHeight: 0,
      child: Column(
        children: [
          Cards(
            squareColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            shadowColor: Theme.of(
              context,
            ).extension<AppThemeExtension>()!.shadowColor,
            squareHeight: 200,
            squareWidth: 380,
            borderRadius: 20,
            text: 'Solicitud',
            textColor: const Color.fromARGB(198, 71, 71, 71),
            textSize: 20,
            onTapAction: () {
              Navigator.pushNamed(
                context,
                '/user_detail', // Or AppRoutes.userDetail if accessible
                //arguments: user,
              );
            },
          ),
        ],
      ),
    );
  }
}
