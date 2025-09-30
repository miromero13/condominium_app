import 'package:dio/dio.dart';
import 'env.dart';

class DioClient {
  late Dio _dio;

  DioClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptors para logging y manejo de tokens
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Interceptor para agregar token automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Aquí puedes agregar el token automáticamente
        // final token = await LocalStorage.getToken();
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        handler.next(options);
      },
    ));
  }

  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  Dio get dio => _dio;

  // Método para actualizar el token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Método para limpiar el token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}