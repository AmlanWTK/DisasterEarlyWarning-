import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flood_data_provider.dart';
import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // FIXED: Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final floodProvider = Provider.of<FloodDataProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    try {
      await Future.wait([
        floodProvider.initializeData(), // Use safe initialization method
        weatherProvider.loadWeatherData('Dhaka'),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bangladesh Disaster Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
    _navigateToPage(index);
  },
  type: BottomNavigationBarType.fixed, // IMPORTANT: For 5 items
  selectedItemColor: Theme.of(context).primaryColor,
  unselectedItemColor: Colors.grey,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.water), label: 'Flood Monitor'),
    BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'),
    BottomNavigationBarItem(icon: Icon(Icons.satellite_alt), label: 'Satellite'), // ADD THIS
    BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
  ],
),




    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content is short
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlertSummary(),
            const SizedBox(height: 20),
            _buildQuickStats(),
            const SizedBox(height: 20),
            _buildRecentAlerts(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSummary() {
    return Consumer<FloodDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.waterLevels.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading flood monitoring data...'),
                ],
              ),
            ),
          );
        }

        if (provider.error != null && provider.waterLevels.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading data: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final critical = provider.criticalAlerts.length;
        final warning = provider.warningLevels.length;
        final normal = provider.waterLevels.length - critical - warning;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Alert Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAlertItem('Critical', critical, Colors.red),
                    _buildAlertItem('Warning', warning, Colors.orange),
                    _buildAlertItem('Normal', normal, Colors.green),
                  ],
                ),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Consumer<FloodDataProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.sensors, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('${provider.stations.length} Monitoring Stations'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      provider.error != null ? Icons.error : Icons.check_circle,
                      color: provider.error != null ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.error != null 
                        ? 'Connection Error' 
                        : 'System Online',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.update, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('Last Updated: ${_formatLastUpdate(provider.lastUpdated)}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentAlerts() {
    return Consumer<FloodDataProvider>(
      builder: (context, provider, child) {
        final alerts = provider.criticalAlerts.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Recent Critical Alerts',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    if (alerts.isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/flood-monitor'),
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (alerts.isEmpty)
                  const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('No critical alerts at this time'),
                    subtitle: Text('All stations are below danger levels'),
                  )
                else
                  ...alerts.map((alert) => ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text('${alert.stationName} (${alert.riverName})'),
                    subtitle: Text(
                      'Water Level: ${alert.currentLevel.toStringAsFixed(2)}m (Danger: ${alert.dangerLevel.toStringAsFixed(2)}m)',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/flood-monitor'),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          // UPDATED: Now shows 4 actions in 2 rows
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    'Flood Monitor',
                    Icons.water,
                    () => Navigator.pushNamed(context, '/flood-monitor'),
                  ),
                  _buildActionButton(
                    'Weather',
                    Icons.cloud,
                    () => Navigator.pushNamed(context, '/weather'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    'Satellite',
                    Icons.satellite_alt,
                    () => Navigator.pushNamed(context, '/satellite'), // ADD THIS
                  ),
                  _buildActionButton(
                    'All Alerts',
                    Icons.notifications,
                    () => Navigator.pushNamed(context, '/alerts'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

 void _navigateToPage(int index) {
  switch (index) {
    case 0: break; // Already on home
    case 1: Navigator.pushNamed(context, '/flood-monitor'); break;
    case 2: Navigator.pushNamed(context, '/weather'); break;
    case 3: Navigator.pushNamed(context, '/satellite'); break; // ADD THIS
    case 4: Navigator.pushNamed(context, '/alerts'); break;
  }
}

  Future<void> _refreshData() async {
    final floodProvider = Provider.of<FloodDataProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    try {
      await Future.wait([
        floodProvider.refreshWaterLevels(),
        weatherProvider.refreshWeather(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatLastUpdate(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
