import 'package:flutter/material.dart';
import '../../core/services/task_service.dart';
import '../../widgets/common_widgets.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _taskService.getAllTasks(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _tasks = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar tareas: $e';
        _isLoading = false;
      });
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
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Gestión de Tareas',
          style: TextStyle(
            color: Color(0xFF09090B),
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE4E4E7),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            color: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'Todas'),
                        const SizedBox(width: 8),
                        _buildFilterChip('pending', 'Pendientes'),
                        const SizedBox(width: 8),
                        _buildFilterChip('in_progress', 'En Progreso'),
                        const SizedBox(width: 8),
                        _buildFilterChip('completed', 'Completadas'),
                        const SizedBox(width: 8),
                        _buildFilterChip('cancelled', 'Canceladas'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _loadTasks,
                  icon: const Icon(Icons.refresh),
                  color: const Color(0xFF18181B),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: const Color(0xFFE4E4E7),
          ),

          // Contenido
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _loadTasks();
      },
      backgroundColor: Colors.transparent,
      selectedColor: const Color(0xFF18181B).withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected 
            ? const Color(0xFF18181B)
            : const Color(0xFF71717A),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected 
            ? const Color(0xFF18181B)
            : const Color(0xFFE4E4E7),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF18181B),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: CustomCard(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFF44250),
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF09090B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTasks,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(
        child: CustomCard(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.task_alt,
                size: 48,
                color: Color(0xFF71717A),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay tareas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF09090B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No se encontraron tareas con los filtros seleccionados.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF71717A),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      color: const Color(0xFF18181B),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildTaskCard(_tasks[index]),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return InkWell(
      onTap: () => _showTaskDetail(task),
      borderRadius: BorderRadius.circular(12),
      child: CustomCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y estado
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF09090B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(task.status),
              ],
            ),
            const SizedBox(height: 8),

            // Usuario asignado
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: Color(0xFF71717A),
                ),
                const SizedBox(width: 4),
                Text(
                  task.userName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF71717A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Descripción
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF71717A),
              ),
            ),
            const SizedBox(height: 12),

            // Footer con fecha y prioridad
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: task.isOverdue 
                      ? const Color(0xFFF44250)
                      : const Color(0xFF71717A),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: task.isOverdue 
                        ? const Color(0xFFF44250)
                        : const Color(0xFF71717A),
                    fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                _buildPriorityChip(task.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = const Color(0xFFFECC1B);
        label = 'Pendiente';
        break;
      case 'in_progress':
        color = const Color(0xFF3992FF);
        label = 'En Progreso';
        break;
      case 'completed':
        color = const Color(0xFF6BD968);
        label = 'Completada';
        break;
      case 'cancelled':
        color = const Color(0xFF71717A);
        label = 'Cancelada';
        break;
      default:
        color = const Color(0xFF71717A);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    IconData icon;
    String label;

    switch (priority) {
      case 'urgent':
        color = const Color(0xFFF44250);
        icon = Icons.priority_high;
        label = 'Urgente';
        break;
      case 'high':
        color = const Color(0xFFFF8A00);
        icon = Icons.keyboard_arrow_up;
        label = 'Alta';
        break;
      case 'medium':
        color = const Color(0xFF3992FF);
        icon = Icons.remove;
        label = 'Media';
        break;
      case 'low':
        color = const Color(0xFF71717A);
        icon = Icons.keyboard_arrow_down;
        label = 'Baja';
        break;
      default:
        color = const Color(0xFF71717A);
        icon = Icons.remove;
        label = priority;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return 'En ${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return 'En ${difference.inMinutes}min';
      } else {
        return 'Ahora';
      }
    } else if (difference.inDays > 0) {
      return 'En ${difference.inDays} días';
    } else {
      return 'Hace ${difference.inDays.abs()} días';
    }
  }

  void _showTaskDetail(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailModal(task: task),
    ).then((_) {
      // Recargar tareas cuando se cierre el modal
      _loadTasks();
    });
  }
}

class TaskDetailModal extends StatefulWidget {
  final Task task;

  const TaskDetailModal({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal> {
  final TaskService _taskService = TaskService();
  bool _isCompletingTask = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E4E7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE4E4E7),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalle de Tarea',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF09090B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF71717A),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y estado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF09090B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusChip(widget.task.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Usuario asignado
                  _buildDetailItem(
                    icon: Icons.person,
                    label: 'Asignado a',
                    value: widget.task.userName,
                  ),
                  const SizedBox(height: 16),

                  // Fecha límite
                  _buildDetailItem(
                    icon: Icons.schedule,
                    label: 'Fecha límite',
                    value: _formatFullDate(widget.task.dueDate),
                    isOverdue: widget.task.isOverdue,
                  ),
                  const SizedBox(height: 16),

                  // Prioridad
                  Row(
                    children: [
                      const Icon(
                        Icons.flag,
                        size: 20,
                        color: Color(0xFF71717A),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Prioridad',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF71717A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPriorityChip(widget.task.priority),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF09090B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.task.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF09090B),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notas (si existen)
                  if (widget.task.notes != null && widget.task.notes!.isNotEmpty) ...[
                    Text(
                      'Notas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF09090B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.task.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF09090B),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Fechas de creación y completado
                  _buildDetailItem(
                    icon: Icons.add_circle_outline,
                    label: 'Creada el',
                    value: _formatFullDate(widget.task.createdAt),
                  ),
                  
                  if (widget.task.completedAt != null) ...[
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      icon: Icons.check_circle_outline,
                      label: 'Completada el',
                      value: _formatFullDate(widget.task.completedAt!),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Actions
          if (widget.task.status == 'pending' || widget.task.status == 'in_progress')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE4E4E7),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCompletingTask ? null : _completeTask,
                  icon: _isCompletingTask
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isCompletingTask ? 'Completando...' : 'Marcar como Completada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BD968),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isOverdue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isOverdue ? const Color(0xFFF44250) : const Color(0xFF71717A),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isOverdue ? const Color(0xFFF44250) : const Color(0xFF09090B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = const Color(0xFFFECC1B);
        label = 'Pendiente';
        break;
      case 'in_progress':
        color = const Color(0xFF3992FF);
        label = 'En Progreso';
        break;
      case 'completed':
        color = const Color(0xFF6BD968);
        label = 'Completada';
        break;
      case 'cancelled':
        color = const Color(0xFF71717A);
        label = 'Cancelada';
        break;
      default:
        color = const Color(0xFF71717A);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    IconData icon;
    String label;

    switch (priority) {
      case 'urgent':
        color = const Color(0xFFF44250);
        icon = Icons.priority_high;
        label = 'Urgente';
        break;
      case 'high':
        color = const Color(0xFFFF8A00);
        icon = Icons.keyboard_arrow_up;
        label = 'Alta';
        break;
      case 'medium':
        color = const Color(0xFF3992FF);
        icon = Icons.remove;
        label = 'Media';
        break;
      case 'low':
        color = const Color(0xFF71717A);
        icon = Icons.keyboard_arrow_down;
        label = 'Baja';
        break;
      default:
        color = const Color(0xFF71717A);
        icon = Icons.remove;
        label = priority;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _completeTask() async {
    setState(() {
      _isCompletingTask = true;
    });

    try {
      final response = await _taskService.completeTask(widget.task.id);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tarea marcada como completada'),
              backgroundColor: const Color(0xFF6BD968),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: const Color(0xFFF44250),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFF44250),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingTask = false;
        });
      }
    }
  }
}