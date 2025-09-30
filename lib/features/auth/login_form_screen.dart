import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/common_widgets.dart';

class LoginFormScreen extends StatefulWidget {
  final UserRole userRole;
  final String roleTitle;
  final Color roleColor;

  const LoginFormScreen({
    super.key,
    required this.userRole,
    required this.roleTitle,
    required this.roleColor,
  });

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
        widget.userRole,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.isSuccess) {
          // Login exitoso
          _showSnackBar(result.message, true);
          
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        } else {
          // Error en login
          _showSnackBar(result.errorMessage, false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showSnackBar('Error inesperado: $e', false);
      }
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess 
            ? const Color(0xFF6BD968) // success
            : const Color(0xFFF44250), // danger
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // light-bg-primary
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF09090B), // light-text-primary
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.roleTitle,
          style: const TextStyle(
            color: Color(0xFF09090B), // light-text-primary
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Header con icono del rol
                _buildRoleHeader(),
                
                const SizedBox(height: 48),
                
                // Formulario
                _buildLoginForm(),
                
                const SizedBox(height: 32),
                
                // Botón de login
                _buildLoginButton(),
                
                const SizedBox(height: 24),
                
                // Enlaces adicionales
                _buildFooterLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleHeader() {
    IconData roleIcon;
    switch (widget.userRole) {
      case UserRole.admin:
        roleIcon = Icons.admin_panel_settings;
        break;
      case UserRole.resident:
        roleIcon = Icons.home;
        break;
      case UserRole.visitor:
        roleIcon = Icons.person_outline;
        break;
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: widget.roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.roleColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            roleIcon,
            size: 40,
            color: widget.roleColor,
          ),
        ),
        const SizedBox(height: 20),
        
        Text(
          'Iniciar Sesión',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B), // light-text-primary
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          'Ingresa tus credenciales para acceder como ${widget.roleTitle.toLowerCase()}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF71717A), // light-text-secondary
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Campo de email
        ShadcnTextField(
          controller: _emailController,
          label: 'Correo Electrónico',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu correo';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Por favor ingresa un correo válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        // Campo de contraseña
        ShadcnTextField(
          controller: _passwordController,
          label: 'Contraseña',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF71717A), // light-text-secondary
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ShadcnButton(
      text: 'Iniciar Sesión',
      onPressed: _isLoading ? null : _login,
      isLoading: _isLoading,
      backgroundColor: widget.roleColor,
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            _showSnackBar('Función de recuperar contraseña próximamente', false);
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF71717A), // light-text-secondary
          ),
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
        
        if (widget.userRole == UserRole.visitor) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F5), // light-bg-secondary
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE4E4E7), // light-border
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3992FF), // process
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Eres un nuevo visitante?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF09090B), // light-text-primary
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contacta a la administración para obtener tus credenciales de acceso.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF71717A), // light-text-secondary
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}