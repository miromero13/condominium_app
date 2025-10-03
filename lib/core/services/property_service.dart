import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../storage/local_storage.dart';
import '../models/property.dart';
import '../models/property_quote.dart';

class PropertyService {
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

  /// Obtiene la información básica de la propiedad del usuario autenticado
  Future<Property?> getMyProperty() async {
    try {
      await _setAuthTokenIfAvailable();

      final response = await _dioClient.dio.get('/api/properties/my_property/');

      if (response.statusCode == 200) {
        return Property.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener la propiedad: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getMyProperty: $e');
      rethrow;
    }
  }

  /// Obtiene toda la información del dashboard para el usuario autenticado
  Future<DashboardInfo?> getDashboardInfo() async {
    try {
      await _setAuthTokenIfAvailable();

      final response = await _dioClient.dio.get('/api/properties/dashboard_info/');

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // El backend devuelve: {"statusCode":200,"message":"...","data":{...}}
        // Necesitamos acceder a response.data['data']
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          print('Parsing data: ${responseData['data']}');
          return DashboardInfo.fromJson(responseData['data']);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener información del dashboard: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getDashboardInfo: $e');
      rethrow;
    }
  }

  /// Obtiene las cuotas del usuario autenticado
  Future<List<PropertyQuote>> getUserQuotes({String? status}) async {
    try {
      await _setAuthTokenIfAvailable();

      String url = '/api/property-quotes/';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await _dioClient.dio.get(url);

      print('Quotes Response Status Code: ${response.statusCode}');
      print('Quotes Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // El backend devuelve: {"statusCode":200,"message":"...","data":[...]}
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final quotesData = responseData['data'] as List;
          return quotesData.map((quote) => PropertyQuote.fromJson(quote)).toList();
        }
        return [];
      } else {
        throw Exception('Error al obtener las cuotas: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException getting quotes: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getUserQuotes: $e');
      rethrow;
    }
  }

  /// Obtiene las cuotas pendientes del usuario
  Future<List<PropertyQuote>> getPendingQuotes() async {
    return getUserQuotes(status: 'pending');
  }

  /// Obtiene las cuotas pagadas del usuario
  Future<List<PropertyQuote>> getPaidQuotes() async {
    return getUserQuotes(status: 'paid');
  }

  /// Obtiene todas las cuotas del usuario
  Future<List<PropertyQuote>> getAllQuotes() async {
    return getUserQuotes();
  }
}