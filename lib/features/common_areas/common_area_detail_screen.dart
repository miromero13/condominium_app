import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../core/services/common_area_service.dart';
import '../../core/models/common_area.dart';
import 'create_reservation_screen.dart';

class CommonAreaDetailScreen extends StatefulWidget {
  final CommonArea commonArea;

  const CommonAreaDetailScreen({
    super.key,
    required this.commonArea,
  });

  @override
  State<CommonAreaDetailScreen> createState() => _CommonAreaDetailScreenState();
}

class _CommonAreaDetailScreenState extends State<CommonAreaDetailScreen>
    with SingleTickerProviderStateMixin {
  final CommonAreaService _commonAreaService = CommonAreaService();
  late TabController _tabController;
  
  List<CommonAreaRule> _rules = [];
  List<Reservation> _reservations = [];
  
  bool _isLoadingRules = true;
  bool _isLoadingReservations = true;
  String? _rulesError;
  String? _reservationsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdditionalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdditionalData() async {
    await Future.wait([
      _loadRules(),
      _loadReservations(),
    ]);
  }

  Future<void> _loadRules() async {
    try {
      setState(() {
        _isLoadingRules = true;
        _rulesError = null;
      });

      final rules = await _commonAreaService.getCommonAreaRules(widget.commonArea.id);
      
      if (mounted) {
        setState(() {
          _rules = rules;
          _isLoadingRules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rulesError = e.toString();
          _isLoadingRules = false;
        });
      }
    }
  }

  Future<void> _loadReservations() async {
    try {
      setState(() {
        _isLoadingReservations = true;
        _reservationsError = null;
      });

      final reservations = await _commonAreaService.getCommonAreaReservations(widget.commonArea.id);
      
      if (mounted) {
        setState(() {
          _reservations = reservations;
          _isLoadingReservations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reservationsError = e.toString();
          _isLoadingReservations = false;
        });
      }
    }
  }

  void _navigateToCreateReservation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReservationScreen(
          commonArea: widget.commonArea,
        ),
      ),
    );
    
    if (result == true) {
      // Recargar las reservas si se creó una nueva
      _loadReservations();
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
          widget.commonArea.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF18181B),
          unselectedLabelColor: const Color(0xFF71717A),
          indicatorColor: const Color(0xFF18181B),
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              text: 'Información',
              icon: Icon(Icons.info_outline, size: 20),
            ),
            Tab(
              text: 'Reglas',
              icon: Icon(Icons.rule, size: 20),
            ),
            Tab(
              text: 'Reservas',
              icon: Icon(Icons.event, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildRulesTab(),
          _buildReservationsTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información básica
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Información General',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.commonArea.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Inactiva',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                if (widget.commonArea.description != null && widget.commonArea.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.commonArea.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Información detallada
                _buildDetailRow(Icons.people, 'Capacidad', widget.commonArea.capacityText),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.attach_money, 'Costo por hora', widget.commonArea.formattedCost),
                const SizedBox(height: 8),
                _buildDetailRow(
                  widget.commonArea.isReservable ? Icons.check_circle : Icons.cancel,
                  'Reservable',
                  widget.commonArea.isReservable ? 'Sí' : 'No',
                  valueColor: widget.commonArea.isReservable ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Horarios y disponibilidad
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Horarios y Disponibilidad',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildDetailRow(Icons.access_time, 'Horario disponible', widget.commonArea.availabilitySchedule),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today, 'Días disponibles', widget.commonArea.availableDaysText),
                
                const SizedBox(height: 16),
                
                // Días de la semana con indicadores
                _buildWeekDaysIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    if (_isLoadingRules) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF18181B)),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando reglas...',
              style: TextStyle(color: Color(0xFF71717A)),
            ),
          ],
        ),
      );
    }

    if (_rulesError != null) {
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
                'Error al cargar las reglas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _rulesError!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ShadcnButton(
                text: 'Reintentar',
                onPressed: _loadRules,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      );
    }

    if (_rules.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rule,
                size: 64,
                color: Color(0xFF71717A),
              ),
              SizedBox(height: 16),
              Text(
                'No hay reglas específicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF71717A),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Esta área común no tiene reglas específicas definidas.',
                style: TextStyle(color: Color(0xFF71717A)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rules.length,
      itemBuilder: (context, index) {
        final rule = _rules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rule.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReservationsTab() {
    if (!widget.commonArea.isReservable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Área no reservable',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta área común no permite reservas',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingReservations) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF18181B)),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando reservas...',
              style: TextStyle(color: Color(0xFF71717A)),
            ),
          ],
        ),
      );
    }

    if (_reservationsError != null) {
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
                'Error al cargar las reservas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _reservationsError!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ShadcnButton(
                text: 'Reintentar',
                onPressed: _loadReservations,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Contenido principal
        _reservations.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No tienes reservas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aún no has realizado ninguna reserva para esta área común. ¡Haz tu primera reserva!',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadReservations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReservationCard(reservation),
                    );
                  },
                ),
              ),
        
        // Botón flotante
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _navigateToCreateReservation,
            backgroundColor: const Color(0xFF18181B),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Nueva Reserva',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getReservationStatusColor(reservation.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  reservation.statusDisplay,
                  style: TextStyle(
                    color: _getReservationStatusColor(reservation.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                reservation.formattedCost,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(Icons.calendar_today, 'Fecha', reservation.formattedDate),
          const SizedBox(height: 4),
          _buildDetailRow(Icons.schedule, 'Horario', reservation.formattedTimeRange),
          const SizedBox(height: 4),
          _buildDetailRow(Icons.access_time, 'Duración', '${reservation.totalHours} horas'),
          
          if (reservation.purpose != null && reservation.purpose!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Propósito:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF71717A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reservation.purpose!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Color _getReservationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
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
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDaysIndicator() {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final availability = widget.commonArea.availabilityDays;
    final dayAvailability = [
      availability.monday,
      availability.tuesday,
      availability.wednesday,
      availability.thursday,
      availability.friday,
      availability.saturday,
      availability.sunday,
    ];

    return Row(
      children: List.generate(7, (index) {
        final isAvailable = dayAvailability[index];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isAvailable 
                  ? const Color(0xFF18181B).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              days[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isAvailable 
                    ? const Color(0xFF18181B)
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }

}