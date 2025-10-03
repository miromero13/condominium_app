import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../core/services/property_service.dart';
import '../../core/models/property.dart';

class RoleResident extends StatefulWidget {
  const RoleResident({super.key});

  @override
  State<RoleResident> createState() => _RoleResidentState();
}

class _RoleResidentState extends State<RoleResident> {
  final PropertyService _propertyService = PropertyService();
  DashboardInfo? _dashboardInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dashboardInfo = await _propertyService.getDashboardInfo();
      
      if (mounted) {
        setState(() {
          _dashboardInfo = dashboardInfo;
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
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal del Residente',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            if (_isLoading)
              _buildLoadingSkeleton()
            else if (_error != null)
              _buildErrorCard()
            else if (_dashboardInfo == null)
              _buildNoPropertyCard()
            else
              _buildPropertyInfo(),
              
            const SizedBox(height: 24),
            
            // Estadísticas rápidas
            if (_dashboardInfo != null && !_isLoading) ...[
              _buildStatsRow(),
              const SizedBox(height: 24),
            ],
            
            // Información de próximo pago si existe
            if (_dashboardInfo?.paymentStats.hasPendingPayments ?? false) ...[
              _buildSectionTitle('Próximo Pago'),
              const SizedBox(height: 12),
              _buildNextPaymentCard(),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        // Skeleton para la información de la propiedad
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y título
              Row(
                children: [
                  _buildShimmerBox(width: 24, height: 24, borderRadius: 4),
                  const SizedBox(width: 8),
                  _buildShimmerBox(width: 120, height: 16, borderRadius: 4),
                  const Spacer(),
                  _buildShimmerBox(width: 80, height: 20, borderRadius: 10),
                ],
              ),
              const SizedBox(height: 16),
              
              // Nombre de la propiedad
              _buildShimmerBox(width: 200, height: 24, borderRadius: 4),
              const SizedBox(height: 12),
              
              // Detalles de la propiedad
              _buildDetailRowSkeleton(),
              const SizedBox(height: 8),
              _buildDetailRowSkeleton(),
              const SizedBox(height: 8),
              _buildDetailRowSkeleton(),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Skeleton para las estadísticas
        Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRowSkeleton() {
    return Row(
      children: [
        _buildShimmerBox(width: 16, height: 16, borderRadius: 4),
        const SizedBox(width: 8),
        _buildShimmerBox(width: 60, height: 14, borderRadius: 4),
        const SizedBox(width: 8),
        Expanded(
          child: _buildShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
        ),
      ],
    );
  }

  Widget _buildStatCardSkeleton() {
    return CustomCard(
      child: Column(
        children: [
          _buildShimmerBox(width: 24, height: 24, borderRadius: 4),
          const SizedBox(height: 8),
          _buildShimmerBox(width: 32, height: 28, borderRadius: 4),
          const SizedBox(height: 4),
          _buildShimmerBox(width: 80, height: 12, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildErrorCard() {
    return CustomCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar los datos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Error desconocido',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ShadcnButton(
            text: 'Reintentar',
            onPressed: _loadDashboardData,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildNoPropertyCard() {
    return CustomCard(
      child: Column(
        children: [
          Icon(
            Icons.home_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin propiedad asignada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes ninguna propiedad asignada en este momento.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfo() {
    final property = _dashboardInfo!.property;
    final userInfo = _dashboardInfo!.userInfo;
    
    if (property == null) {
      return _buildNoPropertyCard();
    }
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Mi Propiedad',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(property.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  property.statusDisplay,
                  style: TextStyle(
                    color: _getStatusColor(property.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Información básica
          Text(
            property.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          _buildDetailRow(Icons.location_on, 'Dirección', property.displayAddress),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.person, 'Rol', userInfo.primaryRole),
          
          if (property.buildingOrBlock != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.business, 'Bloque', property.buildingOrBlock!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.payment,
            'Pagos Pendientes',
            _dashboardInfo!.paymentStats.pendingQuotesCount.toString(),
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.calendar_today,
            'Reservas Activas',
            _dashboardInfo!.reservationStats.activeReservationsCount.toString(),
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return CustomCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNextPaymentCard() {
    final paymentStats = _dashboardInfo!.paymentStats;
    
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payment,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo Pago',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paymentStats.nextPaymentDueDate != null 
                      ? 'Vence: ${_formatDate(paymentStats.nextPaymentDueDate!)}'
                      : 'Sin fecha definida',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '\$${paymentStats.nextPaymentAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return Colors.green;
      case 'rented':
        return Colors.blue;
      case 'available':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}