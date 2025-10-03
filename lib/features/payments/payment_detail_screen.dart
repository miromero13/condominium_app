import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../widgets/common_widgets.dart';
import '../../core/models/property_quote.dart';
import '../../core/services/payment_service.dart';
import 'stripe_test_cards_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  final PropertyQuote quote;

  const PaymentDetailScreen({
    super.key,
    required this.quote,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Realizar Pago',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StripeTestCardsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
            tooltip: 'Ver tarjetas de prueba',
            color: const Color(0xFF18181B),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del pago
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            
            // Detalles adicionales
            _buildPaymentDetails(),
            const SizedBox(height: 24),
            
            // Métodos de pago
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            
            // Error message
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Botón de pago
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen del Pago',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Descripción del pago
          Text(
            widget.quote.description,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Estado actual
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 16,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.quote.statusLabel,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                widget.quote.formattedAmount,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF18181B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del Pago',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Fecha de vencimiento
          _buildDetailRow(
            Icons.schedule,
            'Fecha de Vencimiento',
            widget.quote.formattedDueDate,
            valueColor: widget.quote.isOverdue ? Colors.red : null,
          ),
          
          // Período si existe
          if (widget.quote.periodDisplay.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_month,
              'Período',
              widget.quote.periodDisplay,
            ),
          ],
          
          // Propiedad si existe
          if (widget.quote.propertyName != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.home,
              'Propiedad',
              widget.quote.propertyName!,
            ),
          ],
          
          // Información de reserva si existe
          if (widget.quote.reservationInfo != null) ...[
            const SizedBox(height: 16),
            Container(
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
                      Icon(
                        Icons.event,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Detalles de la Reserva',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.quote.reservationInfo!.commonAreaName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDate(widget.quote.reservationInfo!.reservationDate)} • ${widget.quote.reservationInfo!.startTime} - ${widget.quote.reservationInfo!.endTime}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '${widget.quote.reservationInfo!.totalHours} horas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de Pago',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Método de pago por tarjeta (por ahora el único disponible)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF18181B),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Color(0xFF18181B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarjeta de Crédito/Débito',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pago seguro procesado por Stripe',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'card',
                  groupValue: 'card',
                  onChanged: (value) {},
                  activeColor: const Color(0xFF18181B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF18181B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Procesando...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pagar ${widget.quote.formattedAmount}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Información de seguridad
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Procesado de forma segura por Stripe',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.quote.status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.quote.status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      print('🔄 Iniciando proceso de pago...');
      
      // Crear Payment Intent en el backend
      final paymentIntentData = await _paymentService.createPaymentIntent(
        paymentId: widget.quote.id,
        mobile: true,
      );
      
      print('💳 Payment Intent creado: ${paymentIntentData['client_secret']}');
      
      // Verificar que tenemos el client_secret
      final clientSecret = paymentIntentData['client_secret'];
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('No se pudo obtener el client_secret del servidor');
      }
      
      // Usar la clave pública que viene del backend
      final publishableKey = paymentIntentData['publishable_key'];
      if (publishableKey != null && publishableKey.isNotEmpty) {
        print('🔑 Configurando Stripe con clave del backend: ${publishableKey.substring(0, 20)}...');
        Stripe.publishableKey = publishableKey;
        await Stripe.instance.applySettings();
      }
      
      // Mostrar el formulario de pago de Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Condominio App',
          style: ThemeMode.system,
        ),
      );
      
      // Presentar el Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      
      // Si llegamos aquí, el pago fue exitoso
      print('✅ Pago exitoso!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Pago procesado exitosamente con Stripe!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        Navigator.of(context).pop(true);
      }
      
    } on StripeException catch (e) {
      print('❌ Error de Stripe: ${e.error}');
      
      String errorMessage;
      switch (e.error.code) {
        case FailureCode.Canceled:
          errorMessage = 'Pago cancelado por el usuario';
          break;
        case FailureCode.Failed:
          errorMessage = 'El pago falló. Verifica los datos de tu tarjeta.';
          break;
        case FailureCode.Timeout:
          errorMessage = 'Tiempo agotado. Intenta nuevamente.';
          break;
        default:
          errorMessage = 'Error en el procesamiento: ${e.error.localizedMessage ?? 'Error desconocido'}';
      }
      
      setState(() {
        _error = errorMessage;
      });
      
    } catch (e) {
      print('❌ Error general: $e');
      setState(() {
        _error = 'Error al procesar el pago: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}