class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? ci;
  final bool isActive;
  final bool emailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.ci,
    required this.isActive,
    required this.emailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      ci: json['ci'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'ci': ci,
      'is_active': isActive,
      'email_verified': emailVerified,
    };
  }

  // Método de conveniencia para obtener el nombre del rol en español
  String get roleDisplayName {
    switch (role) {
      case 'administrator':
        return 'Administrador';
      case 'guard':
        return 'Guardia';
      case 'owner':
        return 'Propietario';
      case 'resident':
        return 'Residente';
      case 'visitor':
        return 'Visitante';
      default:
        return 'Usuario';
    }
  }

  // Método para verificar si es admin o guardia
  bool get isAdminOrGuard => role == 'administrator' || role == 'guard';

  // Método para verificar si es propietario o residente
  bool get isOwnerOrResident => role == 'owner' || role == 'resident';

  // Método para verificar si es visitante
  bool get isVisitor => role == 'visitor';
}