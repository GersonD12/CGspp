import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/application/dto/respuesta_dto.dart';
import 'dart:developer' show log;

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

  @override
  /// Descarga las respuestas guardadas del formulario
  Future<RespuestasState?> downloadRespuestas(String userId) async {
    try {
      log('downloadRespuestas: Buscando respuestas para userId: $userId');
      final userDocRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        log('downloadRespuestas: Documento de usuario no existe');
        return null;
      }

      final data = docSnapshot.data();
      log('downloadRespuestas: Datos del documento: $data');
      if (data == null || !data.containsKey('form_responses')) {
        log('downloadRespuestas: No hay form_responses en el documento');
        return null;
      }

      final formResponses = data['form_responses'] as Map<String, dynamic>?;
      log('downloadRespuestas: form_responses: $formResponses');
      if (formResponses == null || !formResponses.containsKey('answers')) {
        log('downloadRespuestas: No hay answers en form_responses');
        return null;
      }

      final answers = formResponses['answers'] as Map<String, dynamic>?;
      log('downloadRespuestas: answers: $answers');
      if (answers == null || answers.isEmpty) {
        log('downloadRespuestas: answers está vacío');
        return null;
      }

      // Convertir el mapa de respuestas a RespuestaDTO y luego a RespuestasState
      final Map<String, RespuestaDTO> respuestasMap = {};

      answers.forEach((preguntaId, answerData) {
        try {
          log('downloadRespuestas: Procesando pregunta $preguntaId con datos: $answerData');
          final respuestaDTO = RespuestaDTO.fromMap(answerData as Map<String, dynamic>);
          respuestasMap[preguntaId] = respuestaDTO;
          log('downloadRespuestas: Respuesta procesada exitosamente para $preguntaId');
        } catch (e) {
          log('downloadRespuestas: Error al procesar respuesta $preguntaId: $e');
          // Ignorar respuestas con formato inválido
        }
      });

      log('downloadRespuestas: Total respuestas cargadas: ${respuestasMap.length}');
      return RespuestasState(respuestas: respuestasMap);
    } catch (e) {
      log('downloadRespuestas: Error general: $e');
      return null;
    }
  }
}

