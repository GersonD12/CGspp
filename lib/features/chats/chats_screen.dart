import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/app/routes/routes.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandardScrollable(
      title: 'Chats',
      actions: [
        // 1. IconButton (Ideal para íconos)
        IconButton(
          icon: const Icon(
            Icons.mail,
          ), // para solicitudes no leidas usar mark_email_unread
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.solicitudes);
          },
          tooltip: 'Solicitudes',
        ),
      ],
      showBackButton: false,
      headerColor: Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      showAppBar: true,
      padding: EdgeInsets.zero,
      separationHeight: 0,
      child: Center(child: Text('Chats')),
    );
  }
}
