import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/user_type_selection_screen.dart';
import 'features/home/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Condominium App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF18181B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // Para un look más moderno
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // light-bg-primary
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const UserTypeSelectionScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}