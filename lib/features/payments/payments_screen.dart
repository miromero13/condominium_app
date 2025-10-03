import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../core/services/property_service.dart';
import '../../core/models/property_quote.dart';
import 'payment_detail_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  final PropertyService _propertyService = PropertyService();
  late TabController _tabController;
  
  List<PropertyQuote> _allQuotes = [];
  List<PropertyQuote> _pendingQuotes = [];
  List<PropertyQuote> _paidQuotes = [];
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadQuotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final allQuotes = await _propertyService.getAllQuotes();
      
      if (mounted) {
        setState(() {
          _allQuotes = allQuotes;
          _pendingQuotes = allQuotes.where((quote) => 
              quote.status == 'pending' || quote.status == 'overdue').toList();
          _paidQuotes = allQuotes.where((quote) => 
              quote.status == 'paid').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
          'Mis Pagos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B),
          ),
        ),
        bottom: _isLoading ? null : TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF18181B),
          unselectedLabelColor: const Color(0xFF71717A),
          indicatorColor: const Color(0xFF18181B),
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              text: 'Todas (${_allQuotes.length})',
              icon: const Icon(Icons.list, size: 20),
            ),
            Tab(
              text: 'Pendientes (${_pendingQuotes.length})',
              icon: const Icon(Icons.schedule, size: 20),
            ),
            Tab(
              text: 'Pagadas (${_paidQuotes.length})',
              icon: const Icon(Icons.check_circle, size: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuotes,
            color: const Color(0xFF18181B),
          ),
        ],
      ),
      body: _isLoading 
          ? _buildLoadingView()
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuotesList(_allQuotes, 'No tienes cuotas registradas'),
                    _buildQuotesList(_pendingQuotes, 'No tienes pagos pendientes'),
                    _buildQuotesList(_paidQuotes, 'No tienes pagos realizados'),
                  ],
                ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF18181B)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando pagos...',
            style: TextStyle(
              color: Color(0xFF71717A),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los pagos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ShadcnButton(
              text: 'Reintentar',
              onPressed: _loadQuotes,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesList(List<PropertyQuote> quotes, String emptyMessage) {
    if (quotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment_outlined,
                size: 64,
                color: const Color(0xFF71717A),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF71717A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuotes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final quote = quotes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildQuoteCard(quote),
          );
        },
      ),
    );
  }

  Widget _buildQuoteCard(PropertyQuote quote) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado y monto
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(quote.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quote.statusLabel,
                  style: TextStyle(
                    color: _getStatusColor(quote.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                quote.formattedAmount,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(quote.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Descripción
          Text(
            quote.description,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Información del período si existe
          if (quote.periodDisplay.isNotEmpty) ...[
            _buildDetailRow(
              Icons.calendar_month,
              'Período',
              quote.periodDisplay,
            ),
            const SizedBox(height: 4),
          ],

          // Fecha de vencimiento
          _buildDetailRow(
            Icons.schedule,
            'Vencimiento',
            quote.formattedDueDate,
            textColor: quote.isOverdue ? Colors.red : null,
          ),

          // Fecha de pago si está pagada
          if (quote.isPaid && quote.paidDate != null) ...[
            const SizedBox(height: 4),
            _buildDetailRow(
              Icons.check_circle,
              'Pagado el',
              quote.formattedPaidDate,
              textColor: Colors.green,
            ),
          ],

          // Información de la propiedad
          if (quote.propertyName != null) ...[
            const SizedBox(height: 4),
            _buildDetailRow(
              Icons.home,
              'Propiedad',
              quote.propertyName!,
            ),
          ],

          // Información de reserva si existe
          if (quote.reservationInfo != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reserva de ${quote.reservationInfo!.commonAreaName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(quote.reservationInfo!.reservationDate)} • ${quote.reservationInfo!.startTime} - ${quote.reservationInfo!.endTime}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          // Acciones si está pendiente
          if (quote.isPending || quote.isOverdue) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ShadcnButton(
                    text: 'Pagar Ahora',
                    onPressed: () => _payQuote(quote),
                    backgroundColor: const Color(0xFF18181B),
                    textColor: Colors.white,
                    icon: Icons.payment,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textColor ?? const Color(0xFF71717A),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF71717A),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor ?? const Color(0xFF09090B),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _payQuote(PropertyQuote quote) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(quote: quote),
      ),
    );
    
    // Si el pago fue exitoso, recargar la lista
    if (result == true) {
      _loadQuotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pago procesado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}