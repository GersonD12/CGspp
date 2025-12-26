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
  /// NUEVO FORMATO: Usa idpregunta como clave para matching eficiente
  /// Además, guarda campos directos en el documento para tipos específicos (text, numero, multiple, fecha, pais)
  Future<void> uploadRespuestas(
    String userId,
    RespuestasState respuestasState,
  ) async {
    final userDocRef = _firestore.collection('users').doc(userId);

    // Agrupar respuestas por grupoId
    final Map<String, Map<String, dynamic>> gruposMap = {};
    
    // Mapa para campos directos en el documento del usuario
    final Map<String, dynamic> camposDirectos = {};
    
    // Tipos de preguntas que se guardan como campos directos
    const tiposParaCamposDirectos = {'texto', 'numero', 'multiple', 'fecha', 'pais'};
    
    for (final respuesta in respuestasState.todasLasRespuestas) {
      final grupoId = respuesta.grupoId;
      
      // Si el grupo no existe, crearlo
      if (!gruposMap.containsKey(grupoId)) {
        gruposMap[grupoId] = {};
      }
      
      // Agregar la respuesta al grupo correspondiente usando idpregunta como clave
      // Estructura: {grupoId: {idpregunta: respuesta}}
      gruposMap[grupoId]![respuesta.idpregunta] = respuesta.toMap();
      
      // Determinar si se debe guardar como campo directo
      // Si tiene tipoPregunta explícito, usarlo; si no, inferirlo desde los datos
      final tipoPregunta = respuesta.tipoPregunta?.toLowerCase().trim();
      final tipoInferido = _inferirTipoPregunta(respuesta);
      final tipoFinal = tipoPregunta ?? tipoInferido;
      
      // Guardar como campo directo si el tipo está en la lista permitida
      if (tipoFinal != null && tiposParaCamposDirectos.contains(tipoFinal)) {
        final valorCampo = _extraerValorParaCampoDirecto(respuesta, tipoFinal);
        if (valorCampo != null) {
          // Usar idpregunta como nombre del campo
          camposDirectos[respuesta.idpregunta] = valorCampo;
        }
      }
    }

    // Crear el mapa final que se subirá a Firestore
    // Estructura: form_responses -> grupos -> {grupoId: {idpregunta: respuesta}}
    final respuestasMap = {
      'form_responses': {
        'grupos': gruposMap,
      },
    };
    
    // Combinar respuestas estructuradas con campos directos
    final datosCompletos = {
      ...respuestasMap,
      ...camposDirectos,
    };

    // Subir las respuestas al documento del usuario
    await userDocRef.set(datosCompletos, SetOptions(merge: true));
  }
  
  /// Infiere el tipo de pregunta basándose en los datos disponibles en la respuesta
  String? _inferirTipoPregunta(RespuestaDTO respuesta) {
    // Si tiene respuestaOpciones, es multiple o radio
    if (respuesta.respuestaOpciones != null && respuesta.respuestaOpciones!.isNotEmpty) {
      return 'multiple';
    }
    
    // Si tiene respuestaImagenes, es imagen (no se guarda como campo directo)
    if (respuesta.respuestaImagenes != null && respuesta.respuestaImagenes!.isNotEmpty) {
      return 'imagen';
    }
    
    // Si tiene respuestaTexto y no tiene opciones ni imágenes, puede ser texto, numero, fecha, pais, telefono
    if (respuesta.respuestaTexto != null && respuesta.respuestaTexto!.isNotEmpty) {
      // Por defecto, asumimos que es texto (se puede refinar más adelante si es necesario)
      return 'texto';
    }
    
    return null;
  }
  
  /// Extrae el valor de la respuesta para guardarlo como campo directo según el tipo
  dynamic _extraerValorParaCampoDirecto(RespuestaDTO respuesta, String tipoPregunta) {
    switch (tipoPregunta) {
      case 'texto':
      case 'numero':
      case 'fecha':
      case 'pais':
        // Para estos tipos, el valor está en respuestaTexto
        return respuesta.respuestaTexto;
      
      case 'multiple':
        // Para múltiple, guardar el primer valor o todos como string separado por comas
        if (respuesta.respuestaOpciones != null && respuesta.respuestaOpciones!.isNotEmpty) {
          // Si hay múltiples valores, guardar como string separado por comas
          // Si solo hay uno, guardar solo ese valor
          return respuesta.respuestaOpciones!.length == 1
              ? respuesta.respuestaOpciones!.first
              : respuesta.respuestaOpciones!.join(',');
        }
        return null;
      
      default:
        return null;
    }
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
              // La clave puede ser idpregunta (nuevo formato) o preguntaId (formato antiguo)
              grupoData.forEach((idpreguntaOrPreguntaId, answerData) {
                try {
                  final respuestaDTO = RespuestaDTO.fromMap(answerData as Map<String, dynamic>);
                  // Usar idpregunta como clave en el mapa de respuestas
                  respuestasMap[respuestaDTO.idpregunta] = respuestaDTO;
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
          answers.forEach((preguntaIdOrIdpregunta, answerData) {
            try {
              final respuestaDTO = RespuestaDTO.fromMap(answerData as Map<String, dynamic>);
              // Usar idpregunta como clave en el mapa de respuestas
              respuestasMap[respuestaDTO.idpregunta] = respuestaDTO;
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

