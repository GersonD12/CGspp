import 'package:calet/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/cards/presentation/widgets/cards.dart';
import 'dart:developer' show log;
import 'package:calet/features/cards/domain/models/user_card.dart';
import 'package:calet/features/cards/domain/repositories/cards_repository.dart';
import 'package:calet/core/di/injection.dart';

class ScreenCards extends StatefulWidget {
  const ScreenCards({super.key});

  @override
  State<ScreenCards> createState() => _ScreenCardsState();
}

class _ScreenCardsState extends State<ScreenCards> {
  List<UserCard> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomUsers();
  }

  Future<void> _fetchRandomUsers() async {
    try {
      final repository = getIt<CardsRepository>();
      final randomUsers = await repository.fetchRandomUsers(15);

      setState(() {
        _users = randomUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandardScrollable(
      title: 'Cards',
      appBarFloats: true,
      headerColor: Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      centerTitle: true,
      showBackButton: false,
      hasFloatingNavBar: true, // Agregado para evitar solapamiento

      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text('No users found.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _users.map((user) {
                return Cards(
                  squareColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  borderColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  shadowColor: Theme.of(
                    context,
                  ).extension<AppThemeExtension>()!.shadowColor,
                  squareHeight: 200,
                  squareWidth: 380,
                  borderRadius: 20,
                  text: user.displayName,
                  textColor: const Color.fromARGB(198, 71, 71, 71),
                  textSize: 20,
                  onTapAction: () {
                    log('Card for ${user.displayName} tapped');
                    Navigator.pushNamed(
                      context,
                      '/user_detail', // Or AppRoutes.userDetail if accessible
                      arguments: user,
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
