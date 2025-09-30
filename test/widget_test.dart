// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:condominium_app/features/auth/user_type_selection_screen.dart';
import 'package:condominium_app/features/auth/login_form_screen.dart';
import 'package:condominium_app/core/services/auth_service.dart';

void main() {
  testWidgets('User type selection screen displays correctly', (WidgetTester tester) async {
    // Test the user type selection screen directly
    await tester.pumpWidget(
      const MaterialApp(
        home: UserTypeSelectionScreen(),
      ),
    );

    // Verify that the screen displays correctly
    expect(find.text('Selecciona tu tipo de usuario'), findsOneWidget);
    
    // Verify that the user type cards are present
    expect(find.text('Administrador / Guardia'), findsOneWidget);
    expect(find.text('Residente / Propietario'), findsOneWidget);
    expect(find.text('Visitante'), findsOneWidget);
    
    // Verify that descriptions are present
    expect(find.text('Gestión y administración del condominio'), findsOneWidget);
    expect(find.text('Propietarios y residentes del condominio'), findsOneWidget);
    expect(find.text('Invitados y visitantes temporales'), findsOneWidget);
  });

  testWidgets('Login form screen displays correctly', (WidgetTester tester) async {
    // Test the login form screen directly
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginFormScreen(
          userRole: UserRole.admin,
          roleTitle: 'Administrador',
          roleColor: Colors.blue,
        ),
      ),
    );

    // Wait for the screen to build
    await tester.pumpAndSettle();

    // Verify login form elements
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    
    // Verify the login button is present
    expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);
  });

  testWidgets('Can enter text in login form fields', (WidgetTester tester) async {
    // Test text input in login form
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginFormScreen(
          userRole: UserRole.admin,
          roleTitle: 'Administrador',
          roleColor: Colors.blue,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the email field by its hint text instead
    final emailFields = find.byType(TextFormField);
    expect(emailFields, findsNWidgets(2));
    
    // Enter text in first field (email)
    await tester.enterText(emailFields.first, 'test@example.com');
    
    // Enter text in second field (password)
    await tester.enterText(emailFields.last, 'password123');
    
    await tester.pump();
    
    // Verify the email text was entered (password is obscured so we can't see it)
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('Form validation works', (WidgetTester tester) async {
    // Test form validation
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginFormScreen(
          userRole: UserRole.admin,
          roleTitle: 'Administrador',
          roleColor: Colors.blue,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Try to submit empty form
    final loginButton = find.widgetWithText(ElevatedButton, 'Ingresar');
    await tester.tap(loginButton);
    await tester.pump();

    // Should show validation errors
    expect(find.text('Por favor ingresa tu email'), findsOneWidget);
    expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
  });
}
