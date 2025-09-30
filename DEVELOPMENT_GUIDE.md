# 🏗️ Guía de Desarrollo - Condominium App

Esta guía te ayudará a entender la estructura del proyecto y cómo agregar nuevas funcionalidades o vistas de manera consistente.

## 📁 Estructura del Proyecto

```
lib/
├── app.dart                    # Configuración principal de la app
├── main.dart                   # Punto de entrada
├── core/                       # Funcionalidades centrales
│   ├── config/                 # Configuraciones
│   │   ├── dio_client.dart     # Cliente HTTP
│   │   └── env.dart           # Variables de entorno
│   ├── models/                 # Modelos de datos globales
│   │   ├── api_response.dart   # Respuesta de API
│   │   └── user.dart          # Modelo de usuario
│   └── services/              # Servicios globales
│       ├── auth_service.dart   # Servicio de autenticación
│       └── local_storage.dart  # Almacenamiento local
├── features/                   # Características/Módulos
│   ├── auth/                   # Módulo de autenticación
│   │   ├── login_form_screen.dart
│   │   └── user_type_selection_screen.dart
│   ├── home/                   # Módulo de inicio
│   │   ├── home_screen.dart
│   │   └── layout.dart
│   ├── roles/                  # Módulos por rol
│   │   ├── admin/
│   │   ├── resident/
│   │   ├── visitor/
│   │   └── guest/
│   └── splash/                 # Pantalla de carga
│       └── splash_screen.dart
├── widgets/                    # Widgets reutilizables
│   └── common_widgets.dart     # Widgets comunes (ShadcnButton, etc.)
└── test/                      # Pruebas unitarias
```

## 🎯 Cómo Agregar Nuevas Funcionalidades

### 1. Crear un Nuevo Módulo/Feature

Cuando necesites agregar una nueva funcionalidad completa (ej: gestión de pagos, reservas, etc.):

```bash
# Crear estructura del módulo
mkdir -p lib/features/payments
mkdir -p lib/features/payments/models
mkdir -p lib/features/payments/services
mkdir -p lib/features/payments/widgets
```

#### Estructura recomendada para un módulo:
```
lib/features/payments/
├── models/
│   ├── payment.dart           # Modelo de datos
│   └── payment_method.dart    # Modelos relacionados
├── services/
│   └── payment_service.dart   # Lógica de negocio/API
├── widgets/
│   ├── payment_card.dart      # Widgets específicos
│   └── payment_form.dart
├── payments_screen.dart       # Pantalla principal
├── payment_details_screen.dart
└── payment_history_screen.dart
```

### 2. Crear un Nuevo Screen (Pantalla)

#### Paso 1: Crear el archivo del screen
```dart
// lib/features/payments/payments_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import 'services/payment_service.dart';
import 'models/payment.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final payments = await _paymentService.getPayments();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Manejar error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBgPrimary,    // #FFFFFF
      appBar: AppBar(
        title: const Text('Pagos'),
        backgroundColor: lightBgPrimary,  // #FFFFFF
        foregroundColor: lightTextPrimary, // #09090B
        // Usar el estilo shadcn establecido
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPaymentsList(),
    );
  }

  Widget _buildPaymentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        return PaymentCard(payment: _payments[index]);
      },
    );
  }
}
```

#### Paso 2: Agregar la ruta en app.dart
```dart
// lib/app.dart
routes: {
  '/splash': (context) => const SplashScreen(),
  '/login': (context) => const UserTypeSelectionScreen(),
  '/home': (context) => const HomeScreen(),
  '/payments': (context) => const PaymentsScreen(), // Nueva ruta
},
```

### 3. Crear un Nuevo Modelo

#### Paso 1: Definir el modelo
```dart
// lib/features/payments/models/payment.dart
class Payment {
  final int id;
  final String description;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;
  final String type;

  Payment({
    required this.id,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.type,
  });

  // Serialización manual (siguiendo el patrón del proyecto)
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date'] as String),
      paidDate: json['paid_date'] != null 
          ? DateTime.parse(json['paid_date'] as String) 
          : null,
      status: json['status'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'status': status,
      'type': type,
    };
  }

  // Getters útiles
  bool get isPaid => status == 'paid';
  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);
  
  String get statusDisplayName {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'paid': return 'Pagado';
      case 'overdue': return 'Vencido';
      default: return status;
    }
  }
}
```

### 4. Crear un Nuevo Servicio

