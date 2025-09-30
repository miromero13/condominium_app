# Guía de Contribución - Condominium App (Flutter)

¡Gracias por tu interés en contribuir al proyecto Condominium App! Esta guía te ayudará a seguir las mejores prácticas para mantener un código limpio y un historial de cambios ordenado en nuestro proyecto Flutter.

## 📋 Proceso de Contribución

### 1. Crear una Nueva Rama

Antes de comenzar a trabajar en una nueva funcionalidad, crea una rama específica para tu tarea:

```bash
git checkout dev
git pull origin dev
git checkout -b <tipo>/<nombre-descriptivo>
```

#### Ejemplos de Nombres de Ramas Convencionales

**Features (nuevas funcionalidades):**
```
feature/login-authentication
feature/payment-management-screen
feature/resident-dashboard
feature/notification-system
feature/apartment-booking-calendar
feature/user-profile-settings
feature/dark-mode-theme
feature/responsive-navigation
feature/pdf-receipt-generation
```

**Bugfixes (corrección de errores):**
```
bugfix/mobile-keyboard-overflow
bugfix/form-validation-messages
bugfix/chart-rendering-issue
bugfix/login-redirect-loop
bugfix/listview-pagination-error
bugfix/image-loading-failure
```

**Hotfixes (correcciones urgentes):**
```
hotfix/security-token-vulnerability
hotfix/memory-leak-screens
hotfix/critical-app-crash
hotfix/payment-processing-bug
```

**Refactoring:**
```
refactor/auth-service-cleanup
refactor/dashboard-widget-optimization
refactor/api-client-restructure
refactor/state-management-improvement
```

**Styles (mejoras de UI/UX):**
```
style/improve-button-widgets
style/update-color-palette-shadcn
style/enhance-mobile-responsive
style/redesign-login-screens
```

**Documentación:**
```
docs/widget-library-guide
docs/deployment-instructions
docs/contributing-guidelines
docs/api-integration-guide
```

### 2. Commits Convencionales

