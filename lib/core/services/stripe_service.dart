import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeService {
  static bool _isInitialized = false;
  
  /// Inicializar Stripe de forma segura
  static Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;
      
      final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
      if (publishableKey == null || publishableKey.isEmpty) {
        debugPrint('StripeService: STRIPE_PUBLISHABLE_KEY no encontrada en .env');
        return false;
      }
      
      // Configurar Stripe
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
      
      _isInitialized = true;
      debugPrint('StripeService: Inicializado correctamente');
      return true;
    } catch (e) {
      debugPrint('StripeService: Error al inicializar - $e');
      return false;
    }
  }
  
  /// Verificar si Stripe está inicializado
  static bool get isInitialized => _isInitialized;
  
  /// Reintentar inicialización si falló anteriormente
  static Future<bool> retryInitialization() async {
    _isInitialized = false;
    return await initialize();
  }
}