#### Paso 1: Definir el servicio
```dart
// lib/features/payments/services/payment_service.dart
import '../../../core/config/dio_client.dart';
import '../../../core/models/api_response.dart';
import '../models/payment.dart';

class PaymentService {
  final DioClient _dioClient = DioClient.instance;

  Future<List<Payment>> getPayments() async {
    try {
      final response = await _dioClient.get('/payments/');
      final apiResponse = ApiResponse.fromJson(response.data);
      
      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> paymentsList = apiResponse.data as List<dynamic>;
        return paymentsList
            .map((json) => Payment.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception(apiResponse.message ?? 'Error al cargar pagos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Payment> getPaymentDetails(int paymentId) async {
    try {
      final response = await _dioClient.get('/payments/$paymentId/');
      final apiResponse = ApiResponse.fromJson(response.data);
      
      if (apiResponse.success && apiResponse.data != null) {
        return Payment.fromJson(apiResponse.data as Map<String, dynamic>);
      }
      
      throw Exception(apiResponse.message ?? 'Error al cargar pago');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> payPayment(int paymentId, Map<String, dynamic> paymentData) async {
    try {
      final response = await _dioClient.post(
        '/payments/$paymentId/pay/',
        data: paymentData,
      );
      final apiResponse = ApiResponse.fromJson(response.data);
      return apiResponse.success;
    } catch (e) {
      throw Exception('Error al procesar pago: $e');
    }
  }
}
```

### 5. Crear un Widget Reutilizable

#### Paso 1: Crear el widget siguiendo el diseño shadcn
```dart
// lib/features/payments/widgets/payment_card.dart
import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../../../widgets/common_widgets.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: lightBgPrimary,            // #FFFFFF
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: lightBorder,        // #e4e4e7
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        payment.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: lightTextPrimary,   // #09090B
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${payment.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: lightAction,          // #18181B
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Vence: ${_formatDate(payment.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: lightTextSecondary,  // #71717A
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color bgColor;
    Color textColor;
    
    switch (payment.status) {
      case 'paid':
        bgColor = success.withOpacity(0.1);         // #6bd968 con 10% opacidad
        textColor = success;                        // #6bd968
        break;
      case 'overdue':
        bgColor = danger.withOpacity(0.1);          // #f44250 con 10% opacidad
        textColor = danger;                         // #f44250
        break;
      case 'processing':
        bgColor = process.withOpacity(0.1);         // #3992ff con 10% opacidad
        textColor = process;                        // #3992ff
        break;
      default: // pending
        bgColor = warning.withOpacity(0.1);         // #fecc1b con 10% opacidad
        textColor = warning;                        // #fecc1b
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        payment.statusDisplayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

### 6. Integrar con el Layout Principal

Si necesitas agregar una nueva sección al navigation drawer o bottom navigation:

#### Paso 1: Actualizar el layout.dart
```dart
// lib/features/home/layout.dart
// Agregar en la función _initializeRoleContent()

case 'owner':
case 'resident':
  _roleWidgets = {
    'resident': const RoleResident(),
    'payments': const PaymentsScreen(), // Nueva pantalla
    'services': const Center(child: Text('Servicios\n(Próximamente)')),
  };
  _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Inicio',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.payment),
      label: 'Pagos',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.room_service),
      label: 'Extras',
    ),
  ];
  break;
```

## 🎨 Guía de Estilos - Sistema de Diseño Shadcn

### Colores Principales
```dart
// Colores de estado
const Color danger = Color(0xFFF44250);              // #f44250
const Color success = Color(0xFF6BD968);             // #6bd968
const Color warning = Color(0xFFFECC1B);             // #fecc1b
const Color process = Color(0xFF3992FF);             // #3992ff

// Modo claro (Light Mode)
const Color lightTextPrimary = Color(0xFF09090B);    // #09090B
const Color lightTextSecondary = Color(0xFF71717A);  // #71717A
const Color lightBgPrimary = Color(0xFFFFFFFF);      // #FFFFFF
const Color lightBgSecondary = Color(0xFFF4F4F5);    // #f4f4f5
const Color lightBorder = Color(0xFFE4E4E7);         // #e4e4e7
const Color lightAction = Color(0xFF18181B);         // #18181B
const Color lightActionHover = Color(0xFF18181BE6);  // #18181be6

// Modo oscuro (Dark Mode)
const Color darkTextPrimary = Color(0xFFFAFAFA);     // #FAFAFA
const Color darkTextSecondary = Color(0xFFA1A1AA);   // #A1A1AA
const Color darkBgPrimary = Color(0xFF09090B);       // #09090b
const Color darkBgSecondary = Color(0xFF151518);     // #151518
const Color darkBorder = Color(0x33B8C0CC);          // #b8c0cc33
const Color darkAction = Color(0xFFFAFAFA);          // #FAFAFA
const Color darkActionHover = Color(0xFFFAFAFAE6);   // #fafafae6
```

### Widgets Reutilizables

#### ShadcnButton
```dart
ShadcnButton(
  text: 'Pagar Ahora',
  onPressed: () => _processPayment(),
  backgroundColor: lightAction,  // #18181B
  icon: Icons.payment,
  width: double.infinity,
  height: 48,
)
```

#### ShadcnTextField
```dart
ShadcnTextField(
  controller: _amountController,
  label: 'Monto',
  hint: 'Ingresa el monto',
  keyboardType: TextInputType.number,
  prefixIcon: Icons.attach_money,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Este campo es requerido';
    }
    return null;
  },
)
```

### Uso de Colores por Contexto

#### Estados de Botones
```dart
// Botón primario
backgroundColor: lightAction,        // #18181B
hoverColor: lightActionHover,        // #18181be6

