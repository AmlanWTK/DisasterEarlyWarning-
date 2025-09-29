// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_super_parameters

import 'package:bangladesh_disaster_management/reports_service/disaster_reports_service.dart';
import 'package:flutter/material.dart';


class DisasterReportsScreen extends StatefulWidget {
  const DisasterReportsScreen({Key? key}) : super(key: key);

  @override
  State<DisasterReportsScreen> createState() => _DisasterReportsScreenState();
}

class _DisasterReportsScreenState extends State<DisasterReportsScreen> {
  List<Map<String, dynamic>> _reports = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String _selectedFilter = 'All';
  String _errorMessage = '';

  final List<String> _filters = ['All', 'Recent', 'Flood', 'Cyclone', 'Earthquake', 'Drought'];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Map<String, dynamic>> reports;

      if (_selectedFilter == 'All') {
        reports = await DisasterReportsService.getAllDisasterReports();
      } else if (_selectedFilter == 'Recent') {
        reports = await DisasterReportsService.getRecentDisasterAlerts();
      } else {
        reports = await DisasterReportsService.getDisasterReportsByType(_selectedFilter);
      }

      final stats = await DisasterReportsService.getDisasterStatistics();

      setState(() {
        _reports = reports;
        _statistics = stats;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading disaster reports: \$e';
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
        title: const Text('Disaster Reports & Alerts'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showSetupInfo,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(),
          _buildFilters(),
          if (_statistics != null) _buildStatistics(),
          Expanded(
            child: _buildReportsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue[100],
      child: Row(
        children: [
          const Icon(Icons.report, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Disaster Reports from HDX OCHA & Twitter X API v2'),
          ),
          TextButton(
            onPressed: _showSetupInfo,
            child: const Text('Setup'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Disaster Type:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        _loadReports();
                      }
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

  Widget _buildStatistics() {
    if (_statistics == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disaster Reports Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Reports', _statistics!['total_reports'].toString(), Icons.report),
                _buildStatCard('HDX Datasets', _statistics!['hdx_datasets'].toString(), Icons.dataset),
                _buildStatCard('Twitter Reports', _statistics!['twitter_reports'].toString(), Icons.message_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildReportsList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading disaster reports...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No disaster reports found for \$_selectedFilter'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final isHDX = report['source'] == 'HDX OCHA';
    final isTwitter = report['source']?.toString().contains('Twitter') ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHDX ? Colors.blue[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['source'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 10,
                      color: isHDX ? Colors.blue[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (isTwitter) ...[
      Icon(Icons.favorite, size: 16, color: Colors.red),
      Text('${report['like_count'] ?? 0}', style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 8),
      Icon(Icons.repeat, size: 16, color: Colors.blue),
      Text('${report['retweet_count'] ?? 0}', style: const TextStyle(fontSize: 12)),
    ],
    if (isHDX) ...[
      Icon(Icons.dataset, size: 16, color: Colors.blue),
      Text('${report['resources_count'] ?? 0} resources', style: const TextStyle(fontSize: 12)),
    ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report['title'] ?? report['text'] ?? 'No title',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (report['notes'] != null && report['notes'].isNotEmpty)
              Text(
                report['notes'],
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            if (isHDX && report['organization'] != null)
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(report['organization'], style: const TextStyle(fontSize: 12)),
                ],
              ),
            if (isTwitter && report['location'] != null)
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(report['location'], style: const TextStyle(fontSize: 12)),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(report['last_modified'] ?? report['created_at']),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _openReport(report),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Unknown date';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '\${difference.inMinutes}m ago';
        }
        return '\${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '\${difference.inDays}d ago';
      } else {
        return '\${date.day}/\${date.month}/\${date.year}';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _openReport(Map<String, dynamic> report) {
    final url = report['url'] ?? '';
    if (url.isNotEmpty) {
      // In a real app, you would use url_launcher package
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Would open: \$url'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSetupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disaster Reports Setup'),
        content: SingleChildScrollView(
          child: Text(DisasterReportsService.getSetupInstructions()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
