import '../config/dio_client.dart';
import '../config/env.dart';
import '../models/api_response.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final String priority;
  final String userId;
  final String userName;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.userId,
    required this.userName,
    this.completedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      priority: json['priority'],
      userId: json['user'],
      userName: json['user_info']['name'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'in_progress':
        return 'En Progreso';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 'low':
        return 'Baja';
      case 'medium':
        return 'Media';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return priority;
    }
  }

  bool get isOverdue {
    return dueDate.isBefore(DateTime.now()) && 
           status != 'completed' && 
           status != 'cancelled';
  }
}

class TaskService {
  final DioClient _dioClient = DioClient.instance;

  // Obtener todas las tareas (solo para admin)
  Future<ApiResponse<List<Task>>> getAllTasks({
    int? limit,
    int? offset,
    String? status,
    String? priority,
    String? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (userId != null) queryParams['user_id'] = userId;

      final response = await _dioClient.dio.get(
        '${AppConfig.apiUrl}/api/user/tasks/',
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final List<dynamic> tasksJson = apiResponse.data!['results'] ?? [];
        final tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
        
        return ApiResponse<List<Task>>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          data: tasks,
        );
      } else {
        return ApiResponse<List<Task>>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          error: apiResponse.error,
        );
      }
    } catch (e) {
      return ApiResponse<List<Task>>(
        statusCode: 500,
        message: 'Error al obtener tareas',
        error: e.toString(),
      );
    }
  }

  // Obtener mis tareas
  Future<ApiResponse<List<Task>>> getMyTasks({
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _dioClient.dio.get(
        '${AppConfig.apiUrl}/api/user/tasks/my_tasks/',
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final tasks = apiResponse.data!.map((json) => Task.fromJson(json)).toList();
        
        return ApiResponse<List<Task>>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          data: tasks,
        );
      } else {
        return ApiResponse<List<Task>>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          error: apiResponse.error,
        );
      }
    } catch (e) {
      return ApiResponse<List<Task>>(
        statusCode: 500,
        message: 'Error al obtener mis tareas',
        error: e.toString(),
      );
    }
  }

  // Marcar tarea como completada
  Future<ApiResponse<Task>> completeTask(String taskId) async {
    try {
      final response = await _dioClient.dio.post(
        '${AppConfig.apiUrl}/api/user/tasks/$taskId/complete/',
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final task = Task.fromJson(apiResponse.data!);
        
        return ApiResponse<Task>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          data: task,
        );
      } else {
        return ApiResponse<Task>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          error: apiResponse.error,
        );
      }
    } catch (e) {
      return ApiResponse<Task>(
        statusCode: 500,
        message: 'Error al completar tarea',
        error: e.toString(),
      );
    }
  }

  // Obtener tareas vencidas
  Future<ApiResponse<List<Task>>> getOverdueTasks() async {
    try {
      final response = await _dioClient.dio.get(
        '${AppConfig.apiUrl}/api/user/tasks/overdue_tasks/',
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final tasks = apiResponse.data!.map((json) => Task.fromJson(json)).toList();
        
        return ApiResponse<List<Task>>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          data: tasks,
        );
      } else {
        return ApiResponse<List<Task>>(
          statusCode: apiResponse.statusCode,
          message: apiResponse.message,
          error: apiResponse.error,
        );
      }
    } catch (e) {
      return ApiResponse<List<Task>>(
        statusCode: 500,
        message: 'Error al obtener tareas vencidas',
        error: e.toString(),
      );
    }
  }
}