import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';

class RoleVisitor extends StatelessWidget {
  const RoleVisitor({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portal del Visitante',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Información del visitante
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Información de Visita',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _buildInfoRow('Estado:', 'Autorizado', Colors.green),
                const SizedBox(height: 8),
                _buildInfoRow('Visitando:', 'Apt. 12B - Torre Norte', null),
                const SizedBox(height: 8),
                _buildInfoRow('Válido hasta:', '18:00 - Hoy', null),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Servicios disponibles para visitantes
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildVisitorServiceCard(
                context,
                'Mi Código QR',
                'Mostrar código de acceso',
                Icons.qr_code,
                Colors.blue,
                () => _showQRCode(context),
              ),
              _buildVisitorServiceCard(
                context,
                'Ubicaciones',
                'Mapa del condominio',
                Icons.map,
                Colors.green,
                () => _showComingSoon(context, 'Mapa del condominio'),
              ),
              _buildVisitorServiceCard(
                context,
                'Emergencias',
                'Contactos de emergencia',
                Icons.emergency,
                Colors.red,
                () => _showEmergencyContacts(context),
              ),
              _buildVisitorServiceCard(
                context,
                'Información',
                'Normas del condominio',
                Icons.info,
                Colors.orange,
                () => _showComingSoon(context, 'Normas del condominio'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Normas importantes para visitantes
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rule, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Normas Importantes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildRuleItem(
                  '• Horario de visitas: 8:00 AM - 10:00 PM',
                ),
                _buildRuleItem(
                  '• Debe portar identificación en todo momento',
                ),
                _buildRuleItem(
                  '• No se permite el acceso a áreas comunes sin autorización',
                ),
                _buildRuleItem(
                  '• Respetar las normas de convivencia del condominio',
                ),
                _buildRuleItem(
                  '• En caso de emergencia, dirigirse a la portería',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Información de contacto
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.contact_phone, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Contactos Útiles',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildContactItem('Portería', '(555) 123-4567', Icons.security),
                const SizedBox(height: 12),
                _buildContactItem('Administración', '(555) 123-4568', Icons.business),
                const SizedBox(height: 12),
                _buildContactItem('Emergencias', '911', Icons.emergency),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorServiceCard(
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

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        rule,
        style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildContactItem(String name, String phone, IconData icon) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {
              // TODO: Implementar llamada telefónica
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Llamando a $name...')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mi Código QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 150,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Muestre este código al personal de seguridad',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
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

  void _showEmergencyContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contactos de Emergencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmergencyContact('Bomberos', '911'),
            _buildEmergencyContact('Policía', '911'),
            _buildEmergencyContact('Ambulancia', '911'),
            _buildEmergencyContact('Seguridad del Edificio', '(555) 123-4567'),
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

  Widget _buildEmergencyContact(String name, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.bold),
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