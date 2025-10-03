class CommonArea {
  final String id;
  final String name;
  final String? description;
  final int capacity;
  final double costPerHour;
  final bool isReservable;
  final bool isActive;
  final String availableFrom;
  final String availableTo;
  final AvailabilityDays availabilityDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommonArea({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    required this.costPerHour,
    required this.isReservable,
    required this.isActive,
    required this.availableFrom,
    required this.availableTo,
    required this.availabilityDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommonArea.fromJson(Map<String, dynamic> json) {
    return CommonArea(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      capacity: json['capacity'],
      costPerHour: double.parse(json['cost_per_hour'].toString()),
      isReservable: json['is_reservable'] ?? true,
      isActive: json['is_active'] ?? true,
      availableFrom: json['available_from'],
      availableTo: json['available_to'],
      availabilityDays: AvailabilityDays.fromJson(json),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'cost_per_hour': costPerHour,
      'is_reservable': isReservable,
      'is_active': isActive,
      'available_from': availableFrom,
      'available_to': availableTo,
      ...availabilityDays.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedCost {
    if (costPerHour == 0) return 'Gratis';
    return '\$${costPerHour.toStringAsFixed(2)}/hora';
  }

  String get availabilitySchedule {
    return '$availableFrom - $availableTo';
  }

  String get capacityText {
    return '$capacity ${capacity == 1 ? 'persona' : 'personas'}';
  }

  bool get isFree => costPerHour == 0;

  List<String> get availableDaysList {
    return availabilityDays.getAvailableDayNames();
  }

  String get availableDaysText {
    final days = availableDaysList;
    if (days.length == 7) return 'Todos los días';
    if (days.length == 5 && !days.contains('Sábado') && !days.contains('Domingo')) {
      return 'Lunes a Viernes';
    }
    if (days.length == 2 && days.contains('Sábado') && days.contains('Domingo')) {
      return 'Fines de semana';
    }
    return days.join(', ');
  }
}

class AvailabilityDays {
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  AvailabilityDays({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory AvailabilityDays.fromJson(Map<String, dynamic> json) {
    return AvailabilityDays(
      monday: json['available_monday'] ?? true,
      tuesday: json['available_tuesday'] ?? true,
      wednesday: json['available_wednesday'] ?? true,
      thursday: json['available_thursday'] ?? true,
      friday: json['available_friday'] ?? true,
      saturday: json['available_saturday'] ?? true,
      sunday: json['available_sunday'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available_monday': monday,
      'available_tuesday': tuesday,
      'available_wednesday': wednesday,
      'available_thursday': thursday,
      'available_friday': friday,
      'available_saturday': saturday,
      'available_sunday': sunday,
    };
  }

  List<String> getAvailableDayNames() {
    List<String> days = [];
    if (monday) days.add('Lunes');
    if (tuesday) days.add('Martes');
    if (wednesday) days.add('Miércoles');
    if (thursday) days.add('Jueves');
    if (friday) days.add('Viernes');
    if (saturday) days.add('Sábado');
    if (sunday) days.add('Domingo');
    return days;
  }

  bool isDayAvailable(int weekday) {
    switch (weekday) {
      case 1: return monday;
      case 2: return tuesday;
      case 3: return wednesday;
      case 4: return thursday;
      case 5: return friday;
      case 6: return saturday;
      case 7: return sunday;
      default: return false;
    }
  }
}

class CommonAreaRule {
  final String id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  CommonAreaRule({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory CommonAreaRule.fromJson(Map<String, dynamic> json) {
    return CommonAreaRule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Reservation {
  final String id;
  final String commonAreaId;
  final String commonAreaName;
  final DateTime reservationDate;
  final String startTime;
  final String endTime;
  final String? purpose;
  final int estimatedAttendees;
  final String status;
  final double totalHours;
  final double totalCost;
  final String? adminNotes;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.commonAreaId,
    required this.commonAreaName,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    this.purpose,
    required this.estimatedAttendees,
    required this.status,
    required this.totalHours,
    required this.totalCost,
    this.adminNotes,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // El backend puede devolver common_area como objeto o como string ID
    String commonAreaId;
    String commonAreaName = '';
    
    if (json['common_area'] is Map<String, dynamic>) {
      // Si common_area es un objeto, extraer el ID y nombre
      final commonAreaData = json['common_area'] as Map<String, dynamic>;
      commonAreaId = commonAreaData['id'];
      commonAreaName = commonAreaData['name'] ?? '';
    } else {
      // Si common_area es un string (ID), usarlo directamente
      commonAreaId = json['common_area'];
      commonAreaName = json['common_area_name'] ?? '';
    }

    return Reservation(
      id: json['id'],
      commonAreaId: commonAreaId,
      commonAreaName: commonAreaName,
      reservationDate: DateTime.parse(json['reservation_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      purpose: json['purpose'],
      estimatedAttendees: json['estimated_attendees'] ?? 1,
      status: json['status'],
      totalHours: double.parse(json['total_hours'].toString()),
      totalCost: double.parse(json['total_cost'].toString()),
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedDate {
    return '${reservationDate.day}/${reservationDate.month}/${reservationDate.year}';
  }

  String get formattedTimeRange {
    return '$startTime - $endTime';
  }

  String get formattedCost {
    if (totalCost == 0) return 'Gratis';
    return '\$${totalCost.toStringAsFixed(2)}';
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pendiente';
      case 'approved': return 'Aprobada';
      case 'rejected': return 'Rechazada';
      case 'cancelled': return 'Cancelada';
      case 'completed': return 'Completada';
      default: return status;
    }
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}