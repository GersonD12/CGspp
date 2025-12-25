# Arquitectura Limpia con Riverpod, GetIt y Clean Architecture

## 📐 Visión General

Este proyecto implementa **Clean Architecture** con separación de capas claramente definida. Utilizamos **Riverpod** para gestión de estado, **GetIt** para inyección de dependencias y **Firebase** para backend.

## 🏗️ Estructura General del Proyecto

```
lib/
├── app/
│   ├── routes/                    # Configuración de rutas
│   │   └── routes.dart
│   └── view/
│       ├── app.dart              # Configuración principal con Riverpod
│       └── splash_screen.dart
│
├── core/
│   ├── di/
│   │   └── injection.dart        # Inyección de dependencias con GetIt
│   ├── domain/
│   │   └── entities/
│   │       ├── user_entity.dart  # Entidades compartidas
│   │       └── entities.dart
│   ├── infrastructure/
│   │   └── storage_service.dart  # Servicios compartidos
│   ├── presentation/
│   │   └── widgets/
│   │       └── protected_widget.dart
│   └── providers/
│       ├── config_provider.dart  # Provider de configuración
│       ├── session_provider.dart # Provider de sesión
│       └── providers.dart
│
├── features/
│   ├── auth/                     # Feature: Autenticación
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── domain.dart       # Barrel
│   │   ├── infrastructure/
│   │   │   ├── google_auth_service.dart
│   │   │   └── infrastructure.dart  # Barrel
│   │   ├── presentation/
│   │   │   ├── google_login_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── protected_home_screen.dart
│   │   │   ├── screens.dart
│   │   │   └── presentation.dart    # Barrel
│   │   └── auth.dart             # Barrel principal
│   │
│   ├── cards/                    # Feature: Cards (UI simple)
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── screen_cards.dart
│   │   │   │   └── screens.dart
│   │   │   ├── widgets/
│   │   │   │   ├── cards.dart
│   │   │   │   ├── modal_perfiles.dart
│   │   │   │   └── widgets.dart
│   │   │   └── presentation.dart
│   │   └── cards.dart            # Barrel principal
│   │
│   ├── profile/                  # Feature: Perfil de Usuario
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── screens.dart
│   │   │   ├── widgets/
│   │   │   │   ├── profile_header.dart
│   │   │   │   └── widgets.dart
│   │   │   └── presentation.dart
│   │   └── profile.dart          # Barrel principal
│   │
│   ├── formulario/              # Feature: Formularios (ejemplo completo)
│   │   ├── application/         # Orquesta reglas y repositorios
│   │   │   ├── use_cases/       # Casos de uso (lógica de negocio)
│   │   │   │   ├── guardar_respuesta_usecase.dart
│   │   │   │   ├── finalizar_formulario_usecase.dart
│   │   │   │   └── use_cases.dart
│   │   │   ├── dto/            # Data Transfer Objects
│   │   │   │   ├── pregunta_dto.dart
│   │   │   │   ├── respuesta_dto.dart
│   │   │   │   └── dto.dart
│   │   │   └── application.dart
│   │   │
│   │   ├── domain/             # Reglas de negocio
│   │   │   ├── entities/       # Entidades del dominio
│   │   │   │   ├── pregunta_entity.dart
│   │   │   │   ├── respuesta_entity.dart
│   │   │   │   └── entities.dart
│   │   │   ├── repositories/   # Contratos (interfaces)
│   │   │   │   └── respuestas_repository.dart
│   │   │   └── domain.dart
│   │   │
│   │   ├── infrastructure/     # Implementaciones técnicas
│   │   │   ├── respuestas_repository_impl.dart
│   │   │   └── infrastructure.dart
│   │   │
│   │   ├── presentation/       # Interfaz de usuario
│   │   │   ├── controllers/    # Controladores de UI
│   │   │   │   └── respuestas_controller.dart
│   │   │   ├── providers/      # Providers de Riverpod
│   │   │   │   ├── respuestas_provider.dart
│   │   │   │   └── respuestas_state.dart
│   │   │   ├── screens/        # Pantallas
│   │   │   │   ├── formulario_screen.dart
│   │   │   │   ├── preguntas_screen.dart
│   │   │   │   └── screens.dart
│   │   │   ├── widgets/        # Widgets reutilizables
│   │   │   │   └── widgets.dart
│   │   │   └── presentation.dart
│   │   │
│   │   └── formulario.dart     # Barrel principal del módulo
│   │
│   └── ...
│
├── shared/
│   └── widgets/
│       ├── consumer_stateful_widget.dart
│       ├── consumer_stateless_widget.dart
│       ├── protected_screen_state.dart
│       ├── vertical_view_standard.dart
│       └── widgets.dart
│
└── main.dart                    # Punto de entrada con ProviderScope
```

## 🎯 Arquitectura por Capas (Clean Architecture)

