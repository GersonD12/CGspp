# Sistema de Navegación Híbrido

## 🎯 **¿Por qué Dos Sistemas de Navegación?**

### **1. Navegación Automática (Riverpod)**
- **Para autenticación**: Login ↔ Home
- **Ventaja**: Sincronización perfecta con Firebase
- **Uso**: No hay que hacer nada, es automático

### **2. Navegación Manual (Navigator)**
- **Para otras pantallas**: Perfil, Configuración, Dashboard
- **Ventaja**: Control total sobre la navegación
- **Uso**: `Navigator.pushNamed(context, '/ruta')`

## 🔄 **Cómo Funciona**

### **Flujo de Autenticación (Automático)**
```
Usuario no autenticado → GoogleLoginScreen
Usuario autenticado → HomeScreen
Logout → GoogleLoginScreen
```

### **Navegación Manual (Con Navigator)**
```dart
// En cualquier widget
Navigator.pushNamed(context, '/profile');
Navigator.pushReplacementNamed(context, '/settings');
Navigator.pop(context);
```

## 📱 **Implementación Actual**

### **App Widget (Navegación Automática)**
```dart
home: session.when(
  data: (user) {
    if (user != null) return HomeScreen();
    else return GoogleLoginScreen();
  },
  // ...
)
```

### **Rutas Manuales (Navigator)**
```dart
final routes = <String, WidgetBuilder>{
  '/profile': (context) => const ProfileScreen(),
  '/settings': (context) => const SettingsScreen(),
  // ...
};
```

## 🚀 **Ejemplos de Uso**

### **Navegación a Nueva Pantalla**
```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/profile');
  },
  child: Text('Ir al Perfil'),
)
```

### **Navegación con Reemplazo**
```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/dashboard');
  },
  child: Text('Ir al Dashboard'),
)
```

### **Navegación con Argumentos**
```dart
// En la ruta
'/details': (context) => DetailsScreen(
  id: ModalRoute.of(context)!.settings.arguments as String,
),

// Al navegar
Navigator.pushNamed(context, '/details', arguments: 'user123');
```

## 🎨 **Ventajas del Sistema Híbrido**

✅ **Autenticación automática** - No hay que recordar rutas  
✅ **Navegación manual** - Control total cuando lo necesites  
✅ **Mejor UX** - Login automático, navegación intuitiva  
✅ **Mantenible** - Código claro y organizado  
✅ **Escalable** - Fácil agregar nuevas pantallas  

## 📝 **Cuándo Usar Cada Uno**

### **Usa Navegación Automática para:**
- Login/Logout
- Pantallas que dependen del estado de autenticación
- Flujos que deben sincronizarse con Firebase

### **Usa Navegación Manual para:**
- Navegación entre pantallas de la app
- Flujos de usuario específicos
- Pantallas que no dependen de autenticación

## 🔧 **Configuración**

### **1. Agregar Nueva Ruta**
```dart
// En routes.dart
'/nueva-pantalla': (context) => const NuevaPantalla(),

// En AppRoutes
static const String nuevaPantalla = '/nueva-pantalla';
```

### **2. Navegar a la Ruta**
```dart
Navigator.pushNamed(context, AppRoutes.nuevaPantalla);
```

---

**Resultado**: Lo mejor de ambos mundos - autenticación automática y navegación manual cuando la necesites.
