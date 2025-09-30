import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';

class RoleResident extends StatelessWidget {
  const RoleResident({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          
          // Información de la propiedad
          CustomCard(
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
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apartamento: 12B', style: Theme.of(context).textTheme.bodyLarge),
                          Text('Torre: Norte', style: Theme.of(context).textTheme.bodyMedium),
                          Text('Área: 85 m²', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Al día',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Servicios disponibles
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildServiceCard(
                context,
                'Pagos',
                'Ver y pagar cuotas',
                Icons.payment,
                Colors.blue,
                () => _showComingSoon(context, 'Pagos'),
              ),
              _buildServiceCard(
                context,
                'Reservas',
                'Reservar áreas comunes',
                Icons.event_available,
                Colors.green,
                () => _showComingSoon(context, 'Reservas'),
              ),
              _buildServiceCard(
                context,
                'Visitantes',
                'Registrar visitantes',
                Icons.person_add,
                Colors.orange,
                () => _showComingSoon(context, 'Visitantes'),
              ),
              _buildServiceCard(
                context,
                'Comunicados',
                'Ver anuncios',
                Icons.announcement,
                Colors.purple,
                () => _showComingSoon(context, 'Comunicados'),
              ),
              _buildServiceCard(
                context,
                'Vehículos',
                'Gestionar vehículos',
                Icons.directions_car,
                Colors.teal,
                () => _showComingSoon(context, 'Vehículos'),
              ),
              _buildServiceCard(
                context,
                'Mascotas',
                'Registrar mascotas',
                Icons.pets,
                Colors.brown,
                () => _showComingSoon(context, 'Mascotas'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Último pago y próximo vencimiento
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Cuenta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildAccountInfo(
                        'Último Pago',
                        '\$250.00',
                        '15 Sep 2024',
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAccountInfo(
                        'Próximo Pago',
                        '\$250.00',
                        '15 Oct 2024',
                        Colors.orange,
                        Icons.schedule,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Noticias o comunicados recientes
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comunicados Recientes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showComingSoon(context, 'Ver todos los comunicados'),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _buildCommunicationItem(
                  'Mantenimiento del ascensor programado',
                  'El próximo lunes se realizará...',
                  '2 días',
                ),
                const Divider(),
                _buildCommunicationItem(
                  'Nueva normativa para visitantes',
                  'A partir del 1 de octubre...',
                  '1 semana',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
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
              size: 28,
              color: color,
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
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

  Widget _buildAccountInfo(
    String label,
    String amount,
    String date,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            date,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationItem(String title, String preview, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
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