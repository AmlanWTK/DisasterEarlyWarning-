import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedCity = 'Dhaka';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  // Major Bangladesh cities for quick selection - NO DUPLICATES
  final List<String> _majorCities = [
    'Dhaka',
    'Chittagong', 
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Rangpur',
    'Mymensingh',
    'Comilla',
    'Narayanganj',
  ];

  // FIXED: Extended list with NO DUPLICATES using Set to remove duplicates
  final Set<String> _allBangladeshCitiesSet = {
    // Major divisions
    'Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna', 'Barisal', 'Rangpur', 'Mymensingh',

    // Dhaka Division
    'Gazipur', 'Narayanganj', 'Tangail', 'Kishoreganj', 'Manikganj', 'Munshiganj', 'Narsingdi', 
    'Faridpur', 'Gopalganj', 'Madaripur', 'Rajbari', 'Shariatpur',

    // Chittagong Division  
    'Cox\'s Bazar', 'Comilla', 'Feni', 'Brahmanbaria', 'Rangamati', 'Noakhali', 'Laksmipur', 
    'Chandpur', 'Bandarban', 'Khagrachhari',

    // Sylhet Division
    'Moulvibazar', 'Habiganj', 'Sunamganj',

    // Rajshahi Division
    'Bogra', 'Pabna', 'Sirajganj', 'Joypurhat', 'Chapainawabganj', 'Naogaon', 'Natore',

    // Khulna Division
    'Jessore', 'Narail', 'Magura', 'Jhenaidah', 'Bagerhat', 'Chuadanga', 'Kushtia', 
    'Meherpur', 'Satkhira',

    // Barisal Division
    'Patuakhali', 'Pirojpur', 'Barguna', 'Bhola', 'Jhalokati',

    // Rangpur Division
    'Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Thakurgaon',

    // Mymensingh Division
    'Jamalpur', 'Netrakona', 'Sherpur',

    // Sub-districts and other cities
    'Tala', 'Savar', 'Dhamrai', 'Keraniganj', 'Dohar', 'Nawabganj', 'Kapasia', 'Kaliakoir', 
    'Gacha', 'Tongi', 'Kaliganj', 'Araihazar', 'Sonargaon', 'Rupganj', 'Bandar', 'Fatullah',
    'Basail', 'Bhuapur', 'Delduar', 'Ghatail', 'Gopalpur', 'Kalihati', 'Madhupur', 'Mirzapur', 
    'Nagarpur', 'Sakhipur',
  };

  late List<String> _allBangladeshCities;
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    // Convert Set to List and sort alphabetically for better UX
    _allBangladeshCities = _allBangladeshCitiesSet.toList()..sort();
    _filteredCities = _allBangladeshCities;

    // Validate that _selectedCity exists in _majorCities
    if (!_majorCities.contains(_selectedCity)) {
      _selectedCity = _majorCities.first;
    }

    print('🔍 Total cities loaded: ${_allBangladeshCities.length}');
    print('🔍 Major cities: ${_majorCities.length}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialWeatherData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialWeatherData() async {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    try {
      await provider.initializeWeatherData(_selectedCity);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading weather: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _allBangladeshCities;
      } else {
        _filteredCities = _allBangladeshCities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchMode = !_isSearchMode;
                if (!_isSearchMode) {
                  _searchController.clear();
                  _filteredCities = _allBangladeshCities;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeather,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchMode) _buildCitySearch() else _buildCitySelector(),
          Expanded(
            child: _buildWeatherContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Any City in Bangladesh (${_allBangladeshCities.length} cities):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Type city name (e.g., Tangail, Tala, Cox\'s Bazar)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterCities('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _filterCities,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _searchAndLoadWeather(value);
              }
            },
          ),
          if (_searchController.text.isNotEmpty && _filteredCities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCities.length > 10 ? 10 : _filteredCities.length,
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_city, size: 20),
                    title: Text(city),
                    onTap: () {
                      _searchController.text = city;
                      _searchAndLoadWeather(city);
                      setState(() {
                        _filteredCities = [];
                      });
                    },
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _searchController.text.isNotEmpty
                      ? () => _searchAndLoadWeather(_searchController.text)
                      : null,
                  child: const Text('Get Weather'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isSearchMode = false;
                    _searchController.clear();
                  });
                },
                child: const Text('Quick Select'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick Select Major Cities:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isSearchMode = true;
                  });
                },
                icon: const Icon(Icons.search, size: 16),
                label: const Text('Search Any City'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                items: _majorCities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Row(
                      children: [
                        const Icon(Icons.location_city, size: 20),
                        const SizedBox(width: 8),
                        Text(city),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != _selectedCity) {
                    print('🔍 Dropdown selection: $newValue');
                    setState(() {
                      _selectedCity = newValue;
                    });
                    _loadWeatherForCity(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.currentWeather == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading weather data...'),
              ],
            ),
          );
        }

        if (provider.error != null && provider.currentWeather == null) {
          return _buildErrorState(provider);
        }

        return RefreshIndicator(
          onRefresh: _refreshWeather,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentWeatherCard(provider),
                const SizedBox(height: 20),
                _buildWeatherAlerts(provider),
                const SizedBox(height: 20),
                _buildWeatherDetails(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(WeatherProvider provider) {
    final isApiKeyError = provider.error?.contains('401') == true;
    final isCityNotFound = provider.error?.contains('404') == true;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCityNotFound ? Icons.location_off : (isApiKeyError ? Icons.key_off : Icons.error),
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isCityNotFound 
                  ? 'City Not Found' 
                  : (isApiKeyError ? 'API Key Issue' : 'Weather Loading Error'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isCityNotFound
                  ? 'The city "$_selectedCity" was not found. Please try a nearby major city.'
                  : (provider.error ?? 'Unknown error occurred'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _refreshWeather,
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isSearchMode = true;
                    });
                  },
                  child: const Text('Search Different City'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherProvider provider) {
    final temperature = provider.getTemperature();
    final description = provider.getWeatherDescription();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Weather - $_selectedCity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getWeatherIcon(description),
                    size: 40,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temperature != null ? '${temperature.round()}°C' : '--°C',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherAlerts(WeatherProvider provider) {
    final hasAlerts = provider.hasWeatherAlerts();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Alerts',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (hasAlerts)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Severe Weather Alert',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          Text(
                            provider.getWeatherDescription(),
                            style: TextStyle(
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Active Weather Alerts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'Weather conditions are normal',
                            style: TextStyle(
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails(WeatherProvider provider) {
    final weather = provider.currentWeather;
    if (weather == null) return const SizedBox();

    final main = weather['main'] as Map<String, dynamic>? ?? {};
    final wind = weather['wind'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Feels Like',
                    '${(main['feels_like'] as num?)?.round() ?? '--'}°C',
                    Icons.thermostat,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Humidity',
                    '${main['humidity'] ?? '--'}%',
                    Icons.water_drop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Pressure',
                    '${main['pressure'] ?? '--'} hPa',
                    Icons.speed,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Wind Speed',
                    '${wind['speed'] ?? '--'} m/s',
                    Icons.air,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue[600]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('rain')) return Icons.umbrella;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('sun') || desc.contains('clear')) return Icons.wb_sunny;
    if (desc.contains('storm')) return Icons.thunderstorm;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('mist') || desc.contains('fog')) return Icons.foggy;
    return Icons.wb_cloudy;
  }

  Future<void> _searchAndLoadWeather(String cityName) async {
    print('🔍 Loading weather for: $cityName');
    setState(() {
      _selectedCity = cityName;
    });
    await _loadWeatherForCity(cityName);
  }

  Future<void> _loadWeatherForCity(String city) async {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    await provider.loadWeatherDataImmediate(city);
  }

  Future<void> _refreshWeather() async {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    await provider.refreshWeather();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weather data refreshed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
