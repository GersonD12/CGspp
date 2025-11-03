/// Entidad de Pregunta del dominio de formulario
/// 
/// Esta entidad es independiente de la fuente de datos (Firestore, API, etc.)
/// Define la estructura y comportamiento de las preguntas en el negocio
class PreguntaEntity {
  final String id;
  final DateTime createdAt;
  final String descripcion;
  final String tipo;
  final List<String> opciones;
  final String encabezado;
  final bool allowCustomOption;
  final String customOptionLabel;

  const PreguntaEntity({
    required this.id,
    required this.createdAt,
    required this.descripcion,
    required this.tipo,
    required this.opciones,
    required this.encabezado,
    this.allowCustomOption = false,
    required this.customOptionLabel,
  });

  /// Crea una copia de la entidad con cambios
  PreguntaEntity copyWith({
    String? id,
    DateTime? createdAt,
    String? descripcion,
    String? tipo,
    List<String>? opciones,
    String? encabezado,
    bool? allowCustomOption,
    String? customOptionLabel,
  }) {
    return PreguntaEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      opciones: opciones ?? this.opciones,
      encabezado: encabezado ?? this.encabezado,
      allowCustomOption: allowCustomOption ?? this.allowCustomOption,
      customOptionLabel: customOptionLabel ?? this.customOptionLabel,
    );
  }

  /// Valida si la pregunta tiene opciones configuradas
  bool get tieneOpciones => opciones.isNotEmpty;

  /// Valida si es una pregunta de tipo texto
  bool get esTipoTexto => tipo == 'texto';

  /// Valida si es una pregunta de tipo radio/múltiple
  bool get esTipoRadio => tipo == 'radio' || tipo == 'multiple';

  /// Valida si es una pregunta de tipo imagen
  bool get esTipoImagen => tipo == 'imagen';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreguntaEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PreguntaEntity(id: $id, descripcion: $descripcion, tipo: $tipo)';
  }
}

