import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';

class RoleGuest extends StatelessWidget {
  const RoleGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso de Invitado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Mensaje de bienvenida
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Información General',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Bienvenido al sistema del condominio. Como invitado, tienes acceso limitado a información pública.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Opciones disponibles para invitados
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildGuestServiceCard(
                context,
                'Información',
                'Datos del condominio',
                Icons.info_outline,
                Colors.blue,
                () => _showCondominiumInfo(context),
              ),
              _buildGuestServiceCard(
                context,
                'Contactos',
                'Información de contacto',
                Icons.contact_phone,
                Colors.green,
                () => _showContactInfo(context),
              ),
              _buildGuestServiceCard(
                context,
                'Ubicación',
                'Cómo llegar',
                Icons.location_on,
                Colors.orange,
                () => _showComingSoon(context, 'Información de ubicación'),
              ),
              _buildGuestServiceCard(
                context,
                'Registro',
                'Solicitar acceso',
                Icons.person_add,
                Colors.purple,
                () => _showRegistrationInfo(context),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Información general del condominio
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Condominio Torres del Norte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem(Icons.apartment, 'Apartamentos', '128 unidades en 2 torres'),
                _buildInfoItem(Icons.pool, 'Amenidades', 'Piscina, gimnasio, área social'),
                _buildInfoItem(Icons.security, 'Seguridad', '24/7 vigilancia y portería'),
                _buildInfoItem(Icons.local_parking, 'Estacionamiento', 'Privado y para visitantes'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Horarios de atención
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Horarios de Atención',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildScheduleItem('Portería', 'Lunes a Domingo', '24 horas'),
                _buildScheduleItem('Administración', 'Lunes a Viernes', '8:00 AM - 5:00 PM'),
                _buildScheduleItem('Visitas', 'Todos los días', '8:00 AM - 10:00 PM'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestServiceCard(
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String service, String days, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              service,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(days),
                Text(
                  hours,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCondominiumInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Condominio'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Condominio Torres del Norte'),
              SizedBox(height: 8),
              Text('Dirección: Av. Principal 123, Ciudad'),
              SizedBox(height: 8),
              Text('Construido: 2020'),
              SizedBox(height: 8),
              Text('Torres: 2 (Norte y Sur)'),
              SizedBox(height: 8),
              Text('Pisos por torre: 16'),
              SizedBox(height: 8),
              Text('Apartamentos por piso: 4'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Contacto'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Administración:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('admin@toresdelnorte.com'),
            Text('(555) 123-4568'),
            SizedBox(height: 12),
            Text('Portería:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('porteria@toresdelnorte.com'),
            Text('(555) 123-4567'),
            SizedBox(height: 12),
            Text('Emergencias:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('911'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Acceso'),
        content: const Text(
          'Para obtener acceso al sistema como residente o visitante, '
          'póngase en contacto con la administración del condominio.\n\n'
          'Teléfono: (555) 123-4568\n'
          'Email: admin@toresdelnorte.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
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