### **1. Domain Layer** (Centro - Reglas de Negocio)

Responsabilidad: Contiene las reglas de negocio puras, independientes de frameworks.

```
domain/
├── entities/          # Entidades del dominio (modelos de negocio)
├── repositories/      # Interfaces/contratos de repositorios
├── enums/            # Enumeraciones de negocio (opcional)
├── utils/            # Utilidades de negocio (opcional)
├── constants/        # Constantes de negocio (opcional)
└── domain.dart       # Barrel file
```

**Características:**
- ✅ No depende de otras capas
- ✅ Contiene lógica de negocio pura
- ✅ Define contratos (interfaces) para repositorios
- ✅ No tiene imports de Flutter, Firebase, etc.

**Ejemplo:**
```dart
// domain/entities/respuesta_entity.dart
class RespuestaEntity {
  final String preguntaId;
  final String? respuestaTexto;
  
  bool get estaCompleta => respuestaTexto?.isNotEmpty ?? false;
}

// domain/repositories/respuestas_repository.dart
abstract class RespuestasRepository {
  Future<void> uploadRespuestas(String userId, RespuestasState state);
}
```

---

### **2. Application Layer** (Orquestación - Casos de Uso)

Responsabilidad: Orquesta las reglas de negocio y coordina repositorios.

```
application/
├── use_cases/        # Casos de uso (acción del usuario)
│   ├── guardar_respuesta_usecase.dart
│   ├── finalizar_formulario_usecase.dart
│   └── use_cases.dart
├── dto/              # Data Transfer Objects (Requests/Responses)
│   ├── pregunta_dto.dart
│   ├── respuesta_dto.dart
│   └── dto.dart
├── services/         # Servicios de aplicación (coordina varios repos)
├── validators/       # Validaciones de reglas transversales
├── failures/         # Tipos de error expuestos a UI
└── application.dart  # Barrel file
```

**Características:**
- ✅ Depende solo de domain
- ✅ Contiene casos de uso específicos
- ✅ Orquesta múltiples repositorios si es necesario
- ✅ Define DTOs para transferencia de datos

**Ejemplo:**
```dart
// application/use_cases/finalizar_formulario_usecase.dart
class FinalizarFormularioUseCase {
  final RespuestasRepository _repository;

  Future<void> execute({
    required String userId,
    required RespuestasState state,
  }) async {
    if (state.totalRespuestas > 0) {
      await _repository.uploadRespuestas(userId, state);
    }
  }
}
```

---

### **3. Infrastructure Layer** (Implementaciones Técnicas)

Responsabilidad: Implementa los contratos definidos en domain.

```
infrastructure/
├── repositories/
│   └── respuestas_repository_impl.dart
└── infrastructure.dart
```

**Características:**
- ✅ Implementa interfaces de domain
- ✅ Contiene toda la lógica técnica (Firebase, API, DB)
- ✅ Puede usar DTOs para serialización
- ✅ Convierte DTOs ↔ Entities

**Ejemplo:**
```dart
// infrastructure/respuestas_repository_impl.dart
class RespuestasRepositoryImpl implements RespuestasRepository {
  final FirebaseFirestore _firestore;

  @override
  Future<void> uploadRespuestas(String userId, RespuestasState state) async {
    // Implementación con Firebase
    await _firestore.collection('users').doc(userId).set({
      'form_responses': state.toMap(),
    });
  }
}
```

---

### **4. Presentation Layer** (Interfaz de Usuario)

Responsabilidad: UI, estado local y coordinación con casos de uso.

```
presentation/
├── controllers/      # Controladores de UI
├── providers/        # Providers de Riverpod
├── screens/          # Pantallas
├── widgets/          # Widgets reutilizables
├── views/            # Vistas (opcional)
└── presentation.dart # Barrel file
```

**Características:**
- ✅ Depende de application (use_cases) y domain (entities)
- ✅ NO depende directamente de infrastructure
- ✅ Usa Riverpod para gestión de estado
- ✅ Los controllers llaman a use_cases

**Ejemplo:**
```dart
// presentation/providers/respuestas_provider.dart
final respuestasProvider = StateNotifierProvider<RespuestasNotifier, RespuestasState>((ref) {
  return RespuestasNotifier();
});

// presentation/controllers/respuestas_controller.dart
class RespuestasController {
  final WidgetRef ref;

  Future<void> finalizarFormulario() async {
    final useCase = FinalizarFormularioUseCase(repository: getIt<RespuestasRepository>());
    await useCase.execute(userId: user.id, respuestasState: state);
  }
}
```

---

## 🔄 Flujo de Datos

