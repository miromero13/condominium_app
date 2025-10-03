import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common_widgets.dart';

class StripeTestCardsScreen extends StatelessWidget {
  const StripeTestCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Tarjetas de Prueba',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Información de Prueba',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Esta aplicación está en modo de prueba. Puedes usar las siguientes tarjetas de prueba para simular diferentes escenarios de pago.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No se realizarán cargos reales',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tarjetas de prueba exitosas
            _buildTestCardSection(
              context,
              title: '✅ Tarjetas de Prueba Exitosas',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              cards: [
                TestCard(
                  number: '4242 4242 4242 4242',
                  description: 'Visa - Pago exitoso',
                  type: 'Visa',
                ),
                TestCard(
                  number: '5555 5555 5555 4444',
                  description: 'Mastercard - Pago exitoso',
                  type: 'Mastercard',
                ),
                TestCard(
                  number: '3782 822463 10005',
                  description: 'American Express - Pago exitoso',
                  type: 'American Express',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tarjetas de prueba con errores
            _buildTestCardSection(
              context,
              title: '❌ Tarjetas con Errores (Para Pruebas)',
              icon: Icons.error_outline,
              iconColor: Colors.red,
              cards: [
                TestCard(
                  number: '4000 0000 0000 0002',
                  description: 'Tarjeta declinada',
                  type: 'Visa - Error',
                ),
                TestCard(
                  number: '4000 0000 0000 9995',
                  description: 'Fondos insuficientes',
                  type: 'Visa - Error',
                ),
                TestCard(
                  number: '4000 0000 0000 9987',
                  description: 'Tarjeta perdida',
                  type: 'Visa - Error',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información Adicional',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today, 'Fecha de Expiración', 'Cualquier fecha futura (ej: 12/25, 01/30)'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.security, 'CVC', 'Cualquier código de 3 dígitos (ej: 123, 456)'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on, 'Código Postal', 'Cualquier código postal (ej: 12345)'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person, 'Nombre', 'Cualquier nombre'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón para cerrar
            SizedBox(
              width: double.infinity,
              child: ShadcnButton(
                text: 'Entendido',
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: const Color(0xFF18181B),
                textColor: Colors.white,
                icon: Icons.check,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCardSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<TestCard> cards,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTestCard(context, card),
          )),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, TestCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  card.number,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: card.number.replaceAll(' ', '')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Número copiado: ${card.number}'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF18181B),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copiar número',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.type,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class TestCard {
  final String number;
  final String description;
  final String type;

  TestCard({
    required this.number,
    required this.description,
    required this.type,
  });
}