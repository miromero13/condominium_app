import 'package:flutter/material.dart';
import '../../core/models/common_area.dart';
import '../../core/services/common_area_service.dart';

class WeeklyReservationCalendar extends StatefulWidget {
  final CommonArea commonArea;
  final Function(DateTime date, String startTime, String endTime)? onTimeSlotSelected;

  const WeeklyReservationCalendar({
    super.key,
    required this.commonArea,
    this.onTimeSlotSelected,
  });

  @override
  State<WeeklyReservationCalendar> createState() => _WeeklyReservationCalendarState();
}

class _WeeklyReservationCalendarState extends State<WeeklyReservationCalendar> {
  final CommonAreaService _commonAreaService = CommonAreaService();
  DateTime _currentWeekStart = DateTime.now();
  List<Reservation> _weekReservations = [];
  bool _isLoading = false;
  
  // Horarios disponibles (intervalos de 2 horas)
  final List<String> _timeSlots = [
    '06:00', '08:00', '10:00', '12:00', '14:00', '16:00',
    '18:00', '20:00', '22:00'
  ];

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(DateTime.now());
    _loadWeekReservations();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _loadWeekReservations() async {
    setState(() => _isLoading = true);
    
    try {
      final reservations = await _commonAreaService.getCommonAreaReservations(
        widget.commonArea.id,
        status: 'approved',
      );
      
      // Filtrar reservas de la semana actual
      final weekEnd = _currentWeekStart.add(const Duration(days: 7));
      _weekReservations = reservations.where((reservation) {
        return reservation.reservationDate.isAfter(_currentWeekStart.subtract(const Duration(days: 1))) &&
               reservation.reservationDate.isBefore(weekEnd);
      }).toList();
      
    } catch (e) {
      print('Error loading week reservations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con navegación de semana
        _buildWeekHeader(),
        const SizedBox(height: 16),
        
        // Calendario semanal
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          _buildWeekCalendar(),
      ],
    );
  }

  Widget _buildWeekHeader() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
            });
            _loadWeekReservations();
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            '${_formatDate(_currentWeekStart)} - ${_formatDate(weekEnd)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
            });
            _loadWeekReservations();
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header con días de la semana
          _buildDaysHeader(),
          
          // Grid de horarios
          ..._timeSlots.map((timeSlot) => _buildTimeSlotRow(timeSlot)),
        ],
      ),
    );
  }

  Widget _buildDaysHeader() {
    const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          // Columna de tiempo
          Container(
            width: 60,
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Hora',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Columnas de días
          ...List.generate(7, (index) {
            final date = _currentWeekStart.add(Duration(days: index));
            final isToday = _isSameDay(date, DateTime.now());
            
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isToday ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isToday ? Theme.of(context).primaryColor : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(String timeSlot) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Columna de tiempo
          Container(
            width: 60,
            padding: const EdgeInsets.all(8),
            child: Text(
              timeSlot,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Celdas de días
          ...List.generate(7, (dayIndex) {
            final date = _currentWeekStart.add(Duration(days: dayIndex));
            return _buildTimeSlotCell(date, timeSlot);
          }),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCell(DateTime date, String timeSlot) {
    final isAvailable = _isTimeSlotAvailable(date, timeSlot);
    final hasReservation = _hasReservationAt(date, timeSlot);
    final isPastTime = _isPastTime(date, timeSlot);
    final isDayAvailable = _isDayAvailable(date);
    
    Color backgroundColor;
    Color? textColor;
    String? tooltipText;
    
    if (!isDayAvailable) {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade400;
      tooltipText = 'Día no disponible';
    } else if (isPastTime) {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade400;
      tooltipText = 'Horario pasado';
    } else if (hasReservation) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
      tooltipText = 'Reservado';
    } else if (isAvailable) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      tooltipText = 'Disponible';
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade400;
      tooltipText = 'No disponible';
    }

    return Expanded(
      child: GestureDetector(
        onTap: isAvailable && !hasReservation && !isPastTime && isDayAvailable
            ? () => _onTimeSlotTap(date, timeSlot)
            : null,
        child: Tooltip(
          message: tooltipText,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Center(
              child: hasReservation
                  ? Icon(
                      Icons.event,
                      size: 16,
                      color: textColor,
                    )
                  : isAvailable && !isPastTime && isDayAvailable
                      ? Icon(
                          Icons.add,
                          size: 16,
                          color: textColor,
                        )
                      : null,
            ),
          ),
        ),
      ),
    );
  }

  bool _isTimeSlotAvailable(DateTime date, String timeSlot) {
    // Verificar si el horario está dentro del rango disponible del área común
    final hour = int.parse(timeSlot.split(':')[0]);
    final availableFromHour = int.parse(widget.commonArea.availableFrom.split(':')[0]);
    final availableToHour = int.parse(widget.commonArea.availableTo.split(':')[0]);
    
    return hour >= availableFromHour && hour < availableToHour;
  }

  bool _hasReservationAt(DateTime date, String timeSlot) {
    return _weekReservations.any((reservation) {
      if (!_isSameDay(reservation.reservationDate, date)) return false;
      
      final slotHour = int.parse(timeSlot.split(':')[0]);
      final startHour = int.parse(reservation.startTime.split(':')[0]);
      final endHour = int.parse(reservation.endTime.split(':')[0]);
      
      return slotHour >= startHour && slotHour < endHour;
    });
  }

  bool _isPastTime(DateTime date, String timeSlot) {
    final now = DateTime.now();
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeSlot.split(':')[0]),
    );
    
    return slotDateTime.isBefore(now);
  }

  bool _isDayAvailable(DateTime date) {
    final weekday = date.weekday;
    final availability = widget.commonArea.availabilityDays;
    
    switch (weekday) {
      case 1: return availability.monday;
      case 2: return availability.tuesday;
      case 3: return availability.wednesday;
      case 4: return availability.thursday;
      case 5: return availability.friday;
      case 6: return availability.saturday;
      case 7: return availability.sunday;
      default: return false;
    }
  }

  void _onTimeSlotTap(DateTime date, String startTime) {
    // Calcular hora de fin (por defecto 2 horas)
    final startHour = int.parse(startTime.split(':')[0]);
    final endTime = '${(startHour + 2).toString().padLeft(2, '0')}:00';
    
    if (widget.onTimeSlotSelected != null) {
      widget.onTimeSlotSelected!(date, startTime, endTime);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month]}';
  }
}