import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../storage/local_storage.dart';
import '../models/common_area.dart';

class CommonAreaService {
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

  /// Obtiene todas las áreas comunes disponibles
  Future<List<CommonArea>> getAllCommonAreas({bool? activeOnly, bool? reservableOnly}) async {
    try {
      await _setAuthTokenIfAvailable();

      String url = '/api/common-areas/';
      List<String> params = [];
      
      if (activeOnly == true) {
        params.add('active_only=true');
      }
      if (reservableOnly == true) {
        params.add('reservable_only=true');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await _dioClient.dio.get(url);

      print('Common Areas Response Status Code: ${response.statusCode}');
      print('Common Areas Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // El backend devuelve: {"statusCode":200,"message":"...","data":[...]}
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final areasData = responseData['data'] as List;
          return areasData.map((area) => CommonArea.fromJson(area)).toList();
        }
        return [];
      } else {
        throw Exception('Error al obtener las áreas comunes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException getting common areas: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getAllCommonAreas: $e');
      rethrow;
    }
  }

  /// Obtiene una área común específica por ID
  Future<CommonArea?> getCommonAreaById(String id) async {
    try {
      await _setAuthTokenIfAvailable();

      final response = await _dioClient.dio.get('/api/common-areas/$id/');

      print('Common Area Detail Response Status Code: ${response.statusCode}');
      print('Common Area Detail Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          return CommonArea.fromJson(responseData['data']);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener el área común: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException getting common area detail: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getCommonAreaById: $e');
      rethrow;
    }
  }

  /// Obtiene las reglas de un área común específica
  Future<List<CommonAreaRule>> getCommonAreaRules(String commonAreaId) async {
    try {
      await _setAuthTokenIfAvailable();

      final response = await _dioClient.dio.get('/api/common-area-rules/?common_area_id=$commonAreaId');

      print('Common Area Rules Response Status Code: ${response.statusCode}');
      print('Common Area Rules Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final rulesData = responseData['data'] as List;
          return rulesData.map((rule) => CommonAreaRule.fromJson(rule)).toList();
        }
        return [];
      } else {
        throw Exception('Error al obtener las reglas: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException getting common area rules: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getCommonAreaRules: $e');
      rethrow;
    }
  }

  /// Obtiene las reservas de un área común específica
  Future<List<Reservation>> getCommonAreaReservations(String commonAreaId, {String? status}) async {
    try {
      await _setAuthTokenIfAvailable();

      String url = '/api/reservations/?common_area_id=$commonAreaId';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await _dioClient.dio.get(url);

      print('Common Area Reservations Response Status Code: ${response.statusCode}');
      print('Common Area Reservations Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final reservationsData = responseData['data'] as List;
          return reservationsData.map((reservation) => Reservation.fromJson(reservation)).toList();
        }
        return [];
      } else {
        throw Exception('Error al obtener las reservas: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException getting common area reservations: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        await LocalStorage.clearUser();
        throw Exception('Sesión expirada');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error en getCommonAreaReservations: $e');
      rethrow;
    }
  }

  /// Crear una nueva reserva
  Future<Reservation> createReservation({
    required String commonAreaId,
    required DateTime reservationDate,
    required String startTime,
    required String endTime,
    String? purpose,
    int estimatedAttendees = 1,
  }) async {
    try {
      await _setAuthTokenIfAvailable();

      final requestData = {
        'common_area_id': commonAreaId,
        'reservation_date': '${reservationDate.year}-${reservationDate.month.toString().padLeft(2, '0')}-${reservationDate.day.toString().padLeft(2, '0')}',
        'start_time': startTime,
        'end_time': endTime,
        'purpose': purpose,
        'estimated_attendees': estimatedAttendees,
      };

      print('Creating reservation with data: $requestData');

      final response = await _dioClient.dio.post(
        '/api/reservations/',
        data: requestData,
      );

      print('Create Reservation Response Status Code: ${response.statusCode}');
      print('Create Reservation Response Data: ${response.data}');

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          return Reservation.fromJson(responseData['data']);
        }
        throw Exception('Respuesta inválida del servidor');
      } else {
        final errorMessage = response.data?['message'] ?? 'Error al crear la reserva';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('DioException creating reservation: ${e.response?.statusCode} - ${e.message}');
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
      print('Error en createReservation: $e');
      rethrow;
    }
  }

  /// Obtiene solo las áreas comunes activas y reservables
  Future<List<CommonArea>> getAvailableCommonAreas() async {
    return getAllCommonAreas(activeOnly: true, reservableOnly: true);
  }
}