import 'package:flutter/material.dart';
import 'package:calet/core/di/injection.dart';
import 'package:calet/core/domain/entities/entities.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/application/use_cases/use_cases.dart';
import 'package:calet/features/formulario/domain/repositories/preguntas_repository.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/shared/widgets/protected_screen_state.dart';
import 'package:calet/features/profile/presentation/widgets/seccion_respuestas_widget.dart';

class EditProfileScreen extends ProtectedScreenStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ProtectedScreenState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ProtectedScreenState<EditProfileScreen> {
  bool _isLoading = true;
  String? _error;
  String? _userId;
  
  // Datos del formulario
  Map<String, SeccionDTO> _secciones = {};
  List<String> _ordenSecciones = [];
  Map<String, List<PreguntaDTO>> _preguntasPorGrupo = {};
  RespuestasState? _respuestasState;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadData(UserEntity user) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _userId = user.id;
      });

      // Cargar preguntas y secciones
      final preguntasRepository = getIt<PreguntasRepository>();
      final obtenerPreguntasUseCase = ObtenerPreguntasUseCase(preguntasRepository);
      final resultado = await obtenerPreguntasUseCase.execute();

      _secciones = resultado['secciones'] as Map<String, SeccionDTO>;
      _ordenSecciones = resultado['ordenSecciones'] as List<String>;
      _preguntasPorGrupo = resultado['preguntasPorGrupo'] as Map<String, List<PreguntaDTO>>;

      // Cargar respuestas guardadas
      final repository = getIt<RespuestasRepository>();
      _respuestasState = await repository.downloadRespuestas(user.id);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar los datos: $e';
      });
    }
  }

  /// Recarga solo las respuestas sin recargar las preguntas
  Future<void> _recargarRespuestas() async {
    if (_userId == null) return;
    
    try {
      final repository = getIt<RespuestasRepository>();
      final nuevasRespuestas = await repository.downloadRespuestas(_userId!);
      
      if (mounted) {
        setState(() {
          _respuestasState = nuevasRespuestas;
        });
      }
    } catch (e) {
      // Silenciar errores al recargar, no queremos interrumpir la UI
      debugPrint('Error al recargar respuestas: $e');
    }
  }

  @override
  Widget buildProtectedContent(BuildContext context, UserEntity user) {
    // Cargar datos cuando se construye el contenido protegido
    if (_isLoading && _ordenSecciones.isEmpty && _error == null) {
      _loadData(user);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadData(user),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_ordenSecciones.isEmpty) {
      return const Center(
        child: Text('No hay secciones disponibles'),
      );
    }

    if (_userId == null) {
      return const Center(
        child: Text('Error: No se pudo obtener el ID del usuario'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ordenSecciones.length,
      itemBuilder: (context, index) {
        final seccionId = _ordenSecciones[index];
        final seccion = _secciones[seccionId];
        
        if (seccion == null) return const SizedBox.shrink();

        // Obtener preguntas de esta sección
        final preguntasSeccion = _preguntasPorGrupo[seccionId] ?? [];
        
        // Obtener respuestas de esta sección
        final respuestasSeccion = _respuestasState?.todasLasRespuestas
            .where((r) => r.grupoId == seccionId)
            .toList() ?? [];

        // Crear mapa de respuestas por idpregunta
        final respuestasMap = {
          for (final r in respuestasSeccion) r.idpregunta: r,
        };

        return SeccionRespuestasWidget(
          seccion: seccion,
          preguntas: preguntasSeccion,
          respuestas: respuestasMap,
          userId: _userId!,
          onRespuestaGuardada: _recargarRespuestas,
        );
      },
    );
  }
}

