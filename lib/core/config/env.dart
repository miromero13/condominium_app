import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';
  
  // Endpoints de autenticación
  static String get loginAdminEndpoint => '$apiUrl/api/auth/login-admin/';
  static String get loginResidentEndpoint => '$apiUrl/api/auth/login-resident/';
  static String get loginVisitorEndpoint => '$apiUrl/api/auth/login-visitor/';
  static String get checkTokenEndpoint => '$apiUrl/api/auth/check-token/';
}