import 'package:flutter/material.dart';
import 'login_form_screen.dart';
import '../../core/services/auth_service.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // light-bg-primary
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Logo y título
              _buildHeader(context),
              
              const SizedBox(height: 40),
              
              // Opciones de usuario
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                    
                    // Tarjetas de roles
                    _buildUserTypeCard(
                      context,
                      'Administración',
                      'Panel de control completo del sistema',
                      Icons.admin_panel_settings,
                      const Color(0xFF3992FF), // process
                      UserRole.admin,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildUserTypeCard(
                      context,
                      'Residente o Propietario',
                      'Acceso a servicios y gestión de tu propiedad',
                      Icons.home,
                      const Color(0xFF6BD968), // success
                      UserRole.resident,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildUserTypeCard(
                      context,
                      'Visitante',
                      'Acceso temporal con permisos limitados',
                      Icons.person_outline,
                      const Color(0xFFFECC1B), // warning
                      UserRole.visitor,
                    ),
                  ],
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF18181B), // light-action
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.apartment,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          'SmartCondo',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B), // light-text-primary
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          'Sistema de gestión inteligente',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF71717A), // light-text-secondary
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color accentColor,
    UserRole userRole,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // light-bg-primary
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E4E7), // light-border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LoginFormScreen(
                  userRole: userRole,
                  roleTitle: title,
                  roleColor: accentColor,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF09090B), // light-text-primary
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF71717A), // light-text-secondary
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF71717A), // light-text-secondary
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}