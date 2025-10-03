import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../core/services/task_service.dart';
import '../tasks/task_list_screen.dart';

class RoleAdmin extends StatefulWidget {
  const RoleAdmin({super.key});

  @override
  State<RoleAdmin> createState() => _RoleAdminState();
}

class _RoleAdminState extends State<RoleAdmin> {
  final TaskService _taskService = TaskService();
  List<Task> _recentTasks = [];
  bool _isLoadingTasks = true;
  int _totalTasks = 0;
  int _pendingTasks = 0;
  int _overdueTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadTasksOverview();
  }

  Future<void> _loadTasksOverview() async {
    setState(() {
      _isLoadingTasks = true;
    });

    try {
      // Cargar tareas recientes
      final recentResponse = await _taskService.getAllTasks(limit: 5);
      if (recentResponse.isSuccess && recentResponse.data != null) {
        setState(() {
          _recentTasks = recentResponse.data!;
        });
      }

      // Cargar estadísticas de tareas
      final allTasksResponse = await _taskService.getAllTasks();
      if (allTasksResponse.isSuccess && allTasksResponse.data != null) {
        final allTasks = allTasksResponse.data!;
        setState(() {
          _totalTasks = allTasks.length;
          _pendingTasks = allTasks.where((t) => t.status == 'pending').length;
          _overdueTasks = allTasks.where((t) => t.isOverdue).length;
        });
      }
    } catch (e) {
      debugPrint('Error loading tasks overview: $e');
    } finally {
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Administración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Estadísticas de tareas
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Estadísticas de Tareas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TaskListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Ver todas'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_isLoadingTasks)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTaskStatItem('Total de Tareas', _totalTasks.toString(), Icons.task_alt, const Color(0xFF3992FF)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTaskStatItem('Pendientes', _pendingTasks.toString(), Icons.pending, const Color(0xFFFECC1B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTaskStatItem('Vencidas', _overdueTasks.toString(), Icons.warning, const Color(0xFFF44250)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTaskStatItem('Completadas', (_totalTasks - _pendingTasks).toString(), Icons.check_circle, const Color(0xFF6BD968)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Tareas recientes
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Tareas Recientes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadTasksOverview,
                      icon: const Icon(Icons.refresh),
                      color: const Color(0xFF71717A),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_isLoadingTasks)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_recentTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No hay tareas recientes',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: _recentTasks.map((task) => _buildRecentTaskItem(task)).toList(),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Grid de opciones administrativas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildAdminCard(
                context,
                'Gestión de Tareas',
                'Ver y gestionar todas las tareas',
                Icons.task_alt,
                const Color(0xFF3992FF),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TaskListScreen(),
                    ),
                  );
                },
              ),
              _buildAdminCard(
                context,
                'Usuarios',
                'Gestionar usuarios del sistema',
                Icons.people,
                Colors.blue,
                () => _showComingSoon(context, 'Gestión de Usuarios'),
              ),
              _buildAdminCard(
                context,
                'Propiedades',
                'Administrar propiedades',
                Icons.home,
                Colors.green,
                () => _showComingSoon(context, 'Gestión de Propiedades'),
              ),
              _buildAdminCard(
                context,
                'Pagos',
                'Control de pagos y cuotas',
                Icons.payment,
                Colors.orange,
                () => _showComingSoon(context, 'Gestión de Pagos'),
              ),
              _buildAdminCard(
                context,
                'Reportes',
                'Generar reportes del sistema',
                Icons.analytics,
                Colors.purple,
                () => _showComingSoon(context, 'Reportes'),
              ),
              _buildAdminCard(
                context,
                'Configuración',
                'Configuración del sistema',
                Icons.settings,
                Colors.grey,
                () => _showComingSoon(context, 'Configuración'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Estadísticas generales del sistema
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas del Sistema',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Usuarios Activos', '45', Icons.person),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem('Propiedades', '128', Icons.home),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Pagos Pendientes', '12', Icons.pending),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem('Reservas Hoy', '3', Icons.event),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isOverdue 
              ? const Color(0xFFF44250).withOpacity(0.3)
              : const Color(0xFFE4E4E7),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TaskListScreen(),
            ),
          );
        },
        child: Row(
          children: [
            // Indicador de prioridad
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.userName,
                    style: const TextStyle(
                      color: Color(0xFF71717A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Estado y fecha
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(task.status),
                const SizedBox(height: 4),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(
                    fontSize: 10,
                    color: task.isOverdue 
                        ? const Color(0xFFF44250)
                        : const Color(0xFF71717A),
                    fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return const Color(0xFFF44250);
      case 'high':
        return const Color(0xFFFF8A00);
      case 'medium':
        return const Color(0xFF3992FF);
      case 'low':
        return const Color(0xFF71717A);
      default:
        return const Color(0xFF71717A);
    }
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}