import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';

/// Implementación del repositorio para operaciones con respuestas en Firestore
/// Esta es la implementación concreta que usa Firebase
class RespuestasRepositoryImpl implements RespuestasRepository {
  final FirebaseFirestore _firestore;

  /// Constructor del repositorio.
  /// Permite inyectar una instancia personalizada de [FirebaseFirestore] para testeo o mocks.
  /// Si no se proporciona, se usa [FirebaseFirestore.instance] por defecto.
  RespuestasRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  /// Sube las respuestas a Firestore
  Future<void> uploadRespuestas(
    String userId,
    RespuestasState respuestasState,
  ) async {
    final userDocRef = _firestore.collection('users').doc(userId);

    // Convertir las respuestas a un mapa, usando preguntaId como clave
    final Map<String, dynamic> answersMap = {};
    for (final respuesta in respuestasState.todasLasRespuestas) {
      answersMap[respuesta.preguntaId] = respuesta.toMap();
    }

    // Crear el mapa final que se subirá a Firestore
    final respuestasMap = {
      'form_responses': {
        'completed_at': FieldValue.serverTimestamp(),
        'answers': answersMap,
      },
    };

    // Subir las respuestas al documento del usuario
    await userDocRef.set(respuestasMap, SetOptions(merge: true));
  }
}

