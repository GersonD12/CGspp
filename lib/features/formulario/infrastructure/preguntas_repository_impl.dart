import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calet/features/formulario/domain/repositories/preguntas_repository.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';

/// Implementación del repositorio para operaciones con preguntas en Firestore
/// Esta es la implementación concreta que usa Firebase
class PreguntasRepositoryImpl implements PreguntasRepository {
  final FirebaseFirestore _firestore;

  /// Constructor del repositorio.
  /// Permite inyectar una instancia personalizada de [FirebaseFirestore] para testeo o mocks.
  /// Si no se proporciona, se usa [FirebaseFirestore.instance] por defecto.
  PreguntasRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  /// Obtiene todas las preguntas activas agrupadas por sección
  Future<Map<String, dynamic>> obtenerPreguntas() async {
    // Lista para almacenar todas las preguntas de todos los grupos
    List<PreguntaDTO> todasLasPreguntas = [];
    Map<String, SeccionDTO> seccionesTemp = {};

    // Intentar obtener el documento 'questions' que contiene todas las secciones
    final questionsDoc = await _firestore
        .collection('questions')
        .doc('questions')
        .get();

    if (questionsDoc.exists) {
      // Nuevo formato: documento único con estructura anidada
      final questionsData = questionsDoc.data();
      if (questionsData != null && questionsData.containsKey('questions')) {
        final sectionsMap = questionsData['questions'] as Map<String, dynamic>;
        
        // Procesar cada sección
        for (final sectionEntry in sectionsMap.entries) {
          final sectionId = sectionEntry.key;
          final sectionData = sectionEntry.value as Map<String, dynamic>;
          
          // Crear SeccionDTO
          final seccionDTO = SeccionDTO.fromMap(sectionId, sectionData);
          seccionesTemp[sectionId] = seccionDTO;
          
          // Obtener las preguntas de la subcolección
          final subcollections = sectionData['_subcollections'] as Map<String, dynamic>?;
          if (subcollections != null) {
            final questionsSubcollection = subcollections['questions'] as Map<String, dynamic>?;
            if (questionsSubcollection != null) {
              // Procesar cada pregunta
              for (final questionEntry in questionsSubcollection.entries) {
                final questionId = questionEntry.key;
                final questionData = questionEntry.value as Map<String, dynamic>;
                
                // Solo procesar preguntas activas (estado == true)
                final estado = questionData['estado'] as bool? ?? true;
                if (!estado) continue;
                
                final pregunta = PreguntaDTO.fromMap(
                  questionId,
                  sectionId,
                  questionData,
                );
                todasLasPreguntas.add(pregunta);
              }
            }
          }
        }
      }
    } else {
      // Formato antiguo: subcolecciones de Firestore
      final QuerySnapshot gruposSnapshot = await _firestore
          .collection('questions')
          .get();

      // Para cada documento (grupo), obtener su información y subcolección 'questions'
      final List<Future<void>> futures = gruposSnapshot.docs.map((grupoDoc) async {
        try {
          // Cargar información de la sección (titulo, descripcion, orden)
          final seccionData = grupoDoc.data() as Map<String, dynamic>;
          final seccionDTO = SeccionDTO.fromMap(
            grupoDoc.id,
            seccionData,
          );
          seccionesTemp[grupoDoc.id] = seccionDTO;
          
          // Obtener la subcolección 'questions' de este grupo
          final QuerySnapshot preguntasSnapshot = await grupoDoc.reference
              .collection('questions')
              .get();

          // Mapear las preguntas de esta subcolección a DTOs
          final preguntasDelGrupo = preguntasSnapshot.docs.map((preguntaDoc) {
            final preguntaData = preguntaDoc.data() as Map<String, dynamic>;
            
            // Solo procesar preguntas activas (estado == true)
            final estado = preguntaData['estado'] as bool? ?? true;
            if (!estado) return null;
            
            final pregunta = PreguntaDTO.fromMap(
              preguntaDoc.id,
              grupoDoc.id, // Pasar el ID del grupo
              preguntaData,
            );
            
            return pregunta;
          }).where((p) => p != null).cast<PreguntaDTO>().toList();

          // Agregar las preguntas de este grupo a la lista total
          todasLasPreguntas.addAll(preguntasDelGrupo);
        } catch (e) {
          // Si hay un error al obtener las preguntas de un grupo, continuar con los demás
        }
      }).toList();

      // Esperar a que todas las consultas se completen
      await Future.wait(futures);
    }

    return {
      'preguntas': todasLasPreguntas,
      'secciones': seccionesTemp,
    };
  }
}

