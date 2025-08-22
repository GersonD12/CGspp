# 🗺️ Diagrama de Flujo del Proyecto - Calet

## 📱 **Flujo Principal de la Aplicación**

```
┌─────────────────┐
│   main.dart     │ ← Punto de entrada
│                 │
│ ProviderScope   │ ← Envuelve toda la app con Riverpod
│   + setupInjection() │ ← Configura GetIt
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│   App Widget    │ ← Navegación automática basada en autenticación
│                 │
│ sessionProvider │ ← Escucha cambios de Firebase Auth
│   ↓             │
│ ┌─────────────┐ │
│ │ No Auth    │ │ → GoogleLoginScreen
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ Auth OK    │ │ → HomeScreen
│ └─────────────┘ │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│  Navegación     │ ← Manual con Navigator.pushNamed()
│   Manual        │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ Pantallas       │ ← Protegidas con ProtectedScreenState
│ Protegidas      │
└─────────────────┘
```

## 🔐 **Flujo de Autenticación (Automático)**

```
┌─────────────────┐
│ Usuario Abre   │
│    la App      │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ sessionProvider │ ← Escucha Firebase Auth
│   ↓             │
│ ┌─────────────┐ │
│ │ Loading     │ │ → CircularProgressIndicator
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ No User     │ │ → GoogleLoginScreen
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ User OK     │ │ → HomeScreen
│ └─────────────┘ │
└─────────────────┘
```

## 🚀 **Flujo de Login**

```
┌─────────────────┐
│ GoogleLoginScreen│
│                 │
│ ElevatedButton  │ ← "Continuar con Google"
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ GoogleAuthService│
│ .signInWithGoogle()│
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ Firebase Auth   │ ← Actualiza estado
│   ↓             │
│ UserCredential  │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ sessionProvider │ ← Detecta cambio automáticamente
│   ↓             │
│ User != null    │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ App Widget      │ ← Navegación automática
│   ↓             │
│ HomeScreen      │ ← Muestra pantalla principal
└─────────────────┘
```

## 🏠 **Flujo de HomeScreen**

```
┌─────────────────┐
│   HomeScreen    │ ← ConsumerWidget
│                 │
│ ┌─────────────┐ │
│ │ AppBar      │ │
│ │ Actions:    │ │
│ │ ├─ Profile  │ │ ← Navigator.pushNamed('/profile')
│ │ └─ Logout   │ │ ← GoogleAuthService.signOut()
│ └─────────────┘ │
│                 │
│ ┌─────────────┐ │
│ │ Body        │ │
│ │ ├─ Avatar   │ │
│ │ ├─ Info     │ │
│ │ └─ Botones  │ │ ← Navegación manual
│ └─────────────┘ │
└─────────────────┘
```

## 🔒 **Flujo de Pantallas Protegidas**

```
┌─────────────────┐
│ Navigator.pushNamed()│
│   ('/profile')  │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│  ProfileScreen  │ ← ProtectedScreenStatefulWidget
│                 │
│ ┌─────────────┐ │
│ │ State       │ │
│ │ ↓           │ │
│ │ ProtectedScreenState│
│ └─────────────┘ │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ ProtectedScreenState│
│                 │
│ sessionProvider │ ← Verifica autenticación
│   ↓             │
│ ┌─────────────┐ │
│ │ Loading     │ │ → _buildLoadingScreen()
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ No Auth     │ │ → _buildUnauthenticatedScreen()
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ Auth OK     │ │ → buildProtectedContent()
│ └─────────────┘ │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ buildProtectedContent()│
│                 │
│ VerticalViewStandard│ ← UI estándar
│   ↓             │
│ ┌─────────────┐ │
│ │ AppBar      │ │
│ │ ├─ Title    │ │
│ │ ├─ Actions  │ │
│ │ └─ Back     │ │
│ └─────────────┘ │
│ ┌─────────────┐ │
│ │ Body        │ │
│ │ └─ Child    │ │ ← Tu contenido personalizado
│ └─────────────┘ │
└─────────────────┘
```

## 🏗️ **Arquitectura de Componentes**

