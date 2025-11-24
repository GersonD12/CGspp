import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/application/dto/respuesta_dto.dart';

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
  /// Sube las respuestas a Firestore agrupadas por grupoId
  Future<void> uploadRespuestas(
    String userId,
    RespuestasState respuestasState,
  ) async {
    final userDocRef = _firestore.collection('users').doc(userId);

    // Agrupar respuestas por grupoId
    final Map<String, Map<String, dynamic>> gruposMap = {};
    
    for (final respuesta in respuestasState.todasLasRespuestas) {
      final grupoId = respuesta.grupoId;
      
      // Si el grupo no existe, crearlo
      if (!gruposMap.containsKey(grupoId)) {
        gruposMap[grupoId] = {};
      }
      
      // Agregar la respuesta al grupo correspondiente
      gruposMap[grupoId]![respuesta.preguntaId] = respuesta.toMap();
    }

    // Crear el mapa final que se subirá a Firestore
    // Estructura: form_responses -> grupos -> {grupoId: {preguntaId: respuesta}}
    final respuestasMap = {
      'form_responses': {
        'grupos': gruposMap,
      },
    };

    // Subir las respuestas al documento del usuario
    await userDocRef.set(respuestasMap, SetOptions(merge: true));
  }

  @override
  /// Descarga las respuestas guardadas del formulario
  Future<RespuestasState?> downloadRespuestas(String userId) async {
    try {

      final userDocRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data();

      if (data == null || !data.containsKey('form_responses')) {

        return null;
      }

      final formResponses = data['form_responses'] as Map<String, dynamic>?;

      // Convertir el mapa de respuestas a RespuestaDTO y luego a RespuestasState
      final Map<String, RespuestaDTO> respuestasMap = {};

      // Intentar leer la nueva estructura agrupada (grupos)
      if (formResponses != null && formResponses.containsKey('grupos')) {
        final grupos = formResponses['grupos'] as Map<String, dynamic>?;

        
        if (grupos != null && grupos.isNotEmpty) {
          // Iterar sobre cada grupo
          grupos.forEach((grupoId, grupoData) {
            if (grupoData is Map<String, dynamic>) {
              // Iterar sobre las respuestas del grupo
              grupoData.forEach((preguntaId, answerData) {
                try {
                  
                  final respuestaDTO = RespuestaDTO.fromMap(answerData as Map<String, dynamic>);
                  respuestasMap[preguntaId] = respuestaDTO;
                } catch (e) {
                  // Ignorar respuestas con formato inválido
                }
              });
            }
          });
        }
      } 
      // Compatibilidad con estructura antigua (answers directo)
      else if (formResponses != null && formResponses.containsKey('answers')) {
        final answers = formResponses['answers'] as Map<String, dynamic>?;
        
        if (answers != null && answers.isNotEmpty) {
          answers.forEach((preguntaId, answerData) {
            try {
              final respuestaDTO = RespuestaDTO.fromMap(answerData as Map<String, dynamic>);
              respuestasMap[preguntaId] = respuestaDTO;
            } catch (e) {
              // Ignorar respuestas con formato inválido
            }
          });
        }
      } else {
        return null;
      }

      if (respuestasMap.isEmpty) {
        return null;
      }

      return RespuestasState(respuestas: respuestasMap);
    } catch (e) {
      return null;
    }
  }
}

