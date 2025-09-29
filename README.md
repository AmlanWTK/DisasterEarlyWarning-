# Bangladesh Disaster Management - Early Warning System

[![Flutter](https://img.shields.io/badge/Flutter-3.1.5+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-73.9%25-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A comprehensive **Flutter mobile application** designed specifically for Bangladesh to provide real-time disaster monitoring, early warning alerts, and emergency response coordination. This app integrates multiple data sources including flood monitoring, weather forecasting, satellite imagery, and disaster reporting to help communities prepare for and respond to natural disasters.

![App Preview](assets/images/app_preview.png)

## 🌟 Key Features

### 🌊 **Real-Time Flood Monitoring**
- **Live Water Level Tracking**: Monitors 100+ stations across Bangladesh rivers
- **FFWC Integration**: Direct connection to Flood Forecasting and Warning Centre (FFWC) API
- **Critical Alert System**: Instant notifications when water levels exceed danger thresholds
- **Interactive Maps**: Visualize flood-prone areas and monitoring station locations
- **Trend Analysis**: Rising/falling water level indicators with predictive alerts

### ⛈️ **Weather Intelligence**
- **OpenWeatherMap Integration**: Real-time weather data for major Bangladesh cities
- **5-Day Forecasting**: Extended weather predictions for planning purposes
- **Severe Weather Alerts**: Automatic notifications for storms, cyclones, and extreme conditions
- **Multi-City Support**: Coverage for Dhaka, Chittagong, Sylhet, Rajshahi, Khulna, and more
- **Localized Forecasts**: Weather data specific to user's current location

### 🛰️ **NASA Satellite Imagery**
- **NASA GIBS Integration**: Free satellite imagery without API key requirements
- **Multiple View Modes**: City-level zoom and regional wide-area views
- **Various Satellite Layers**: True color, infrared, and specialized disaster monitoring layers
- **Real-Time Updates**: Latest satellite imagery for disaster assessment
- **Offline Caching**: Store satellite images for offline viewing during emergencies

### 📊 **Disaster Reporting & Alerts**
- **Supabase Backend**: Real-time disaster report database
- **Community Reports**: User-generated incident reporting system
- **Geo-Tagged Incidents**: Location-based disaster mapping
- **Push Notifications**: Critical alert delivery system
- **Historical Data**: Access to past disaster records and patterns

### 🗺️ **Smart Navigation & Location Services**
- **Google Maps Integration**: Interactive mapping with disaster overlays
- **GPS Location Services**: Automatic location detection for personalized alerts
- **Evacuation Routes**: Pre-planned emergency evacuation pathways
- **Safe Zone Mapping**: Identification of relief centers and safe areas
- **Offline Maps**: Cached map data for use during network outages

## 🏗️ Technical Architecture

### **Frontend Framework**
- **Flutter 3.1.5+**: Cross-platform mobile development
- **Material Design 3**: Modern, responsive UI components
- **Provider Pattern**: State management for real-time data updates
- **Responsive Design**: Optimized for various screen sizes

### **Backend Services**
- **Supabase**: Real-time database and authentication
- **FFWC API**: Official Bangladesh flood monitoring data
- **OpenWeatherMap API**: Weather and forecast services
- **NASA GIBS**: Satellite imagery service

### **Key Dependencies**
```yaml
dependencies:
  flutter: sdk
  supabase_flutter: ^2.0.3      # Real-time database
  google_maps_flutter: ^2.5.0   # Interactive mapping
  geolocator: ^10.1.0           # GPS location services
  flutter_local_notifications: ^16.3.0  # Push notifications
  provider: ^6.1.1              # State management
  http: ^1.1.0                  # API communications
  cached_network_image: ^3.3.0  # Image caching
  connectivity_plus: ^5.0.2     # Network monitoring
```

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: Version 3.1.5 or higher
- **Dart SDK**: Version 3.0+ 
- **Android Studio** or **VS Code** with Flutter extensions
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+ (for iOS deployment)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/AmlanWTK/DisasterEarlyWarning-.git
   cd DisasterEarlyWarning-
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**
   
   Create a `.env` file in the root directory:
   ```env
   OPENWEATHER_API_KEY=your_openweathermap_api_key
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

4. **Set Up API Services**
   
   **OpenWeatherMap API:**
   - Sign up at [OpenWeatherMap](https://openweathermap.org/api)
   - Get free API key (1000 calls/day)
   - Add key to `lib/services/weather_service.dart`

   **Supabase Setup:**
   - Create project at [Supabase](https://supabase.com)
   - Configure database schema for disaster reports
   - Update credentials in `lib/main.dart`

   **Google Maps:**
   - Enable Maps SDK in [Google Cloud Console](https://console.cloud.google.com)
   - Add API key to `android/app/src/main/AndroidManifest.xml`

5. **Configure Platform-Specific Settings**

   **Android (android/app/src/main/AndroidManifest.xml):**
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

6. **Run the Application**
   ```bash
   flutter run
   ```

## 📱 App Navigation & User Guide

### **Home Dashboard**
- **Alert Status Overview**: Real-time summary of critical, warning, and normal conditions
- **System Status**: Monitoring station count and connection status
- **Recent Critical Alerts**: Latest high-priority flood warnings
- **Quick Actions**: One-tap access to all major features

### **Flood Monitor Screen**
- **Station List**: All FFWC monitoring stations with current status
- **Search & Filter**: Find specific stations by name, river, or district
- **Alert Levels**: Color-coded indicators (Red=Critical, Orange=Warning, Green=Normal)
- **Detailed View**: Station-specific information with trends and forecasts

### **Weather Screen**
- **Current Conditions**: Temperature, humidity, and weather description
- **5-Day Forecast**: Extended weather predictions
- **Multiple Cities**: Switch between major Bangladesh cities
- **Weather Alerts**: Severe weather warnings and advisories

### **Satellite Screen**
- **Real-Time Imagery**: Latest NASA satellite views
- **Layer Selection**: Multiple satellite data types
- **Zoom Controls**: City-level and regional viewing modes
- **Offline Storage**: Cached images for emergency access

### **Disaster Reports Screen**
- **Live Reports**: Community-submitted incident reports
- **Map Integration**: Geo-located disaster incidents
- **Report Submission**: Easy incident reporting with photos
- **Historical Data**: Past disaster records and patterns

## 🔧 Development & Customization

### **Project Structure**
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── station_model.dart
│   ├── water_level_model.dart
│   ├── forecast_model.dart
│   └── weather_model.dart
├── providers/                # State management
│   ├── flood_data_provider.dart
│   └── weather_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── flood_monitor_screen.dart
│   ├── weather_screen.dart
│   └── settings_screen.dart
├── services/                 # API services
│   ├── ffwc_api_service.dart
│   ├── weather_service.dart
│   └── notification_service.dart
└── satelliate_screen/        # Satellite imagery
    └── satellite_screen.dart
```

### **Adding New Features**
1. **Create Model**: Define data structure in `models/`
2. **Add Provider**: Implement state management in `providers/`
3. **Create Service**: Add API integration in `services/`
4. **Build UI**: Design screen in `screens/`
5. **Update Navigation**: Add routes in `main.dart`

### **API Integration Guide**
- **FFWC API**: No authentication required, public Bangladesh data
- **NASA GIBS**: Free service, no API key needed
- **OpenWeatherMap**: Free tier (1000 calls/day), registration required
- **Supabase**: Free tier with real-time features

## 🌍 Regional Adaptation

This app is specifically designed for **Bangladesh** but can be adapted for other regions:

### **For Other Countries:**
1. **Replace FFWC API** with local flood monitoring service
2. **Update City Coordinates** in satellite service
3. **Modify Weather Cities** for local locations
4. **Adjust Alert Thresholds** based on regional standards
5. **Localize Text** and date formats

### **Language Support**
- Currently supports English
- Easily extensible for Bengali/Bangla localization
- Use Flutter's `intl` package for internationalization

## 🔐 Security & Privacy

### **Data Protection**
- **No Personal Data Storage**: Location data processed locally only
- **Encrypted Communications**: All API calls use HTTPS
- **Minimal Permissions**: Only essential device permissions requested
- **Privacy by Design**: User data never shared with third parties

### **API Security**
- **Rate Limiting**: Implemented to prevent API abuse
- **Error Handling**: Graceful degradation when services unavailable
- **Offline Mode**: Critical features work without internet
- **Data Validation**: All external data sanitized before display

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### **Ways to Contribute**
1. **Bug Reports**: Submit issues with detailed reproduction steps
2. **Feature Requests**: Suggest new disaster management features
3. **Code Contributions**: Submit pull requests with improvements
4. **Documentation**: Help improve setup guides and API documentation
5. **Testing**: Test the app in different regions and report issues

### **Development Workflow**
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### **Code Standards**
- Follow [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Write descriptive commit messages
- Add comments for complex logic
- Include tests for new features
- Update documentation for API changes

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Contact

### **Technical Support**
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check wiki for detailed guides
- **Community**: Join discussions in GitHub Discussions

### **Emergency Use**
This app is designed for **preparedness and early warning**. In actual emergencies:
- Contact local emergency services immediately
- Use official evacuation routes
- Follow guidance from local disaster management authorities
- Keep the app updated for latest features and data sources

### **Acknowledgments**
- **FFWC Bangladesh**: Flood monitoring data
- **NASA**: Satellite imagery through GIBS service  
- **OpenWeatherMap**: Weather and forecast data
- **Google**: Maps and location services
- **Supabase**: Real-time database infrastructure
- **Flutter Community**: Framework and package ecosystem

---

**Built with ❤️ for disaster resilience in Bangladesh and beyond.**

For the latest updates and releases, visit: [GitHub Repository](https://github.com/AmlanWTK/DisasterEarlyWarning-)
