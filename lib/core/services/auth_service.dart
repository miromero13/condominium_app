import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../config/env.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../storage/local_storage.dart';

enum UserRole { admin, resident, visitor }

class AuthService {
  final DioClient _dioClient = DioClient.instance;

  // Método principal de login que selecciona el endpoint según el rol
  Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      String endpoint;
      
      // Seleccionar endpoint según el rol
      switch (role) {
        case UserRole.admin:
          endpoint = AppConfig.loginAdminEndpoint;
          break;
        case UserRole.resident:
          endpoint = AppConfig.loginResidentEndpoint;
          break;
        case UserRole.visitor:
          endpoint = AppConfig.loginVisitorEndpoint;
          break;
      }

      final response = await _dioClient.dio.post(
        endpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
      );

      // Si el login es exitoso, guardar los datos
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data!;
        
        // Extraer token y usuario según la respuesta del backend
        String token;
        Map<String, dynamic> userData;
        
        if (role == UserRole.admin) {
          token = data['accessToken'] as String;
          userData = data['User'] as Map<String, dynamic>;
        } else {
          token = data['access'] as String;
          userData = data['user'] as Map<String, dynamic>;
        }

        final user = User.fromJson(userData);
        
        // Guardar en storage local
        await LocalStorage.saveUser(user, token);
        
        // Configurar token en DioClient para futuras peticiones
        _dioClient.setAuthToken(token);
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        message: 'Error interno: $e',
        error: e.toString(),
      );
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      // Limpiar token del DioClient
      _dioClient.clearAuthToken();
      
      // Limpiar storage local
      return await LocalStorage.clearUser();
    } catch (e) {
      print('Error en logout: $e');
      return false;
    }
  }

  // Obtener usuario actual
  Future<User?> getCurrentUser() async {
    return await LocalStorage.getUser();
  }

  // Verificar si hay usuario logueado
  Future<bool> isLoggedIn() async {
    return await LocalStorage.hasUser();
  }

  // Validar token con el backend
  Future<bool> validateToken() async {
    try {
      final token = await LocalStorage.getToken();
      if (token == null) return false;

      // Configurar token para la petición
      _dioClient.setAuthToken(token);

      final response = await _dioClient.dio.get(AppConfig.checkTokenEndpoint);
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
      );

      return apiResponse.isSuccess;
    } on DioException catch (e) {
      // Si el token es inválido, limpiar datos
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await logout();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Manejar errores de Dio
  ApiResponse<Map<String, dynamic>> _handleDioError(DioException e) {
    if (e.response != null) {
      // Error del servidor con respuesta
      try {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          e.response!.data,
        );
        return apiResponse;
      } catch (_) {
        // Si no puede parsear como ApiResponse
        return ApiResponse<Map<String, dynamic>>(
          statusCode: e.response!.statusCode ?? 500,
          message: 'Error del servidor',
          error: e.response!.data,
        );
      }
    } else {
      // Error de conexión
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 0,
        message: 'Error de conexión',
        error: e.message,
      );
    }
  }
}