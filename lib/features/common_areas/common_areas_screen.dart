import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../core/services/common_area_service.dart';
import '../../core/models/common_area.dart';
import 'common_area_detail_screen.dart';

class CommonAreasScreen extends StatefulWidget {
  const CommonAreasScreen({super.key});

  @override
  State<CommonAreasScreen> createState() => _CommonAreasScreenState();
}

class _CommonAreasScreenState extends State<CommonAreasScreen> {
  final CommonAreaService _commonAreaService = CommonAreaService();
  
  List<CommonArea> _commonAreas = [];
  List<CommonArea> _filteredAreas = [];
  
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  bool _showOnlyReservable = false;

  @override
  void initState() {
    super.initState();
    _loadCommonAreas();
  }

  Future<void> _loadCommonAreas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final areas = await _commonAreaService.getAllCommonAreas(activeOnly: true);
      
      if (mounted) {
        setState(() {
          _commonAreas = areas;
          _filteredAreas = areas;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAreas = _commonAreas.where((area) {
        final matchesSearch = area.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             (area.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        final matchesReservable = !_showOnlyReservable || area.isReservable;
        
        return matchesSearch && matchesReservable;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _toggleReservableFilter() {
    setState(() {
      _showOnlyReservable = !_showOnlyReservable;
    });
    _applyFilters();
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
          'Áreas Comunes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF09090B),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyReservable ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showOnlyReservable ? const Color(0xFF18181B) : const Color(0xFF71717A),
            ),
            onPressed: _toggleReservableFilter,
            tooltip: 'Solo reservables',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommonAreas,
            color: const Color(0xFF18181B),
          ),
        ],
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
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFFFFFF),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar áreas comunes...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF71717A)),
                filled: true,
                fillColor: const Color(0xFFF4F4F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: _isLoading 
                ? _buildLoadingView()
                : _error != null
                    ? _buildErrorView()
                    : _buildAreasList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF18181B)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando áreas comunes...',
            style: TextStyle(
              color: Color(0xFF71717A),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
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
              'Error al cargar las áreas comunes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ShadcnButton(
              text: 'Reintentar',
              onPressed: _loadCommonAreas,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreasList() {
    if (_filteredAreas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.location_city_outlined,
                size: 64,
                color: const Color(0xFF71717A),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty 
                    ? 'No se encontraron áreas comunes'
                    : 'No hay áreas comunes disponibles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF71717A),
                ),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Intenta con otros términos de búsqueda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF71717A),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommonAreas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAreas.length,
        itemBuilder: (context, index) {
          final area = _filteredAreas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAreaCard(area),
          );
        },
      ),
    );
  }

  Widget _buildAreaCard(CommonArea area) {
    return CustomCard(
      onTap: () => _navigateToAreaDetail(area),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre y estado
          Row(
            children: [
              Expanded(
                child: Text(
                  area.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!area.isReservable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'No Reservable',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (area.isFree)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Gratis',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          if (area.description != null && area.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              area.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF71717A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Información básica en grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.people,
                  'Capacidad',
                  area.capacityText,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.attach_money,
                  'Costo',
                  area.formattedCost,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.schedule,
                  'Horario',
                  area.availabilitySchedule,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today,
                  'Días',
                  area.availableDaysText,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botón de acción
          Row(
            children: [
              const Spacer(),
              ShadcnButton(
                text: 'Ver Detalles',
                onPressed: () => _navigateToAreaDetail(area),
                backgroundColor: const Color(0xFF18181B),
                textColor: Colors.white,
                icon: Icons.arrow_forward,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF71717A),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF71717A),
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToAreaDetail(CommonArea area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommonAreaDetailScreen(commonArea: area),
      ),
    );
  }
}