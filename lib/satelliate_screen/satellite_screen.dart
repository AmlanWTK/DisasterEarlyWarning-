import 'package:bangladesh_disaster_management/services_satellite/NASASatelliteService.dart';
import 'package:flutter/material.dart';

class SatelliteScreen extends StatefulWidget {
  const SatelliteScreen({Key? key}) : super(key: key);

  @override
  State<SatelliteScreen> createState() => _SatelliteScreenState();
}

class _SatelliteScreenState extends State<SatelliteScreen> {
  String _selectedCity = 'Dhaka';
  String _selectedLayer = 'VIIRS True Color (SNPP)';
  String _selectedDate = '';
  bool _isLoading = false;
  String? _currentImageUrl;
  String? _errorMessage;
  bool _isRegionalView = false; // toggle between city/regional

  final Map<String, Map<String, double>> _cityCoordinates =
      NASASatelliteService.getBangladeshCityCoordinates();

  final Map<String, String> _satelliteLayers =
      NASASatelliteService.getNASASatelliteLayers();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().subtract(const Duration(days: 1))
        .toString()
        .split(' ')[0];
    _loadInitialImageSilently();
  }

  Future<void> _loadInitialImageSilently() async {
    final coordinates = _cityCoordinates[_selectedCity];
    if (coordinates == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imageUrl = NASASatelliteService.getSatelliteImageUrl(
        latitude: coordinates['lat']!,
        longitude: coordinates['lon']!,
        layer: _satelliteLayers[_selectedLayer]!,
        date: _selectedDate,
        zoomKm: _isRegionalView ? 800.0 : 20.0,
        width: _isRegionalView ? 600 : 1024,
        height: _isRegionalView ? 1000 : 1024,
      );

      setState(() {
        _currentImageUrl = imageUrl;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading satellite image: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satellite Imagery (NASA GIBS)'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.info), onPressed: _showAPIInfo),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadSatelliteImageWithFeedback),
        ],
      ),
      body: Column(
        children: [
          MaterialBanner(
            backgroundColor: Colors.green[50],
            content: const Text(
              'NASA GIBS Ready – Free satellite imagery, no API key required.',
              style: TextStyle(fontSize: 14),
            ),
            leading: const Icon(Icons.check_circle, color: Colors.green),
            actions: [
              TextButton(
                  onPressed: _showAPIInfo, child: const Text("Learn More"))
            ],
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildControls(),
          const SizedBox(height: 16),
          _buildImageCard(),
          const SizedBox(height: 16),
          _buildDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select City:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCity,
          items: _cityCoordinates.keys.map((city) {
            return DropdownMenuItem(value: city, child: Text(city));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() => _selectedCity = newValue);
              _loadSatelliteImageWithFeedback();
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(height: 16),
        Text('Select Layer:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _satelliteLayers.keys.map((layerName) {
            final isSelected = _selectedLayer == layerName;
            return ChoiceChip(
              label: Text(layerName, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedLayer = layerName);
                _loadSatelliteImageWithFeedback();
              },
              selectedColor: Colors.blue[100],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // View mode toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('View Mode:', style: Theme.of(context).textTheme.titleMedium),
            Switch(
              value: _isRegionalView,
              onChanged: (val) {
                setState(() => _isRegionalView = val);
                _loadSatelliteImageWithFeedback();
              },
            ),
            Text(_isRegionalView ? "Regional" : "City"),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 400,
        width: double.infinity,
        color: Colors.grey[200],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorWidget(_errorMessage!)
                : _currentImageUrl != null
                    ? Image.network(
                        _currentImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildErrorWidget(
                                'Failed to load satellite image'),
                      )
                    : _buildPlaceholderWidget(),
      ),
    );
  }

  Widget _buildDetailsCard() {
    final coords = _cityCoordinates[_selectedCity];
    return ExpansionTile(
      title: const Text("Image Details"),
      children: [
        ListTile(title: Text("City: $_selectedCity")),
        ListTile(title: Text("Layer: $_selectedLayer")),
        ListTile(title: Text("Date: $_selectedDate")),
        ListTile(
            title: Text("View Mode: ${_isRegionalView ? "Regional (wide)" : "City (zoomed)"}")),
        if (coords != null)
          ListTile(
            title: Text(
                "Coordinates: ${coords['lat']!.toStringAsFixed(4)}, ${coords['lon']!.toStringAsFixed(4)}"),
          ),
      ],
    );
  }

  Widget _buildPlaceholderWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.satellite_alt, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Satellite image will appear here',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          ElevatedButton(
            onPressed: _loadSatelliteImageWithFeedback,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSatelliteImageWithFeedback() async {
    final coordinates = _cityCoordinates[_selectedCity];
    if (coordinates == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imageUrl = NASASatelliteService.getSatelliteImageUrl(
        latitude: coordinates['lat']!,
        longitude: coordinates['lon']!,
        layer: _satelliteLayers[_selectedLayer]!,
        date: _selectedDate,
        zoomKm: _isRegionalView ? 800.0 : 20.0,
        width: _isRegionalView ? 600 : 1024,
        height: _isRegionalView ? 1000 : 1024,
      );

      setState(() {
        _currentImageUrl = imageUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satellite image updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAPIInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NASA GIBS Info'),
        content: SingleChildScrollView(
          child: Text(NASASatelliteService.getAPISetupInstructions()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }
}
