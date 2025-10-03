import 'package:flutter/material.dart';
import '../../core/models/common_area.dart';
import '../../core/services/common_area_service.dart';

class ReservationFormDialog extends StatefulWidget {
  final CommonArea commonArea;
  final DateTime selectedDate;
  final String selectedStartTime;
  final String selectedEndTime;

  const ReservationFormDialog({
    super.key,
    required this.commonArea,
    required this.selectedDate,
    required this.selectedStartTime,
    required this.selectedEndTime,
  });

  @override
  State<ReservationFormDialog> createState() => _ReservationFormDialogState();
}

class _ReservationFormDialogState extends State<ReservationFormDialog> {
  final CommonAreaService _commonAreaService = CommonAreaService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _purposeController;
  late TextEditingController _attendeesController;
  late String _startTime;
  late String _endTime;
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController();
    _attendeesController = TextEditingController(text: '1');
    _startTime = widget.selectedStartTime;
    _endTime = widget.selectedEndTime;
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.event_available,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva Reserva',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.commonArea.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Información de la reserva
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.calendar_today, 'Fecha', _formatDate(widget.selectedDate)),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.access_time, 'Horario', '$_startTime - $_endTime'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.attach_money, 'Costo estimado', _calculateCost()),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Selección de horario extendido
                Text(
                  'Ajustar Horario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector('Hora inicio', _startTime, (time) {
                        setState(() => _startTime = time);
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeSelector('Hora fin', _endTime, (time) {
                        setState(() => _endTime = time);
                      }),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Propósito
                Text(
                  'Propósito de la reserva',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _purposeController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe el motivo de tu reserva...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor describe el propósito de la reserva';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Número de asistentes
                Text(
                  'Número de asistentes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _attendeesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Cantidad de personas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    suffixText: 'personas',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el número de asistentes';
                    }
                    final attendees = int.tryParse(value);
                    if (attendees == null || attendees < 1) {
                      return 'Debe ser un número mayor a 0';
                    }
                    if (attendees > widget.commonArea.capacity) {
                      return 'Máximo ${widget.commonArea.capacity} personas';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Reservar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(String label, String currentTime, Function(String) onTimeChanged) {
    final availableHours = _generateAvailableHours();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: currentTime,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: availableHours.map((hour) {
            return DropdownMenuItem(
              value: hour,
              child: Text(hour),
            );
          }).toList(),
          onChanged: (newTime) {
            if (newTime != null) {
              onTimeChanged(newTime);
            }
          },
        ),
      ],
    );
  }

  List<String> _generateAvailableHours() {
    final startHour = int.parse(widget.commonArea.availableFrom.split(':')[0]);
    final endHour = int.parse(widget.commonArea.availableTo.split(':')[0]);
    
    // Generar horas en intervalos de 2 horas
    List<String> hours = [];
    for (int hour = startHour; hour <= endHour; hour += 2) {
      hours.add('${hour.toString().padLeft(2, '0')}:00');
    }
    return hours;
  }

  String _calculateCost() {
    final startHour = int.parse(_startTime.split(':')[0]);
    final endHour = int.parse(_endTime.split(':')[0]);
    final hours = endHour - startHour;
    final totalCost = hours * widget.commonArea.costPerHour;
    
    return hours > 0 ? '\$${totalCost.toStringAsFixed(2)}' : '\$0.00';
  }

  String _formatDate(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month]} ${date.year}';
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar horarios
    final startHour = int.parse(_startTime.split(':')[0]);
    final endHour = int.parse(_endTime.split(':')[0]);
    
    if (endHour <= startHour) {
      _showErrorSnackBar('La hora de fin debe ser posterior a la hora de inicio');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reservation = await _commonAreaService.createReservation(
        commonAreaId: widget.commonArea.id,
        reservationDate: widget.selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        purpose: _purposeController.text.trim(),
        estimatedAttendees: int.parse(_attendeesController.text),
      );

      if (mounted) {
        Navigator.of(context).pop(reservation);
        _showSuccessSnackBar('Reserva creada exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al crear la reserva: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}