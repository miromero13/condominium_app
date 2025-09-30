import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class LocalStorage {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // Guardar usuario y token
  static Future<bool> saveUser(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar el usuario como JSON
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      
      // Guardar el token
      await prefs.setString(_tokenKey, token);
      
      return true;
    } catch (e) {
      print('Error al guardar usuario: $e');
      return false;
    }
  }

  // Obtener usuario guardado
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Obtener token guardado
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  // Verificar si hay usuario guardado
  static Future<bool> hasUser() async {
    final user = await getUser();
    final token = await getToken();
    return user != null && token != null;
  }

  // Limpiar datos (logout)
  static Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      return true;
    } catch (e) {
      print('Error al limpiar datos: $e');
      return false;
    }
  }

  // Actualizar usuario (mantener token)
  static Future<bool> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      return true;
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return false;
    }
  }
}