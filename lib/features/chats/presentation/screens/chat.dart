import 'package:calet/features/cards/presentation/widgets/modal_perfiles.dart';
import 'package:calet/features/chats/infrastructure/data/bajar_conversacion.dart';
import 'package:calet/features/chats/infrastructure/repository/bajar_conversacion_repository.dart';
import 'package:calet/features/chats/infrastructure/data/iniciar_chat.dart';
import 'package:calet/features/chats/presentation/widgets/burbuja_mensaje.dart';
import 'package:calet/features/chats/presentation/widgets/cuadro_texto_chat.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final BajarConversacionRepository _repository = BajarConversacionRepository();
  final currentUser = FirebaseAuth.instance.currentUser;

  Stream<List<BajarConversacion>>? _mensajesStream;
  String? _idChat;
  String _userName = 'Chat';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_idChat == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is String) {
        _idChat = args;
      } else if (args is Map<String, dynamic>) {
        _idChat = args['idChat'] ?? '';
        _userName = args['userName'] ?? 'Chat';
      }

      if (_idChat != null && _idChat!.isNotEmpty) {
        _mensajesStream = _repository.escucharMensajes(_idChat!);
      }
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje(String idChat) async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty || currentUser == null) return;

    final now = DateTime.now().toIso8601String();
    _mensajeController.clear();

    // Obtenemos los UIDs del idChat (uid1_uid2)
    final parts = idChat.split('_');
    if (parts.length < 2) return;
    final String toUsuario = (parts[0] == currentUser!.uid)
        ? parts[1]
        : parts[0];

    try {
      await iniciarNuevoChat(
        idChat: idChat,
        fromUsuario: currentUser!.uid,
        toUsuario: toUsuario,
        createdAt: now,
        mensaje: texto,
        estado: 'pendiente',
      );
    } catch (e) {
      print('Error al enviar: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const CustomModal(
            text: 'Error de envío',
            height: 200,
            content: Center(
              child: Text(
                'No se pudo enviar el mensaje. Por favor, intenta de nuevo.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    }
  }

  String _formatearHora(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_idChat == null || _idChat!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Error: Chat no encontrado')),
      );
    }

    return VerticalViewStandardScrollable(
      title: _userName,
      showBackButton: true,
      fillRemaining: true,
      showAppBar: true,
      headerColor: Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // 1. Lista de mensajes (Fondo)
          Positioned.fill(
            child: StreamBuilder<List<BajarConversacion>>(
              stream: _mensajesStream,
              builder: (context, snapshot) {
                final mensajes = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting &&
                    mensajes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError && mensajes.isEmpty) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (mensajes.isEmpty) {
                  return const Center(child: Text('No hay mensajes aún.'));
                }

                return ListView.builder(
                  reverse: true, // Mostrar los últimos mensajes abajo
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 40,
                    bottom:
                        90, // Espacio para que el mensaje no quede tapado pero se vea detrás del glass
                  ),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    // Invertimos el índice porque reverse: true cambia el orden
                    final mensaje = mensajes[mensajes.length - 1 - index];
                    return BurbujaMensaje(
                      mensaje: mensaje.mensaje,
                      hora: _formatearHora(mensaje.createdAt),
                      esMio: mensaje.esMio(currentUser?.uid ?? ''),
                    );
                  },
                );
              },
            ),
          ),

          // 2. Barra de entrada (Flotante)
          Positioned(
            left: 10,
            right: 10,
            bottom: 15,
            child: CuadroTextoChat(
              controller: _mensajeController,
              onSend: () => _enviarMensaje(_idChat!),
            ),
          ),
        ],
      ),
    );
  }
}