// Botón de éxito
backgroundColor: success,            // #6bd968

// Botón de peligro
backgroundColor: danger,             // #f44250

// Botón de advertencia
backgroundColor: warning,            // #fecc1b

// Botón de proceso
backgroundColor: process,            // #3992ff
```

#### Colores de Estado para Chips/Tags
```dart
// Pagado
bgColor: success.withOpacity(0.1);   // #6bd968 con 10% opacidad
textColor: success;                  // #6bd968

// Vencido
bgColor: danger.withOpacity(0.1);    // #f44250 con 10% opacidad
textColor: danger;                   // #f44250

// Pendiente
bgColor: warning.withOpacity(0.1);   // #fecc1b con 10% opacidad
textColor: warning;                  // #fecc1b

// En proceso
bgColor: process.withOpacity(0.1);   // #3992ff con 10% opacidad
textColor: process;                  // #3992ff
```

## 🧪 Testing

### Crear Tests para un Nuevo Widget
```dart
// test/features/payments/widgets/payment_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:condominium_app/features/payments/widgets/payment_card.dart';
import 'package:condominium_app/features/payments/models/payment.dart';

void main() {
  group('PaymentCard Widget Tests', () {
    late Payment testPayment;

    setUp(() {
      testPayment = Payment(
        id: 1,
        description: 'Cuota de administración',
        amount: 150.0,
        dueDate: DateTime.now().add(const Duration(days: 10)),
        status: 'pending',
        type: 'monthly',
      );
    });

    testWidgets('displays payment information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentCard(payment: testPayment),
          ),
        ),
      );

      expect(find.text('Cuota de administración'), findsOneWidget);
      expect(find.text('\$150.00'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentCard(
              payment: testPayment,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PaymentCard));
      expect(tapped, isTrue);
    });
  });
}
```

## 📝 Checklist para Nuevas Funcionalidades

- [ ] **Estructura**: ¿Sigue la estructura de carpetas establecida?
- [ ] **Naming**: ¿Los archivos y clases siguen las convenciones de naming?
- [ ] **Modelos**: ¿Los modelos tienen serialización manual (`fromJson`/`toJson`)?
- [ ] **Servicios**: ¿El servicio maneja errores correctamente?
- [ ] **UI**: ¿Sigue el sistema de diseño shadcn establecido?
- [ ] **Responsive**: ¿Funciona en diferentes tamaños de pantalla?
- [ ] **Loading States**: ¿Maneja estados de carga y error?
- [ ] **Navigation**: ¿Las rutas están correctamente configuradas?
- [ ] **Tests**: ¿Incluye tests unitarios para widgets/servicios?
- [ ] **Performance**: ¿No causa re-renderizados innecesarios?

## 🚀 Comandos Útiles

```bash
# Desarrollo
fvm flutter run              # Ejecutar en modo debug
fvm flutter run --release    # Ejecutar en modo release
fvm flutter hot-reload       # Hot reload manual

# Testing
fvm flutter test             # Ejecutar todos los tests
fvm flutter test test/features/payments/  # Tests específicos
fvm flutter test --coverage  # Tests con cobertura

# Análisis
fvm flutter analyze          # Análisis estático
fvm flutter doctor           # Verificar instalación
fvm flutter clean            # Limpiar build cache

# Build
fvm flutter build apk        # Build para Android
fvm flutter build ios        # Build para iOS
fvm flutter build web        # Build para Web
```

## 🔧 Debugging

### Debugging Tips
1. **Flutter Inspector**: Usa el inspector para examinar el widget tree
2. **Debug Console**: Usa `print()` o `debugPrint()` para logging
3. **Breakpoints**: Configura breakpoints en VS Code
4. **Widget Rebuild**: Usa `flutter run` con hot reload para iteración rápida

### Problemas Comunes
- **Overflow**: Usa `Expanded`, `Flexible`, o `SingleChildScrollView`
- **State Management**: Asegúrate de llamar `setState()` al actualizar estado
- **Navigation**: Verifica que las rutas estén definidas en `app.dart`
- **API Calls**: Maneja excepciones y estados de loading

---

Esta guía debe ayudarte a mantener consistencia en el desarrollo. ¡Siempre busca reutilizar componentes existentes antes de crear nuevos!