```
┌─────────────────┐
│   Presentation  │ ← UI (Riverpod State)
│   (Controllers) │
└────────┬────────┘
         ↓ (llama a)
┌─────────────────┐
│  Application    │ ← Casos de Uso (lógica orquestada)
│  (Use Cases)    │
└────────┬────────┘
         ↓ (usa)
┌─────────────────┐
│    Domain       │ ← Reglas de Negocio (Entities, Interfaces)
│  (Repositories  │
│   interfaces)   │
└────────┬────────┘
         ↑ (implementa)
┌─────────────────┐
│ Infrastructure  │ ← Firebase, API, DB
│ (Repository Impl)│
└─────────────────┘
```

### Ejemplo Concreto:

1. **Usuario**: Presiona botón "Finalizar" en la UI
2. **Controller**: `RespuestasController.finalizarFormulario()`
3. **Use Case**: `FinalizarFormularioUseCase.execute()`
4. **Repository Interface**: `RespuestasRepository.uploadRespuestas()`
5. **Repository Impl**: `RespuestasRepositoryImpl.uploadRespuestas()` (Firebase)
6. **Respuesta**: Vuelve por las capas hasta actualizar el estado en Riverpod

---

## 🛠️ Tecnologías Utilizadas

### **Gestión de Estado: Riverpod**
- `StateNotifierProvider`: Para estado mutable complejo
- `StreamProvider`: Para streams (ej: Firebase Auth)
- `Provider`: Para valores estáticos o computados

### **Inyección de Dependencias: GetIt**
- Registra singletons y factories
- Permite inyectar mocks para testing

### **Backend: Firebase**
- **Firebase Auth**: Autenticación
- **Cloud Firestore**: Base de datos
- **Firebase Storage**: Almacenamiento de archivos

---

## 📝 Convenciones de Nomenclatura

### **Archivos:**
- `*_entity.dart`: Entidades del dominio
- `*_dto.dart`: Data Transfer Objects
- `*_repository.dart`: Interfaces de repositorios
- `*_repository_impl.dart`: Implementaciones
- `*_usecase.dart`: Casos de uso
- `*_provider.dart`: Providers de Riverpod
- `*_controller.dart`: Controladores de UI
- `*_screen.dart`: Pantallas
- `*_widget.dart`: Widgets

### **Clases:**
- `*Entity`: Entidades del dominio
- `*DTO`: Data Transfer Objects
- `*Repository`: Interfaces
- `*RepositoryImpl`: Implementaciones
- `*UseCase`: Casos de uso
- `*Provider`: Providers de Riverpod
- `*Controller`: Controladores
- `*Screen`: Pantallas (StatefulWidget)
- `*Widget`: Widgets reutilizables

---

## 🔒 Principios de Arquitectura

### **1. Separación de Responsabilidades**
Cada capa tiene una responsabilidad clara:
- **Domain**: Reglas de negocio
- **Application**: Orquestación
- **Infrastructure**: Implementaciones técnicas
- **Presentation**: UI y estado

### **2. Inversión de Dependencias**
- Presentation depende de Application y Domain
- Application depende solo de Domain
- Infrastructure implementa interfaces de Domain

### **3. Independencia de Frameworks**
- Domain no conoce Flutter ni Firebase
- La lógica de negocio es testeable sin UI

### **4. Testabilidad**
- Use cases son fáciles de testear (mocks de repos)
- Domain tiene tests puros
- Infrastructure se testea con integración

---

## 📦 Barrel Files (Archivos de Exportación)

Cada módulo tiene archivos `.dart` que actúan como "barrel" para simplificar imports:

```dart
// En lugar de múltiples imports:
import 'package:calet/features/formulario/domain/entities/pregunta_entity.dart';
import 'package:calet/features/formulario/domain/entities/respuesta_entity.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';

// Solo un import:
import 'package:calet/features/formulario/domain/domain.dart';
```

---

## 🎓 Ejemplo Completo: Feature "Formulario"

Ver estructura completa en `lib/features/formulario/`

### **Flujo de un Caso de Uso:**

```dart
// 1. UI llama a Controller
_controller.finalizarFormulario(context, respuestasState);

// 2. Controller llama a Use Case
final useCase = FinalizarFormularioUseCase(repository: getIt<RespuestasRepository>());
await useCase.execute(userId: user.id, respuestasState: state);

// 3. Use Case llama a Repository (interface)
await _repository.uploadRespuestas(userId, state);

// 4. RepositoryImpl ejecuta lógica técnica
await _firestore.collection('users').doc(userId).set(data);
```

---

## ✅ Características Implementadas

- ✅ Clean Architecture con 4 capas claras
- ✅ Riverpod para gestión de estado
- ✅ GetIt para inyección de dependencias
- ✅ Separación Domain/Application/Infrastructure/Presentation
- ✅ Use cases para orquestación de lógica
- ✅ Barrel files para imports simplificados
- ✅ Arquitectura escalable y mantenible
- ✅ Testeable en todas las capas

---

## 📚 Referencias

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev/)
- [GetIt Package](https://pub.dev/packages/get_it)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
