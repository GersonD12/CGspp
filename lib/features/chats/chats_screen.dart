import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandardScrollable(
      title: 'Chats',
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
