import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Simular tiempo de carga
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        // Validar token con el backend
        final isValidToken = await _authService.validateToken();
        
        if (isValidToken && mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // En caso de error, ir al login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B), // light-action
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o ícono de la app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA), // light-bg-primary
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.apartment,
                size: 80,
                color: Color(0xFF18181B), // light-action
              ),
            ),
            const SizedBox(height: 32),
            
            // Título de la app
            Text(
              'Condominium App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFFFAFAFA), // dark-text-primary
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Sistema de gestión inteligente',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFFAFAFA).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            
            // Indicador de carga
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFFAFAFA), // dark-text-primary
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Cargando...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFAFAFA).withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}