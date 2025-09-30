import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';

class RoleAdmin extends StatelessWidget {
  const RoleAdmin({super.key});

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
                'Reservas',
                'Gestionar reservas de áreas comunes',
                Icons.event,
                Colors.teal,
                () => _showComingSoon(context, 'Gestión de Reservas'),
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
          
          // Estadísticas rápidas
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}