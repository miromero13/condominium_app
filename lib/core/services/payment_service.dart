import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../storage/local_storage.dart';

class PaymentService {
  final DioClient _dioClient = DioClient.instance;

  Future<String?> _getAuthToken() async {
    return await LocalStorage.getToken();
  }

  Future<void> _setAuthTokenIfAvailable() async {
    final token = await _getAuthToken();
    if (token != null) {
      _dioClient.setAuthToken(token);
    }
  }

  /// Obtener configuración de Stripe
  Future<Map<String, dynamic>> getStripeConfig() async {
    try {
      await _setAuthTokenIfAvailable();

      final response = await _dioClient.dio.get('/api/stripe/config/');

      print('Stripe Config Response Status Code: ${response.statusCode}');
      print('Stripe Config Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          return responseData['data'];
        }
        return {};
      } else {
        throw Exception('Error al obtener configuración de Stripe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException getting stripe config: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getStripeConfig: $e');
      rethrow;
    }
  }

  /// Crear Payment Intent en el backend
  Future<Map<String, dynamic>> createPaymentIntent({
    required String paymentId,
    bool mobile = true,
  }) async {
    try {
      await _setAuthTokenIfAvailable();

      final requestData = {
        'payment_id': paymentId,
        'mobile': mobile,
      };

      print('Creating payment intent with data: $requestData');

      final response = await _dioClient.dio.post(
        '/api/payments/create_payment_intent/',
        data: requestData,
      );

      print('Payment Intent Response Status Code: ${response.statusCode}');
      print('Payment Intent Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          return responseData['data'];
        }
        throw Exception('Respuesta inválida del servidor');
      } else {
        final errorMessage = response.data?['message'] ?? 'Error al crear Payment Intent';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('DioException creating payment intent: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
        if (errorData['error'] != null) {
          throw Exception('Errores de validación: ${errorData['error']}');
        }
      }
      
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en createPaymentIntent: $e');
      rethrow;
    }
  }

  /// Verificar estado de un pago
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      await _setAuthTokenIfAvailable();

      final response = await _dioClient.dio.get('/api/payments/$paymentId/');

      print('Payment Status Response Status Code: ${response.statusCode}');
      print('Payment Status Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          return responseData['data'];
        }
        return {};
      } else {
        throw Exception('Error al obtener estado del pago: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException getting payment status: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getPaymentStatus: $e');
      rethrow;
    }
  }
}