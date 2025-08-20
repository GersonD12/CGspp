# Guía de Testing

## 🧪 **¿Por qué son importantes los tests?**

Los tests son **ESENCIALES** para:
- ✅ Verificar que tu UI funciona correctamente
- ✅ Detectar errores antes de llegar a producción
- ✅ Facilitar refactoring y mantenimiento
- ✅ Asegurar calidad del código
- ✅ Documentar el comportamiento esperado

## 🚀 **Ejecutar Tests**

### **Tests de Widgets:**
```bash
flutter test test/widget_test.dart
```

### **Todos los Tests:**
```bash
flutter test
```

### **Tests con Coverage:**
```bash
flutter test --coverage
```

## 🔧 **Configuración de Tests**

### **1. Test Utils (`test/test_utils.dart`)**
- Proporciona `ProviderScope` para Riverpod
- Wrapper `TestApp` para tests
- Helpers para crear containers de test

### **2. Mocks (`test/mocks/firebase_mocks.dart`)**
- Simula Firebase Auth para tests
- Evita dependencias externas en tests
- Permite tests rápidos y confiables

### **3. Widget Test (`test/widget_test.dart`)**
- Test básico de la app
- Verifica que se construye sin errores
- Confirma configuración (debug banner deshabilitado)

## 📝 **Ejemplo de Test**

```dart
testWidgets('Mi Widget funciona correctamente', (WidgetTester tester) async {
  // Construir widget con ProviderScope
  await tester.pumpWidget(createTestApp(const MiWidget()));
  
  // Verificar comportamiento
  expect(find.text('Texto esperado'), findsOneWidget);
});
```

## 🎯 **Tipos de Tests Recomendados**

1. **Widget Tests**: Para componentes de UI
2. **Unit Tests**: Para lógica de negocio
3. **Integration Tests**: Para flujos completos
4. **Golden Tests**: Para verificar apariencia visual

## ⚠️ **Problemas Comunes y Soluciones**

### **Error: "No ProviderScope found"**
**Solución**: Usar `createTestApp()` que incluye `ProviderScope`

### **Error: "Firebase not initialized"**
**Solución**: Usar mocks en lugar de Firebase real

### **Error: "GetIt not configured"**
**Solución**: Los tests no necesitan GetIt, solo Riverpod

## 🚀 **Próximos Pasos**

1. **Ejecuta los tests**: `flutter test`
2. **Agrega más tests** para tus widgets
3. **Configura CI/CD** para ejecutar tests automáticamente
4. **Mantén coverage** por encima del 80%

---

**Recuerda**: Los tests son una inversión que se paga sola con el tiempo. ¡Mantén tu código confiable!
