import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flood_data_provider.dart';
import '../models/water_level_model.dart';

class FloodMonitorScreen extends StatefulWidget {
  const FloodMonitorScreen({Key? key}) : super(key: key);

  @override
  State<FloodMonitorScreen> createState() => _FloodMonitorScreenState();
}

class _FloodMonitorScreenState extends State<FloodMonitorScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All', 'Critical', 'Warning', 'Normal', 'Rising', 'Falling'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<FloodDataProvider>(context, listen: false);
    await provider.loadFloodData();

    // DEBUG: Print first few water levels to see what data we have
    if (provider.waterLevels.isNotEmpty) {
      print('🔍 DEBUG: First 3 water levels:');
      for (int i = 0; i < provider.waterLevels.length && i < 3; i++) {
        final wl = provider.waterLevels[i];
        print('  ${i + 1}. ${wl.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Monitoring'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          // DEBUG button to show raw data
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildDataSummary(), // Show summary of loaded data
          Expanded(
            child: _buildStationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummary() {
    return Consumer<FloodDataProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Stations: ${provider.stations.length}'),
              Text('Water Levels: ${provider.waterLevels.length}'),
              Text('Forecasts: ${provider.forecasts.length}'),
              if (provider.usingMockData)
                const Text('📋 DEMO MODE', 
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by station, river, or district...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
                print('🔍 Search query: "$_searchQuery"'); // DEBUG
              });
            },
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? filter : 'All';
                        print('🔍 Filter: $_selectedFilter'); // DEBUG
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationList() {
    return Consumer<FloodDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.waterLevels.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading flood monitoring data...'),
              ],
            ),
          );
        }

        if (provider.error != null && provider.waterLevels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredStations = _filterStations(provider.waterLevels);
        print('🔍 DEBUG: Total stations: ${provider.waterLevels.length}, Filtered: ${filteredStations.length}'); // DEBUG

        if (filteredStations.isEmpty && provider.waterLevels.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No stations match your search criteria'),
                const SizedBox(height: 16),
                Text('Search: "$_searchQuery"'),
                Text('Filter: $_selectedFilter'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedFilter = 'All';
                    });
                  },
                  child: const Text('Clear Search'),
                ),
              ],
            ),
          );
        }

        if (provider.waterLevels.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No water level data available'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredStations.length,
            itemBuilder: (context, index) {
              final station = filteredStations[index];
              return _buildStationCard(station);
            },
          ),
        );
      },
    );
  }

  Widget _buildStationCard(WaterLevel station) {
    final alertColor = _getAlertColor(station);
    final alertIcon = _getAlertIcon(station);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showStationDetails(station),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with station name and alert status
              Row(
                children: [
                  Icon(alertIcon, color: alertColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.stationName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${station.riverName} River',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (station.division != null)
                          Text(
                            '${station.division}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: alertColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: alertColor),
                    ),
                    child: Text(
                      station.alertLevel,
                      style: TextStyle(
                        color: alertColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Water level information
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Current Level',
                      '${station.currentLevel.toStringAsFixed(2)}m',
                      Icons.water,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Danger Level',
                      '${station.dangerLevel.toStringAsFixed(2)}m',
                      Icons.warning,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Status',
                      '${station.statusCm > 0 ? '+' : ''}${station.statusCm}cm',
                      station.statusCm > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Trend indicator
              Row(
                children: [
                  Icon(
                    _getTrendIcon(station.trend),
                    size: 16,
                    color: _getTrendColor(station.trend),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trend: ${station.trend}',
                    style: TextStyle(
                      color: _getTrendColor(station.trend),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Updated: ${_formatTime(station.timestamp)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<WaterLevel> _filterStations(List<WaterLevel> stations) {
    print('🔍 DEBUG: Starting with ${stations.length} stations');

    var filtered = stations.where((station) {
      // Search filter
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        matchesSearch = 
          station.stationName.toLowerCase().contains(_searchQuery) ||
          station.riverName.toLowerCase().contains(_searchQuery) ||
          (station.division?.toLowerCase().contains(_searchQuery) ?? false) ||
          (station.district?.toLowerCase().contains(_searchQuery) ?? false);

        print('🔍 Station "${station.stationName}" matches search "$_searchQuery": $matchesSearch');
      }

      // Alert level filter
      bool matchesFilter = true;
      if (_selectedFilter != 'All') {
        switch (_selectedFilter) {
          case 'Critical':
            matchesFilter = station.isAboveDanger;
            break;
          case 'Warning':
            matchesFilter = station.isWarningLevel && !station.isAboveDanger;
            break;
          case 'Normal':
            matchesFilter = !station.isAboveDanger && !station.isWarningLevel;
            break;
          case 'Rising':
            matchesFilter = station.isRising;
            break;
          case 'Falling':
            matchesFilter = station.isFalling;
            break;
        }
      }

      final result = matchesSearch && matchesFilter;
      if (_searchQuery.isNotEmpty || _selectedFilter != 'All') {
        print('🔍 Station "${station.stationName}": search=$matchesSearch, filter=$matchesFilter, result=$result');
      }

      return result;
    }).toList();

    // Sort by alert level (Critical first, then Warning, then Normal)
    filtered.sort((a, b) {
      if (a.isAboveDanger && !b.isAboveDanger) return -1;
      if (!a.isAboveDanger && b.isAboveDanger) return 1;
      if (a.isWarningLevel && !b.isWarningLevel) return -1;
      if (!a.isWarningLevel && b.isWarningLevel) return 1;
      return a.stationName.compareTo(b.stationName);
    });

    print('🔍 DEBUG: Filtered to ${filtered.length} stations');
    return filtered;
  }

  Color _getAlertColor(WaterLevel station) {
    if (station.isAboveDanger) return Colors.red;
    if (station.isWarningLevel) return Colors.orange;
    return Colors.green;
  }

  IconData _getAlertIcon(WaterLevel station) {
    if (station.isAboveDanger) return Icons.error;
    if (station.isWarningLevel) return Icons.warning;
    return Icons.check_circle;
  }

  Color _getTrendColor(String trend) {
    if (trend.toLowerCase().contains('rising')) return Colors.red;
    if (trend.toLowerCase().contains('falling')) return Colors.green;
    return Colors.grey;
  }

  IconData _getTrendIcon(String trend) {
    if (trend.toLowerCase().contains('rising')) return Icons.trending_up;
    if (trend.toLowerCase().contains('falling')) return Icons.trending_down;
    return Icons.trending_flat;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showStationDetails(WaterLevel station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Station details
              Text(
                station.stationName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${station.riverName} River',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (station.division != null)
                Text(
                  '${station.division}, Bangladesh',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              const SizedBox(height: 20),

              // Raw data for debugging
              Text(
                'Debug Info:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text('ID: ${station.stationId}'),
              Text('Current: ${station.currentLevel}m'),
              Text('Danger: ${station.dangerLevel}m'),
              Text('Status: ${station.status}'),
              Text('Trend: ${station.trend}'),
              Text('Alert Level: ${station.alertLevel}'),
              Text('Above Danger: ${station.isAboveDanger}'),
              Text('Warning Level: ${station.isWarningLevel}'),
            ],
          ),
        ),
      ),
    );
  }

  void _showDebugInfo() {
    final provider = Provider.of<FloodDataProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Stations: ${provider.stations.length}'),
              Text('Total Water Levels: ${provider.waterLevels.length}'),
              Text('Total Forecasts: ${provider.forecasts.length}'),
              Text('Using Mock Data: ${provider.usingMockData}'),
              Text('Last Updated: ${provider.lastUpdated}'),
              if (provider.error != null)
                Text('Error: ${provider.error}'),
              const SizedBox(height: 16),
              const Text('Sample Water Level Data:'),
              if (provider.waterLevels.isNotEmpty)
                Text(provider.waterLevels.first.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<FloodDataProvider>(context, listen: false);
    await provider.refreshWaterLevels();
  }
}