Utilizamos [Conventional Commits](https://www.conventionalcommits.org/) para mantener un historial claro y generar changelogs automáticamente.

#### Estructura del Commit

```
<tipo>[ámbito opcional]: <descripción>

[cuerpo opcional]

[footer opcional]
```

#### Tipos de Commit

- **feat**: Nueva funcionalidad
- **fix**: Corrección de errores
- **docs**: Cambios en documentación
- **style**: Cambios de formato o UI/UX
- **refactor**: Refactorización de código
- **perf**: Mejoras de rendimiento
- **test**: Agregar o corregir tests
- **chore**: Tareas de mantenimiento
- **ci**: Cambios en configuración de CI/CD
- **build**: Cambios en el sistema de build

#### Ejemplos de Commits

```bash
# Nueva funcionalidad
git commit -m "feat(auth): implementar pantalla de login"
git commit -m "feat(dashboard): agregar widget de estadísticas"
git commit -m "feat(payments): crear formulario de pagos"
git commit -m "feat(ui): agregar widget de tabla reutilizable"

# Corrección de errores
git commit -m "fix(auth): corregir validación de formulario de login"
git commit -m "fix(dashboard): resolver problema de carga de datos"
git commit -m "fix(mobile): arreglar overflow en pantallas pequeñas"
git commit -m "fix(routing): corregir navegación entre pantallas"

# Mejoras de estilo/UI
git commit -m "style(buttons): mejorar diseño de botones siguiendo shadcn"
git commit -m "style(forms): actualizar estilos de inputs y labels"
git commit -m "style(responsive): mejorar diseño en tablets"
git commit -m "style(theme): implementar modo oscuro"

# Documentación
git commit -m "docs(widgets): documentar widgets reutilizables"
git commit -m "docs(readme): actualizar instrucciones de instalación"

# Refactoring
git commit -m "refactor(services): simplificar servicios de autenticación"
git commit -m "refactor(widgets): optimizar re-construcción de widgets"
git commit -m "refactor(models): mejorar estructura de modelos de datos"

# Tests
git commit -m "test(auth): agregar pruebas para widgets de login"
git commit -m "test(dashboard): implementar tests unitarios"
git commit -m "test(integration): agregar pruebas de integración"

# Configuración y herramientas
git commit -m "chore(deps): actualizar dependencias de Flutter"
git commit -m "chore(analysis): configurar reglas adicionales de analysis_options"
git commit -m "build(android): optimizar configuración de build"
git commit -m "ci(github): configurar GitHub Actions para testing"
```

### 3. Subir Cambios

Antes de subir tus cambios, asegúrate de que tu rama esté actualizada:

```bash
# Actualizar rama dev
git checkout dev
git pull origin dev

# Regresar a tu rama y hacer rebase
git checkout tu-rama
git rebase dev

# Resolver conflictos si existen
# Después del rebase exitoso, subir cambios
git push origin tu-rama
```

### 4. Crear Pull Request

1. Ve a GitHub y crea un Pull Request desde tu rama hacia `dev`
2. Usa un título descriptivo siguiendo convenciones similares a los commits
3. Completa la plantilla de PR con:
   - **Descripción**: Explica qué hace tu cambio
   - **Cambios realizados**: Lista los principales cambios
   - **Testing**: Describe cómo probaste tus cambios
   - **Screenshots**: Si aplica, incluye capturas de pantalla
   - **Responsive**: Confirma que funciona en diferentes dispositivos

#### Ejemplo de Título de PR
```
feat(dashboard): implementar widgets de estadísticas con gráficos
fix(mobile): corregir navegación responsive en dispositivos móviles
style(ui): rediseñar sistema de widgets con diseño shadcn
refactor(auth): mejorar manejo de estado de autenticación
```

### 5. Proceso de Revisión

- ✅ **Mantén tu PR sin conflictos**: Haz rebase regularmente
- ✅ **Responde a comentarios**: Atiende feedback de los revisores
- ✅ **Tests pasando**: Asegúrate de que todos los tests pasen
- ✅ **Build exitoso**: Verifica que la aplicación compile correctamente
- ✅ **Responsive design**: Prueba en diferentes tamaños de pantalla
- ✅ **Performance**: No degradar la performance de la aplicación
- ✅ **Análisis estático**: Sin warnings en `flutter analyze`

## 🔍 Checklist Antes del PR

- [ ] Mi rama está basada en `dev` actualizado
- [ ] Los commits siguen convenciones de naming
- [ ] Los tests pasan localmente (`fvm flutter test`)
- [ ] **El build se ejecuta sin errores (`fvm flutter build apk --debug`)**
- [ ] No hay warnings en análisis estático (`fvm flutter analyze`)
- [ ] No hay conflictos de merge
- [ ] He probado la funcionalidad en diferentes dispositivos
- [ ] El diseño es responsive (móvil, tablet)
- [ ] La documentación está actualizada (si aplica)
- [ ] No incluyo archivos de configuración personal
- [ ] Las imágenes están optimizadas
- [ ] Los widgets siguen la estructura del proyecto

## 🎨 Estándares de Código Flutter

### Estructura de Widgets
```dart
// Importaciones en orden:
// 1. Flutter y material
// 2. Paquetes externos
// 3. Archivos internos del proyecto
// 4. Modelos y tipos
// 5. Widgets y utilidades

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/services/auth_service.dart';
import '../models/user.dart';
import '../../widgets/common_widgets.dart';

class MyWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;

  const MyWidget({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Variables de estado primero
  bool _isLoading = false;
  
  // Métodos lifecycle
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  // Métodos privados
  void _initialize() {
    // lógica de inicialización
  }
  
  void _handlePress() {
    // lógica del evento
  }
  
  // Build method al final
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    return Container(
      // contenido del widget
    );
  }
}
```

### Naming Conventions
- **Widgets**: PascalCase (`UserProfile`, `DashboardCard`)
- **Archivos de widgets**: snake_case (`user_profile.dart`)
- **Métodos privados**: camelCase con prefijo `_` (`_handleLogin`, `_buildUserCard`)
- **Variables**: camelCase (`userName`, `isLoading`)
- **Constantes**: camelCase para variables, UPPER_SNAKE_CASE para constantes globales
- **Modelos**: PascalCase (`User`, `PaymentMethod`)

### Estructura de Archivos
```dart
// Para archivos de modelos
class User {
  final int id;
  final String name;
  
  const User({required this.id, required this.name});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

## 🚨 Importantes

1. **Nunca hagas push directamente a `main` o `dev`**
2. **Siempre crea una rama específica para tu trabajo**
3. **Mantén tus commits pequeños y enfocados**
4. **Haz rebase en lugar de merge para mantener un historial limpio**
5. **Espera la aprobación antes de hacer merge de tu PR**
6. **Testa tu código en múltiples navegadores**
7. **Verifica la responsividad en diferentes dispositivos**

## 🛠️ Comandos Útiles

```bash
# Desarrollo
fvm flutter run              # Iniciar app en modo debug
fvm flutter run --release    # Iniciar app en modo release  
fvm flutter hot-restart      # Hot restart completo

# Testing
fvm flutter test             # Ejecutar tests unitarios
fvm flutter test --coverage # Tests con cobertura
fvm flutter test test/features/auth/ # Tests específicos

# Análisis y calidad de código
fvm flutter analyze          # Análisis estático del código
fvm flutter doctor           # Verificar instalación de Flutter
fvm flutter clean            # Limpiar caché de build

# Build y deployment
fvm flutter build apk        # Build para Android (APK)
fvm flutter build appbundle  # Build para Android (AAB)
fvm flutter build ios        # Build para iOS
fvm flutter build web        # Build para Web

# Dependencias
fvm flutter pub get         # Instalar dependencias
fvm flutter pub upgrade     # Actualizar dependencias
fvm flutter pub deps        # Ver dependencias
```

## 🎯 Performance y Best Practices

- **Widget Optimization**: Usa `const` constructors cuando sea posible
- **State Management**: Minimiza llamadas a `setState()` y usa providers cuando sea necesario
- **Image Optimization**: Usa `Image.asset` para imágenes locales y maneja loading states
- **List Performance**: Usa `ListView.builder` para listas largas
- **Memory Management**: Dispose controllers y listeners en `dispose()`
- **Build Methods**: Mantén el método `build` simple y divide en widgets más pequeños
- **API Calls**: Maneja estados de loading, error y éxito apropiadamente

### Ejemplos de Optimización

```dart
// ✅ Buena práctica - const constructor
const MyWidget({super.key, required this.title});

// ✅ Buena práctica - dispose de recursos
@override
void dispose() {
  _controller.dispose();
  _subscription?.cancel();
  super.dispose();
}

// ✅ Buena práctica - ListView.builder para listas largas
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)

// ❌ Mala práctica - crear widgets en build
Widget build(BuildContext context) {
  return Column(
    children: [
      for (var item in items) Container(...), // Evitar esto
    ],
  );
}
```

---

¿Tienes alguna duda sobre el proceso de contribución? No dudes en contactar al equipo de desarrollo.