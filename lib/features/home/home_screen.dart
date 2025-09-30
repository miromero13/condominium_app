import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user.dart';
import '../../widgets/common_widgets.dart';
import 'layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        // Si no hay usuario, redirigir al login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      // En caso de error, redirigir al login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA), // light-bg-primary
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B), // light-action
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.apartment,
                  size: 40,
                  color: Color(0xFFFAFAFA), // light-bg-primary
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF18181B), // light-action
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF71717A), // light-text-secondary
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA), // light-bg-primary
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF), // light-bg-primary
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE4E4E7), // light-border
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
                    Icons.error_outline,
                    size: 32,
                    color: Color(0xFFF44250), // danger
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Error al cargar usuario',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF09090B), // light-text-primary
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor, inicia sesión nuevamente',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF71717A), // light-text-secondary
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ShadcnButton(
                  text: 'Iniciar Sesión',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  backgroundColor: const Color(0xFF18181B), // light-action
                  icon: Icons.login,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AuthenticatedLayout(user: _currentUser!);
  }
}