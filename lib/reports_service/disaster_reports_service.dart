// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:http/http.dart' as http;

class DisasterReportsService {
  // HDX OCHA Humanitarian Data Exchange API
  static const String hdxBaseUrl = 'https://data.humdata.org/api/3';
  static const String hdxBangladeshUrl = 'https://data.humdata.org/api/3/action/package_search';

  // Twitter X API v2 Configuration (requires authentication)
  static const String twitterBaseUrl = 'https://api.x.com/2';
  static const String twitterBearerToken = 'AAAAAAAAAAAAAAAAAAAAADf04QEAAAAAkHb9ekFvmN6dyzBD8rWBPT9uHZM%3DymIlN4nY2Kit8VDjQuoDHXKgYQrfWgp2Knvs4ugdlmjKd11n6k'; 
  
  // Replace with actual token

  // Bangladesh bounding box for geo-filtering
  static const double bangladeshMinLat = 20.5;
  static const double bangladeshMaxLat = 26.5;
  static const double bangladeshMinLon = 88.0;
  static const double bangladeshMaxLon = 93.0;

  // Disaster-related keywords for filtering
  static const List<String> disasterKeywords = [
    'flood', 'cyclone', 'earthquake', 'landslide', 'drought', 'fire',
    'storm', 'tsunami', 'tornado', 'hurricane', 'disaster', 'emergency',
    'rescue', 'evacuation', 'relief', 'aid', 'damage', 'casualties',
    'বন্যা', 'ঘূর্ণিঝড়', 'ভূমিকম্প', 'দুর্যোগ', 'জরুরি', // Bengali keywords
  ];

