class Property {
  final String id;
  final String name;
  final String address;
  final String? buildingOrBlock;
  final String propertyNumber;
  final String status;
  final String statusLabel;

  Property({
    required this.id,
    required this.name,
    required this.address,
    this.buildingOrBlock,
    required this.propertyNumber,
    required this.status,
    required this.statusLabel,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      buildingOrBlock: json['building_or_block'],
      propertyNumber: json['property_number'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
    );
  }

  String get displayAddress {
    final parts = [address];
    if (buildingOrBlock != null && buildingOrBlock!.isNotEmpty) {
      parts.add('Bloque $buildingOrBlock');
    }
    if (propertyNumber != 'S/N' && propertyNumber.isNotEmpty) {
      parts.add('#$propertyNumber');
    }
    return parts.join(', ');
  }

  String get statusDisplay => statusLabel;
}

class UserInfo {
  final String name;
  final String email;
  final String role;
  final List<String> propertyRoles;

  UserInfo({
    required this.name,
    required this.email,
    required this.role,
    required this.propertyRoles,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      propertyRoles: List<String>.from(json['property_roles'] ?? []),
    );
  }

  String get primaryRole {
    if (propertyRoles.contains('owner')) return 'Propietario';
    if (propertyRoles.contains('resident')) return 'Residente';
    return 'Visitante';
  }
}

class PaymentStats {
  final bool hasPendingPayments;
  final int pendingQuotesCount;
  final double nextPaymentAmount;
  final DateTime? nextPaymentDueDate;

  PaymentStats({
    required this.hasPendingPayments,
    required this.pendingQuotesCount,
    required this.nextPaymentAmount,
    this.nextPaymentDueDate,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      hasPendingPayments: json['has_pending_payments'] ?? false,
      pendingQuotesCount: json['pending_quotes_count'] ?? 0,
      nextPaymentAmount: double.tryParse(json['next_payment_amount'].toString()) ?? 0.0,
      nextPaymentDueDate: json['next_payment_due_date'] != null 
          ? DateTime.parse(json['next_payment_due_date']) 
          : null,
    );
  }
}

class ReservationStats {
  final int activeReservationsCount;
  final List<dynamic> upcomingReservations;

  ReservationStats({
    required this.activeReservationsCount,
    required this.upcomingReservations,
  });

  factory ReservationStats.fromJson(Map<String, dynamic> json) {
    return ReservationStats(
      activeReservationsCount: json['active_reservations_count'] ?? 0,
      upcomingReservations: json['upcoming_reservations'] ?? [],
    );
  }
}

class DashboardInfo {
  final bool hasProperty;
  final UserInfo userInfo;
  final Property? property;
  final PaymentStats paymentStats;
  final ReservationStats reservationStats;

  DashboardInfo({
    required this.hasProperty,
    required this.userInfo,
    this.property,
    required this.paymentStats,
    required this.reservationStats,
  });

  factory DashboardInfo.fromJson(Map<String, dynamic> json) {
    return DashboardInfo(
      hasProperty: json['has_property'] ?? false,
      userInfo: UserInfo.fromJson(json['user_info'] ?? {}),
      property: json['property'] != null ? Property.fromJson(json['property']) : null,
      paymentStats: PaymentStats.fromJson(json['payment_stats'] ?? {}),
      reservationStats: ReservationStats.fromJson(json['reservation_stats'] ?? {}),
    );
  }
}