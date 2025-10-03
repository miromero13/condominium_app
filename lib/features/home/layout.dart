import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../roles/role_admin.dart';
import '../roles/role_resident.dart';
import '../roles/role_visitor.dart';
import '../roles/role_guest.dart';
import '../payments/payments_screen.dart';
import '../common_areas/common_areas_screen.dart';
import '../../widgets/common_widgets.dart';

class AuthenticatedLayout extends StatefulWidget {
  final User user;

  const AuthenticatedLayout({
    super.key,
    required this.user,
  });

  @override
  State<AuthenticatedLayout> createState() => _AuthenticatedLayoutState();
}

class _AuthenticatedLayoutState extends State<AuthenticatedLayout> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  // Mapa de roles a widgets
  late final Map<String, Widget> _roleWidgets;
  late final List<BottomNavigationBarItem> _navigationItems;

  @override
  void initState() {
    super.initState();
    _initializeRoleContent();
  }

  void _initializeRoleContent() {
    // Configurar contenido según el rol del usuario
    switch (widget.user.role) {
      case 'administrator':
      case 'guard':
        _roleWidgets = {
          'admin': const RoleAdmin(),
          'users': const Center(child: Text('Gestión de Usuarios\n(Próximamente)')),
          'settings': const Center(child: Text('Configuración\n(Próximamente)')),
        };
        _navigationItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Panel',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ];
        break;

      case 'owner':
      case 'resident':
        _roleWidgets = {
          'resident': const RoleResident(),
          'payments': const PaymentsScreen(),
          'services': const CommonAreasScreen(),
        };
        _navigationItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pagos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'Áreas',
          ),
        ];
        break;

      case 'visitor':
        _roleWidgets = {
          'visitor': const RoleVisitor(),
          'info': const Center(child: Text('Información\n(Próximamente)')),
        };
        _navigationItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Visita',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ];
        break;

      default:
        _roleWidgets = {
          'guest': const RoleGuest(),
        };
        _navigationItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleKeys = _roleWidgets.keys.toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // light-bg-primary
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // light-bg-primary
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF18181B), // light-action
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.apartment,
                color: Color(0xFFFAFAFA), // light-bg-primary
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Condominio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF09090B), // light-text-primary
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getRoleDisplayName(widget.user.role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF71717A), // light-text-secondary
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5), // light-bg-secondary
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE4E4E7), // light-border
                    width: 1,
                  ),
                ),
                child: widget.user.name.isNotEmpty
                    ? Center(
                        child: Text(
                          widget.user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF18181B), // light-action
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF18181B), // light-action
                        size: 20,
                      ),
              ),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFFFFFFFF), // light-bg-primary
              shadowColor: Colors.black.withOpacity(0.1),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Color(0xFF71717A), // light-text-secondary
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Mi Perfil',
                        style: TextStyle(
                          color: Color(0xFF09090B), // light-text-primary
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Color(0xFFF44250), // danger
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Color(0xFFF44250), // danger
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) {
                switch (value) {
                  case 'profile':
                    _showProfile();
                    break;
                  case 'logout':
                    _showLogoutConfirmation();
                    break;
                }
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE4E4E7), // light-border
          ),
        ),
      ),
      body: roleKeys.isNotEmpty
          ? _roleWidgets[roleKeys[_currentIndex]] ?? const RoleGuest()
          : const RoleGuest(),
      bottomNavigationBar: _navigationItems.length > 1
          ? Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF), // light-bg-primary
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFE4E4E7), // light-border
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF18181B), // light-action
                unselectedItemColor: const Color(0xFF71717A), // light-text-secondary
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                items: _navigationItems,
              ),
            )
          : null,
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'administrator':
        return 'Administrador';
      case 'guard':
        return 'Guardia';
      case 'resident':
        return 'Residente';
      case 'owner':
        return 'Propietario';
      case 'visitor':
        return 'Visitante';
      case 'guest':
        return 'Invitado';
      default:
        return 'Usuario';
    }
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFFFFFFF), // light-bg-primary
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B), // light-action
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.user.name.isNotEmpty
                        ? Center(
                            child: Text(
                              widget.user.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFFAFAFA), // light-bg-primary
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Color(0xFFFAFAFA), // light-bg-primary
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mi Perfil',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF09090B), // light-text-primary
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getRoleDisplayName(widget.user.role),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF71717A), // light-text-secondary
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5), // light-bg-secondary
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildProfileItem('Nombre:', widget.user.name),
                    _buildProfileItem('Email:', widget.user.email),
                    _buildProfileItem('Rol:', widget.user.roleDisplayName),
                    if (widget.user.phone != null)
                      _buildProfileItem('Teléfono:', widget.user.phone!),
                    if (widget.user.ci != null)
                      _buildProfileItem('CI:', widget.user.ci!),
                    _buildProfileItem(
                      'Estado:', 
                      widget.user.isActive ? 'Activo' : 'Inactivo',
                    ),
                    _buildProfileItem(
                      'Email verificado:', 
                      widget.user.emailVerified ? 'Sí' : 'No',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            color: Color(0xFF71717A), // light-text-secondary
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: ShadcnButton(
                      text: 'Editar',
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Edición de perfil próximamente'),
                            backgroundColor: const Color(0xFF18181B), // light-action
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      backgroundColor: const Color(0xFF18181B), // light-action
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF71717A), // light-text-secondary
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF09090B), // light-text-primary
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFFFFFFF), // light-bg-primary
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF44250).withOpacity(0.1), // danger
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.logout,
                  size: 32,
                  color: Color(0xFFF44250), // danger
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cerrar Sesión',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF09090B), // light-text-primary
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Estás seguro de que deseas cerrar sesión?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF71717A), // light-text-secondary
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Color(0xFF71717A), // light-text-secondary
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: ShadcnButton(
                      text: 'Cerrar Sesión',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      backgroundColor: const Color(0xFFF44250), // danger
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF), // light-bg-primary
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF18181B), // light-action
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cerrando sesión...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF09090B), // light-text-primary
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await _authService.logout();
      
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        
        if (success) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al cerrar sesión'),
              backgroundColor: const Color(0xFFF44250), // danger
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFF44250), // danger
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}