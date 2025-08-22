# Arquitectura Limpia con Riverpod y GetIt

## Estructura del Proyecto

```
lib/
├── app/
│   ├── routes/
│   └── view/
│       └── app.dart          # Configuración principal de la app
├── core/
│   ├── di/
│   │   └── injection.dart    # Inyección de dependencias con GetIt
│   ├── providers/
│   │   ├── config_provider.dart    # Provider de configuración
│   │   ├── session_provider.dart   # Provider de sesión
│   │   └── providers.dart          # Archivo barril
│   └── presentation/
│       └── widgets/
│           └── protected_widget.dart # Widget de seguridad
├── features/
│   └── auth/
│       ├── domain/
│       ├── screen/
│       └── service/
├── shared/
│   └── widgets/
│       ├── consumer_stateful_widget.dart  # Widget base stateful
│       ├── consumer_stateless_widget.dart # Widget base stateless
│       └── widgets.dart                   # Archivo barril
└── main.dart                 # Punto de entrada con Riverpod
```

## Tecnologías Utilizadas

- **Riverpod**: Para gestión de estado y providers
- **GetIt**: Para inyección de dependencias
- **Firebase Auth**: Para autenticación

## Componentes Principales

### 1. Configuración (config_provider.dart)
- Maneja el tema de la aplicación
- Configuración global de la app

### 2. Seguridad (session_provider.dart)
- Escucha cambios en la sesión de Firebase
- Proporciona estado de autenticación

### 3. ProtectedWidget
- Widget que protege contenido basado en autenticación
- Escucha el sessionProvider automáticamente

### 4. Widgets Base
- `BaseConsumerStatefulWidget`: Para widgets con estado
- `BaseConsumerStatelessWidget`: Para widgets sin estado

## Uso

### Widget Protegido
```dart
class MyProtectedScreen extends BaseConsumerStatelessWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProtectedWidget(
      child: Scaffold(
        body: Text('Contenido protegido'),
      ),
    );
  }
}
```

### Configuración de Tema
```dart
// En app.dart
final config = ref.watch(configProvider);
return MaterialApp(
  theme: config.theme,
  // ...
);
```

### Inyección de Dependencias
```dart
// En cualquier lugar del código
final authService = getIt<GoogleAuthService>();
```

## Características

- ✅ Arquitectura limpia simple
- ✅ Riverpod para gestión de estado
- ✅ GetIt para inyección de dependencias
- ✅ Widget de seguridad integrado
- ✅ Tema configurable
- ✅ Sin debug banner
- ✅ Base widgets para UI
