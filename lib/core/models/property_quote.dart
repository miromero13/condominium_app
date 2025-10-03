class PropertyQuote {
  final String id;
  final String paymentType;
  final String paymentTypeLabel;
  final String? relatedPropertyId;
  final String? propertyName;
  final String? relatedReservationId;
  final ReservationInfo? reservationInfo;
  final List<QuoteUserInfo> responsibleUsersInfo;
  final String? paidById;
  final QuoteUserInfo? paidByInfo;
  final double amount;
  final String description;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? paymentReference;
  final Map<String, dynamic>? paymentData;
  final String status;
  final String statusLabel;
  final int? periodMonth;
  final int? periodYear;
  final bool isAutomatic;
  final bool isOverdue;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyQuote({
    required this.id,
    required this.paymentType,
    required this.paymentTypeLabel,
    this.relatedPropertyId,
    this.propertyName,
    this.relatedReservationId,
    this.reservationInfo,
    required this.responsibleUsersInfo,
    this.paidById,
    this.paidByInfo,
    required this.amount,
    required this.description,
    required this.dueDate,
    this.paidDate,
    this.paymentReference,
    this.paymentData,
    required this.status,
    required this.statusLabel,
    this.periodMonth,
    this.periodYear,
    required this.isAutomatic,
    required this.isOverdue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyQuote.fromJson(Map<String, dynamic> json) {
    return PropertyQuote(
      id: json['id'],
      paymentType: json['payment_type'],
      paymentTypeLabel: json['payment_type_label'],
      relatedPropertyId: json['related_property'],
      propertyName: json['property_name'],
      relatedReservationId: json['related_reservation'],
      reservationInfo: json['reservation_info'] != null 
          ? ReservationInfo.fromJson(json['reservation_info'])
          : null,
      responsibleUsersInfo: (json['responsible_users_info'] as List?)
          ?.map((user) => QuoteUserInfo.fromJson(user))
          .toList() ?? [],
      paidById: json['paid_by'],
      paidByInfo: json['paid_by_info'] != null 
          ? QuoteUserInfo.fromJson(json['paid_by_info'])
          : null,
      amount: double.parse(json['amount'].toString()),
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
      paidDate: json['paid_date'] != null 
          ? DateTime.parse(json['paid_date'])
          : null,
      paymentReference: json['payment_reference'],
      paymentData: json['payment_data'],
      status: json['status'],
      statusLabel: json['status_label'],
      periodMonth: json['period_month'],
      periodYear: json['period_year'],
      isAutomatic: json['is_automatic'] ?? false,
      isOverdue: json['is_overdue'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_type': paymentType,
      'payment_type_label': paymentTypeLabel,
      'related_property': relatedPropertyId,
      'property_name': propertyName,
      'related_reservation': relatedReservationId,
      'reservation_info': reservationInfo?.toJson(),
      'responsible_users_info': responsibleUsersInfo.map((user) => user.toJson()).toList(),
      'paid_by': paidById,
      'paid_by_info': paidByInfo?.toJson(),
      'amount': amount,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'payment_reference': paymentReference,
      'payment_data': paymentData,
      'status': status,
      'status_label': statusLabel,
      'period_month': periodMonth,
      'period_year': periodYear,
      'is_automatic': isAutomatic,
      'is_overdue': isOverdue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  
  String get formattedDueDate {
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }
  
  String get formattedPaidDate {
    if (paidDate == null) return '';
    return '${paidDate!.day}/${paidDate!.month}/${paidDate!.year}';
  }
  
  String get periodDisplay {
    if (periodMonth != null && periodYear != null) {
      const months = [
        '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return '${months[periodMonth!]} $periodYear';
    }
    return '';
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
}

class ReservationInfo {
  final String id;
  final String commonAreaName;
  final DateTime reservationDate;
  final String startTime;
  final String endTime;
  final double totalHours;
  final String status;

  ReservationInfo({
    required this.id,
    required this.commonAreaName,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.status,
  });

  factory ReservationInfo.fromJson(Map<String, dynamic> json) {
    return ReservationInfo(
      id: json['id'],
      commonAreaName: json['common_area_name'],
      reservationDate: DateTime.parse(json['reservation_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalHours: double.parse(json['total_hours'].toString()),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'common_area_name': commonAreaName,
      'reservation_date': reservationDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'total_hours': totalHours,
      'status': status,
    };
  }
}

// UserInfo específico para quotes que incluye el ID
class QuoteUserInfo {
  final String id;
  final String name;
  final String email;
  final String role;

  QuoteUserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory QuoteUserInfo.fromJson(Map<String, dynamic> json) {
    return QuoteUserInfo(
      id: json['id'],
      name: json['name'] ?? json['first_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}