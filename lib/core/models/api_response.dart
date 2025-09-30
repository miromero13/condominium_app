class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T? data;
  final dynamic error;
  final int? countData;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
    this.error,
    this.countData,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: json['data'] as T?,
      error: json['error'],
      countData: json['countData'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data,
      'error': error,
      'countData': countData,
    };
  }

  // Método de conveniencia para respuestas exitosas
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  // Método de conveniencia para obtener el mensaje de error
  String get errorMessage {
    if (error != null) {
      if (error is Map) {
        // Maneja errores de validación de Django
        return _formatValidationErrors(error);
      }
      return error.toString();
    }
    return message;
  }

  String _formatValidationErrors(Map<String, dynamic> errors) {
    final List<String> errorMessages = [];
    errors.forEach((field, fieldErrors) {
      if (fieldErrors is List) {
        for (var error in fieldErrors) {
          errorMessages.add('$field: $error');
        }
      } else {
        errorMessages.add('$field: $fieldErrors');
      }
    });
    return errorMessages.join('\n');
  }
}