```
┌─────────────────────────────────────────────────────────────┐
│                        CORE                                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Providers     │  │       DI        │  │  Protected  │ │
│  │                 │  │                 │  │   Widget    │ │
│  │ ├─ config       │  │ ├─ GetIt        │  │             │ │
│  │ ├─ session      │  │ ├─ Services     │  │             │ │
│  │ └─ auth         │  │ └─ Repositories │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      SHARED                                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Widgets       │  │   Base Widgets  │  │   Utils     │ │
│  │                 │  │                 │  │             │ │
│  │ ├─ VerticalView │  │ ├─ Consumer     │  │ ├─ Test     │ │
│  │ ├─ Protected    │  │ ├─ Stateful     │  │ └─ Helpers  │ │
│  │ └─ Standard     │  │ └─ Stateless    │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      FEATURES                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │      AUTH       │  │    PAGINA2      │  │   FUTURE    │ │
│  │                 │  │                 │  │  FEATURES   │ │
│  │ ├─ Screens      │  │ ├─ Screens      │  │             │ │
│  │ ├─ Services     │  │ ├─ Services     │  │             │ │
│  │ ├─ Repositories │  │ ├─ Repositories │  │             │ │
│  │ └─ Domain       │  │ └─ Domain       │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 **Flujo de Navegación Completo**

```
┌─────────────────┐
│   main.dart     │
│                 │
│ ProviderScope   │
│   + App         │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│   App Widget    │
│                 │
│ sessionProvider │
│   ↓             │
│ ┌─────────────┐ │
│ │ No Auth     │ │
│ └─────────────┘ │
│       │         │
│       ▼         │
│ ┌─────────────┐ │
│ │GoogleLogin  │ │
│ │  Screen     │ │
│ └─────────────┘ │
│       │         │
│       ▼         │
│ ┌─────────────┐ │
│ │ Login OK    │ │
│ └─────────────┘ │
│       │         │
│       ▼         │
│ ┌─────────────┐ │
│ │ HomeScreen  │ │
│ │             │ │
│ │ ├─ Profile  │ │ ← Navigator.pushNamed('/profile')
│ │ └─ Logout   │ │ ← GoogleAuthService.signOut()
│ └─────────────┘ │
│       │         │
│       ▼         │
│ ┌─────────────┐ │
│ │ProfileScreen│ │ ← ProtectedScreenState
│ │             │ │
│ │ ├─ Security │ │
│ │ ├─ UI       │ │
│ │ └─ Back     │ │ ← Navigator.pop()
│ └─────────────┘ │
│       │         │
│       ▼         │
│ ┌─────────────┐ │
│ │ HomeScreen  │ │ ← Regresa automáticamente
│ └─────────────┘ │
└─────────────────┘
```

## 🛠️ **Guía para Crear Nuevos Widgets**

### **1. Widget Simple (Sin Autenticación)**
```dart
class MiWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Mi Widget'),
    );
  }
}
```

### **2. Widget con Riverpod (Sin Autenticación)**
```dart
class MiWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(miProvider);
    return Container(
      child: Text(data),
    );
  }
}
```

### **3. Widget con Estado (Sin Autenticación)**
```dart
class MiWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MiWidget> createState() => _MiWidgetState();
}

class _MiWidgetState extends ConsumerState<MiWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Mi Widget con Estado'),
    );
  }
}
```

### **4. Pantalla Protegida (Con Autenticación)**
```dart
class MiPantalla extends ProtectedScreenStatefulWidget {
  @override
  ProtectedScreenState<MiPantalla> createState() => _MiPantallaState();
}

class _MiPantallaState extends ProtectedScreenState<MiPantalla> {
  @override
  Widget buildProtectedContent(BuildContext context, dynamic user) {
    return VerticalViewStandard(
      title: 'Mi Pantalla',
      headerColor: Colors.blue,
      child: MiContenido(),
    );
  }
}
```

## 📍 **Guía para Implementar Nuevas Funcionalidades**

### **1. Agregar Nuevo Provider**
```dart
// En lib/core/providers/
final miProvider = StateProvider<String>((ref) => 'Valor inicial');

// En lib/core/providers/providers.dart
export 'mi_provider.dart';
```

### **2. Agregar Nuevo Service**
```dart
// En lib/features/mi_feature/service/
class MiService {
  static final instance = MiService._();
  MiService._();
  
  Future<void> miMetodo() async {
    // Implementación
  }
}

// En lib/core/di/injection.dart
getIt.registerLazySingleton<MiService>(() => MiService.instance);
```

### **3. Agregar Nueva Pantalla**
```dart
// En lib/features/mi_feature/screen/
class MiPantalla extends ProtectedScreenStatefulWidget {
  // Implementación
}

// En lib/app/routes/routes.dart
'/mi-pantalla': (context) => const MiPantalla(),

// En AppRoutes
static const String miPantalla = '/mi-pantalla';
```

### **4. Navegar a Nueva Pantalla**
```dart
Navigator.pushNamed(context, AppRoutes.miPantalla);
```

## 🎯 **Resumen de Flujos Clave**

| **Acción** | **Flujo** | **Archivo** |
|------------|-----------|-------------|
| **App Inicia** | `main.dart` → `ProviderScope` → `App` | `main.dart` |
| **Login** | `GoogleLoginScreen` → `GoogleAuthService` → `Firebase` → `sessionProvider` → `HomeScreen` | `google_login_screen.dart` |
| **Navegación Manual** | `Navigator.pushNamed(context, '/ruta')` → `routes.dart` → `Pantalla` | `routes.dart` |
| **Pantalla Protegida** | `ProtectedScreenState` → `sessionProvider` → `buildProtectedContent()` | `protected_screen_state.dart` |
| **UI Estándar** | `VerticalViewStandard` → `AppBar` + `Body` | `vertical_view_standard.dart` |
| **Logout** | `GoogleAuthService.signOut()` → `sessionProvider` → `GoogleLoginScreen` | `google_auth.dart` |

---

**💡 Con este diagrama, podrás entender rápidamente cómo implementar cualquier nueva funcionalidad siguiendo los patrones establecidos.**