  // Get HDX disaster datasets for Bangladesh
  static Future<List<Map<String, dynamic>>> getHDXDisasterReports() async {
    try {
      final response = await http.get(
        Uri.parse('\$hdxBangladeshUrl?q=Bangladesh disaster OR emergency OR flood OR cyclone&rows=50&sort=metadata_modified desc'),
        headers: {'Content-Type': 'application/json'},
      );
if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final results = data['result']['results'] as List<dynamic>;

  return results.map((item) => <String, dynamic>{
        'id': item['id'] ?? '',
        'title': item['title'] ?? 'No title',
        'name': item['name'] ?? '',
        'notes': item['notes'] ?? 'No description',
        'organization': item['organization']?['title'] ?? 'Unknown',
        'last_modified': item['metadata_modified'] ?? '',
        'url': 'https://data.humdata.org/dataset/${item['name']}',
        'tags': (item['tags'] as List<dynamic>?)
                ?.map((tag) => tag['display_name'] ?? '')
                .toList() ??
            [],
        'resources_count': (item['resources'] as List<dynamic>?)?.length ?? 0,
        'source': 'HDX OCHA',
        'type': 'dataset',
      }).toList();
}


      else {
        print('HDX API Error: \${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('HDX fetch error: \$e');
      return [];
    }
  }

  // Get Twitter disaster tweets for Bangladesh (requires authentication)
  static Future<List<Map<String, dynamic>>> getTwitterDisasterTweets() async {
    if (twitterBearerToken == 'YOUR_TWITTER_BEARER_TOKEN') {
      return _getMockTwitterData();
    }

    try {
      // Build disaster keywords query
      final keywordQuery = disasterKeywords.take(10).map((k) => '"\$k"').join(' OR ');
      final query = '(\$keywordQuery) place_country:BD -is:retweet has:geo';

      final response = await http.get(
        Uri.parse('\$twitterBaseUrl/tweets/search/recent?query=\${Uri.encodeComponent(query)}&max_results=50&tweet.fields=created_at,author_id,geo,public_metrics,lang&expansions=geo.place_id&place.fields=full_name,country,geo'),
        headers: {
          'Authorization': 'Bearer \$twitterBearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final tweets = data['data'] as List<dynamic>? ?? [];
  final places = data['includes']?['places'] as List<dynamic>? ?? [];

  // Create places lookup
  final placesMap = {for (var place in places) place['id']: place};

  return tweets.map((tweet) => <String, dynamic>{
        'id': tweet['id'] ?? '',
        'text': tweet['text'] ?? '',
        'created_at': tweet['created_at'] ?? '',
        'author_id': tweet['author_id'] ?? '',
        'retweet_count': tweet['public_metrics']?['retweet_count'] ?? 0,
        'like_count': tweet['public_metrics']?['like_count'] ?? 0,
        'reply_count': tweet['public_metrics']?['reply_count'] ?? 0,
        'quote_count': tweet['public_metrics']?['quote_count'] ?? 0,
        'language': tweet['lang'] ?? 'en',
        'location': placesMap[tweet['geo']?['place_id']]?['full_name'] ?? 'Unknown location',
        'country': placesMap[tweet['geo']?['place_id']]?['country'] ?? 'BD',
        'coordinates': placesMap[tweet['geo']?['place_id']]?['geo']?['bbox'],
        'url': 'https://x.com/i/status/${tweet['id']}',
        'source': 'Twitter X API v2',
        'type': 'tweet',
      }).toList();
}

      
      else {
        print('Twitter API Error: \${response.statusCode}');
        print('Response: \${response.body}');
        return _getMockTwitterData();
      }
    } catch (e) {
      print('Twitter fetch error: \$e');
      return _getMockTwitterData();
    }
  }

  // Get combined disaster reports from both sources
  static Future<List<Map<String, dynamic>>> getAllDisasterReports() async {
    final hdxReports = await getHDXDisasterReports();
    final twitterReports = await getTwitterDisasterTweets();

    final allReports = [...hdxReports, ...twitterReports];

    // Sort by last modified/created date (most recent first)
    allReports.sort((a, b) {
      final aDate = DateTime.tryParse(a['last_modified'] ?? a['created_at'] ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['last_modified'] ?? b['created_at'] ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return allReports;
  }

  // Get disaster reports by type
  static Future<List<Map<String, dynamic>>> getDisasterReportsByType(String disasterType) async {
    final allReports = await getAllDisasterReports();

    return allReports.where((report) {
      final title = (report['title'] ?? '').toLowerCase();
      final notes = (report['notes'] ?? '').toLowerCase();
      final text = (report['text'] ?? '').toLowerCase();
      final tags = (report['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();

      final content = '\$title \$notes \$text \$tags';
      return content.contains(disasterType.toLowerCase());
    }).toList();
  }

  // Get recent disaster alerts (last 7 days)
  static Future<List<Map<String, dynamic>>> getRecentDisasterAlerts() async {
    final allReports = await getAllDisasterReports();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    return allReports.where((report) {
      final dateStr = report['last_modified'] ?? report['created_at'] ?? '';
      final date = DateTime.tryParse(dateStr);
      return date != null && date.isAfter(weekAgo);
    }).take(20).toList();
  }

  // Mock Twitter data for demonstration (when API key not available)
  static List<Map<String, dynamic>> _getMockTwitterData() {
    return [
      {
        'id': 'mock_1',
        'text': 'Flood situation in Sylhet division getting worse. Need immediate relief assistance. #BangladeshFloods #Emergency',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'author_id': 'user_123',
        'retweet_count': 45,
        'like_count': 123,
        'reply_count': 12,
        'quote_count': 8,
        'language': 'en',
        'location': 'Sylhet, Bangladesh',
        'country': 'BD',
        'coordinates': [91.8687, 24.8949, 91.9687, 24.9949],
        'url': 'https://x.com/i/status/mock_1',
        'source': 'Twitter X API v2 (Mock)',
        'type': 'tweet',
      },
      {
        'id': 'mock_2',
        'text': 'চট্টগ্রামে ভারী বৃষ্টির কারণে জলাবদ্ধতা। স্থানীয় প্রশাসন সতর্ক অবস্থানে। #ChittagongRain',
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'author_id': 'user_456',
        'retweet_count': 23,
        'like_count': 89,
        'reply_count': 7,
        'quote_count': 3,
        'language': 'bn',
        'location': 'Chittagong, Bangladesh',
        'country': 'BD',
        'coordinates': [91.7832, 22.3569, 91.8832, 22.4569],
        'url': 'https://x.com/i/status/mock_2',
        'source': 'Twitter X API v2 (Mock)',
        'type': 'tweet',
      },
      {
        'id': 'mock_3',
        'text': 'Cyclone warning issued for coastal areas of Bangladesh. Evacuation centers prepared. Stay safe everyone! #CycloneAlert',
        'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        'author_id': 'official_weather',
        'retweet_count': 156,
        'like_count': 234,
        'reply_count': 28,
        'quote_count': 15,
        'language': 'en',
        'location': 'Cox\'s Bazar, Bangladesh',
        'country': 'BD',
        'coordinates': [92.0058, 21.4272, 92.1058, 21.5272],
        'url': 'https://x.com/i/status/mock_3',
        'source': 'Twitter X API v2 (Mock)',
        'type': 'tweet',
      },
    ];
  }

  // Get disaster statistics
  static Future<Map<String, dynamic>> getDisasterStatistics() async {
    final allReports = await getAllDisasterReports();

    final hdxCount = allReports.where((r) => r['source'] == 'HDX OCHA').length;
    final twitterCount = allReports.where((r) => r['source']?.toString().contains('Twitter') ?? false).length;

    // Count by disaster type
    final disasterCounts = <String, int>{};
    for (final keyword in ['flood', 'cyclone', 'earthquake', 'drought', 'fire']) {
      final count = allReports.where((report) {
        final content = '${report['title'] ?? ''} ${report['notes'] ?? ''} ${report['text'] ?? ''}'.toLowerCase();

        return content.contains(keyword);
      }).length;
      if (count > 0) disasterCounts[keyword] = count;
    }

    return {
      'total_reports': allReports.length,
      'hdx_datasets': hdxCount,
      'twitter_reports': twitterCount,
      'disaster_types': disasterCounts,
      'last_updated': DateTime.now().toIso8601String(),
      'sources': ['HDX OCHA', 'Twitter X API v2'],
    };
  }

  // Setup instructions
  static String getSetupInstructions() {
    return '''DISASTER REPORTS DATA SOURCES SETUP:

HDX OCHA (Humanitarian Data Exchange):
✅ FREE: No API key required
✅ 351+ Bangladesh datasets from 66 organizations  
✅ Situation reports, displacement data, needs assessments
✅ Updated regularly by UN agencies and NGOs
✅ Direct API access: data.humdata.org/api/3

Twitter X API v2:
⚠️  PAID: Requires Twitter Developer Account
⚠️  Basic Plan: \$100/month for API access
✅ Real-time geo-tagged disaster tweets
✅ Advanced filtering by location and keywords
✅ Public metrics (likes, retweets, replies)

CURRENT STATUS:
✅ HDX OCHA: Working immediately (free)
⚠️  Twitter X API: Mock data until you add API key

TO ADD TWITTER ACCESS:
1. Apply for Twitter Developer Account
2. Subscribe to Basic Plan (\$100/month)
3. Get Bearer Token
4. Replace 'YOUR_TWITTER_BEARER_TOKEN' in service

Your disaster monitoring system will work with HDX data immediately!''';
  }

  // Test API availability
  static Future<Map<String, bool>> testAPIsAvailability() async {
    print('Testing disaster report APIs...');

    // Test HDX
    bool hdxAvailable = false;
    try {
      final response = await http.get(Uri.parse('\$hdxBaseUrl/action/status_show'));
      hdxAvailable = response.statusCode == 200;
    } catch (e) {
      print('HDX test failed: \$e');
    }

    // Test Twitter (mock for now)
    final twitterAvailable = twitterBearerToken != 'YOUR_TWITTER_BEARER_TOKEN';

    return {
      'hdx_ocha': hdxAvailable,
      'twitter_x_api': twitterAvailable,
    };
  }
}
