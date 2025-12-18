import 'package:calet/features/chats/infrastructure/data/bajar_lista_chats.dart';
import 'package:calet/features/chats/infrastructure/repository/bajar_lista_chats_repository.dart';
import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/app/routes/routes.dart';
import 'package:calet/features/chats/presentation/widgets/imagen_perfil.dart';

class ListChatsScreen extends StatefulWidget {
  const ListChatsScreen({super.key});

  @override
  State<ListChatsScreen> createState() => _ListChatsScreenState();
}

class _ListChatsScreenState extends State<ListChatsScreen> {
  final BajarListaChatsRepository _repository = BajarListaChatsRepository();

  String _formatearHora(String isoDate) {
    if (isoDate.isEmpty) return '--:--';
    try {
      final date = DateTime.parse(isoDate);
      final hora = date.hour.toString().padLeft(2, '0');
      final minuto = date.minute.toString().padLeft(2, '0');
      return "$hora:$minuto";
    } catch (e) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandardScrollable(
      title: 'Chats',
      actions: [
        IconButton(
          icon: const Icon(Icons.mail),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.solicitudes);
          },
          tooltip: 'Solicitudes',
        ),
      ],
      showBackButton: false,
      headerColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      showAppBar: true,
      padding: EdgeInsets.zero,
      separationHeight: 0,
      child: StreamBuilder<List<BajarListaChats>>(
        stream: _repository.escucharListaChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Text('No tienes chats activos aún.'),
              ),
            );
          }

          return Column(
            children: chats.map((chat) {
              return ImagenPerfil(
                nombre: chat.otherUserDisplayName,
                mensaje: chat.mensaje,
                hora: _formatearHora(chat.createdAt),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chat,
                    arguments: {
                      'idChat': chat.idChat,
                      'userName': chat.otherUserDisplayName,
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
