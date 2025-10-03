import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/stripe_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // Inicializar Stripe de forma segura (sin bloquear la app si falla)
  try {
    await StripeService.initialize();
  } catch (e) {
    debugPrint('Main: Stripe no se pudo inicializar - $e');
    // La app continúa sin Stripe, se puede reintentar más tarde
  }
  
  runApp(const MyApp());
}
