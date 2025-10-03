import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../core/models/common_area.dart';
import 'weekly_reservation_calendar.dart';
import 'reservation_form_dialog.dart';

class CreateReservationScreen extends StatefulWidget {
  final CommonArea commonArea;

  const CreateReservationScreen({
    super.key,
    required this.commonArea,
  });

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Nueva Reserva',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del área común
            CustomCard(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.place,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.commonArea.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Capacidad: ${widget.commonArea.capacityText}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Costo: ${widget.commonArea.formattedCost}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona tu horario',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cada slot representa 2 horas. Selecciona un horario disponible (verde) para continuar con tu reserva.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Calendario semanal
            WeeklyReservationCalendar(
              commonArea: widget.commonArea,
              onTimeSlotSelected: _onTimeSlotSelected,
            ),
            
            const SizedBox(height: 20),
            
            // Leyenda
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leyenda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildLegendItem(Colors.green.shade50, Colors.green.shade700, 'Disponible'),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.red.shade100, Colors.red.shade700, 'Ocupado'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(Colors.grey.shade200, Colors.grey.shade400, 'No disponible'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color backgroundColor, Color iconColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            Icons.add,
            size: 12,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _onTimeSlotSelected(DateTime date, String startTime, String endTime) {
    showDialog(
      context: context,
      builder: (context) => ReservationFormDialog(
        commonArea: widget.commonArea,
        selectedDate: date,
        selectedStartTime: startTime,
        selectedEndTime: endTime,
      ),
    ).then((result) {
      if (result != null) {
        // Reserva creada exitosamente, regresar a la pantalla anterior
        Navigator.of(context).pop(true);
      }
    });
  }
}