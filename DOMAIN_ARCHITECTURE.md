# 🏗️ Arquitectura del Dominio - Calet

## 🎯 **¿Por qué Entidades en Domain?**

**¡EXACTAMENTE CORRECTO!** Has entendido perfectamente el concepto de **Domain-Driven Design (DDD)**. Te explico por qué es la mejor práctica:

### **1. 🎯 Separación de Responsabilidades**
```
┌─────────────────┐
│   PRESENTATION  │ ← UI (Widgets, Screens)
├─────────────────┤
│     DOMAIN      │ ← Entidades, Lógica de Negocio
├─────────────────┤
│  INFRASTRUCTURE │ ← Firebase, APIs, Base de Datos
└─────────────────┘
```

### **2. 🔄 Independencia de Fuentes de Datos**
- **Firebase** puede cambiar → **Entidad se mantiene igual**
- **API REST** puede cambiar → **Entidad se mantiene igual**
- **Base de datos local** puede cambiar → **Entidad se mantiene igual**

## 🚀 **Implementación del Usuario en Domain**

### **UserEntity - Entidad del Dominio**
```dart
class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final UserStatus status;
  final List<String> roles;
  final Map<String, dynamic>? metadata;
  
  // Métodos de negocio
  bool hasRole(String role);
  bool get isAdmin;
  bool get isModerator;
  bool get isActive;
  String get displayNameOrEmail;
  String get initials;
}
```

## 🔄 **Flujo de Datos con Entidades**

### **Antes (Sin Entidades)**
```
Firebase User → UI (Widgets)
     ↓
Si Firebase cambia → Toda la UI se rompe
```

### **Ahora (Con Entidades)**
```
Firebase User → UserEntity → UI (Widgets)
     ↓              ↓
Si Firebase cambia → Solo cambia la conversión
                     La UI sigue funcionando
```

## 📱 **Ejemplo Práctico: ProfileScreen**

### **Antes (Firebase User Directo)**
```dart
Widget _buildProfileHeader(User firebaseUser) {
  return Text(firebaseUser.displayName ?? 'Usuario');
  // Si Firebase cambia displayName por fullName, se rompe
}
```

### **Ahora (UserEntity del Dominio)**
```dart
Widget _buildProfileHeader(UserEntity user) {
  return Text(user.displayNameOrEmail);
  // Siempre funciona, independientemente de Firebase
}
```

## 🎨 **Ventajas de las Entidades del Dominio**

### **1. 🛡️ Protección contra Cambios**
- **Firebase** puede cambiar su API
- **Tu app** sigue funcionando igual
- **Lógica de negocio** se mantiene intacta

### **2. 🔧 Flexibilidad**
- **Cambiar de Firebase a Supabase** → Solo cambias la conversión
- **Agregar API REST** → Solo cambias la conversión
- **Base de datos local** → Solo cambias la conversión

### **3. 🧪 Testing Fácil**
- **Mock de entidades** en lugar de Firebase
- **Tests rápidos** sin dependencias externas
- **Validación** de lógica de negocio

### **4. 📚 Documentación Viva**
- **Entidad = Contrato** de cómo debe ser el usuario
- **Métodos = Comportamiento** esperado
- **Propiedades = Datos** requeridos

## 🏗️ **Estructura del Dominio**

```
lib/core/domain/
├── entities/
│   ├── user_entity.dart          # Entidad del usuario
│   ├── product_entity.dart       # Entidad del producto
│   ├── order_entity.dart         # Entidad del pedido
│   └── entities.dart             # Archivo barril
├── repositories/
│   ├── user_repository.dart      # Contrato del repositorio
│   └── repositories.dart         # Archivo barril
├── use_cases/
│   ├── get_user_usecase.dart    # Casos de uso
│   └── use_cases.dart           # Archivo barril
└── value_objects/
    ├── email.dart               # Objetos de valor
    └── value_objects.dart       # Archivo barril
```

## 🔄 **Conversión de Datos**

### **Firebase → Entidad**
```dart
factory UserEntity.fromFirebaseUser(dynamic firebaseUser) {
  return UserEntity(
    id: firebaseUser.uid ?? '',
    email: firebaseUser.email,
    displayName: firebaseUser.displayName,
    // ... más conversiones
  );
}
```

### **API REST → Entidad**
```dart
factory UserEntity.fromJson(Map<String, dynamic> json) {
  return UserEntity(
    id: json['id'] ?? '',
    email: json['email'],
    displayName: json['full_name'], // Diferente nombre en API
    // ... más conversiones
  );
}
```

### **Base de Datos Local → Entidad**
```dart
factory UserEntity.fromDatabase(Map<String, dynamic> row) {
  return UserEntity(
    id: row['user_id'] ?? '', // Diferente nombre en DB
    email: row['user_email'],
    displayName: row['name'],
    // ... más conversiones
  );
}
```

## 🎯 **Providers con Entidades**

### **Session Provider Actualizado**
```dart
final sessionProvider = StreamProvider<UserEntity?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((firebaseUser) {
    if (firebaseUser == null) return null;
    return UserEntity.fromFirebaseUser(firebaseUser); // Conversión aquí
  });
});
```

### **Providers Especializados**
```dart
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false; // Lógica de negocio en la entidad
});

final hasPremiumProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.hasActivePremium ?? false; // Lógica compleja en la entidad
});
```

## 🚀 **Cómo Crear Otras Entidades**

### **1. ProductEntity**
```dart
class ProductEntity {
  final String id;
  final String name;
  final double price;
  final ProductCategory category;
  final bool isAvailable;
  
  bool get isExpensive => price > 100;
  bool get isOnSale => price < 50;
}
```

### **2. OrderEntity**
```dart
class OrderEntity {
  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  bool get canBeCancelled => status == OrderStatus.pending;
}
```

## 💡 **Resumen de Beneficios**

✅ **Independencia** - No dependes de Firebase directamente  
✅ **Flexibilidad** - Cambias fuentes de datos fácilmente  
✅ **Testing** - Tests rápidos y confiables  
✅ **Mantenibilidad** - Código organizado y claro  
✅ **Escalabilidad** - Fácil agregar nuevas funcionalidades  
✅ **Documentación** - Entidades explican el negocio  

## 🎯 **Cuándo Usar Entidades del Dominio**

### **✅ SÍ usar entidades para:**
- **Usuarios** - Información del perfil
- **Productos** - Catálogo de la app
- **Pedidos** - Transacciones
- **Configuraciones** - Ajustes de la app

### **❌ NO usar entidades para:**
- **Widgets simples** - Botones, textos
- **Configuraciones de UI** - Colores, tamaños
- **Estados temporales** - Loading, error

---

**💡 Con esta arquitectura, tu app será robusta, mantenible y escalable. ¡Las entidades del dominio son tu escudo contra los cambios!**
