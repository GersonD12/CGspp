import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/cards/presentation/widgets/cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calet/features/cards/domain/models/user_card.dart';
import 'package:calet/features/cards/domain/repositories/questions_repository.dart';
import 'package:calet/core/di/injection.dart';
import 'dart:developer' show log;

import 'package:calet/features/solicitudes/infrastructure/repository/bajar_solicitudes_repository.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  List<UserCard> _pendingSolicitudes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingSolicitudes();
  }

  Future<void> _fetchPendingSolicitudes() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        log('No user logged in');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final questionsRepository = getIt<QuestionsRepository>();
      final questionsMap = await questionsRepository.fetchAllQuestions();

      final repository = BajarSolicitudesRepository();
      final solicitudes = await repository.bajarSolicitudesPorUID(
        currentUser.uid,
      );

      if (solicitudes.isEmpty) {
        log('No solicitudes found for user ${currentUser.uid}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<String> fromUsuarioIds = [];

      // Filter pending solicitudes and collect fromUsuario IDs
      for (var solicitud in solicitudes) {
        if (solicitud.estado == 'pendiente' &&
            solicitud.toUsuario == currentUser.uid) {
          fromUsuarioIds.add(solicitud.fromUsuario);
        }
      }

      log('Found ${fromUsuarioIds.length} pending solicitudes');

      // Fetch user data for each fromUsuario
      List<UserCard> users = [];
      for (String userId in fromUsuarioIds) {
        try {
          final userDoc = await firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            users.add(
              UserCard.fromMap(userId, userData, questionsMap: questionsMap),
            );
          }
        } catch (e) {
          log('Error fetching user $userId: $e');
        }
      }

      setState(() {
        _pendingSolicitudes = users;
        _isLoading = false;
      });
    } catch (e) {
      log('Error fetching pending solicitudes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingSolicitudes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No tienes solicitudes pendientes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          : Column(
              children: _pendingSolicitudes.map((user) {
                return Cards(
                  squareHeight: 200,
                  squareWidth: 380,
                  borderRadius: 20,
                  text: user.displayName,
                  textColor: const Color.fromARGB(198, 71, 71, 71),
                  textSize: 20,
                  onTapAction: () {
                    Navigator.pushNamed(
                      context,
                      '/user_detail',
                      arguments: user,
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
