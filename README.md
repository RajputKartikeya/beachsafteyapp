# 🏖️ BeachSafe India

**A comprehensive beach safety and management application for Indian beaches, providing real-time safety monitoring, beach information, and user-friendly interfaces for beach management.**

[![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![Node.js](https://img.shields.io/badge/Node.js-Express-green.svg)](https://nodejs.org/)

## 🌟 Unique Features

### 🚦 Intelligent Safety Assessment

- **Automatic Safety Calculation**: Real-time beach safety determination based on wave height (>1.5m dangerous) and ocean current strength
- **Dynamic Safety Updates**: Automatic recalculation of safety status when environmental conditions change
- **Visual Safety Indicators**: Color-coded safety status throughout the app interface

### 🗺️ Comprehensive Beach Coverage

- **20+ Major Indian Beaches**: Covers popular destinations across Tamil Nadu, Goa, Kerala, Odisha, Andaman & Nicobar Islands
- **Detailed Beach Profiles**: Temperature, wave height, ocean currents, GPS coordinates, and comprehensive descriptions
- **Interactive Maps**: Google Maps integration with precise beach locations

### 🔄 Real-time Synchronization

- **Firebase Realtime Database**: Instant updates across all connected devices
- **Hybrid Architecture**: Node.js REST API with Firebase real-time capabilities
- **Offline Support**: Firebase persistence enables offline functionality

### 👥 Multi-User Management

- **User Authentication**: Secure Firebase Auth integration
- **Role-based Access**: Different permissions for regular users and beach administrators
- **Profile Management**: Comprehensive user profiles with preferences and history

### 🔔 Smart Notifications

- **Safety Alerts**: Automatic notifications when beach conditions become unsafe
- **Weather Updates**: Real-time weather and condition notifications
- **User Preferences**: Customizable notification settings

## 📱 App Features

### Core Functionality

- **Beach Discovery**: Browse and search through Indian beaches
- **Real-time Safety Status**: Current safety conditions with detailed explanations
- **Interactive Maps**: Google Maps integration with beach locations
- **Detailed Beach Information**: Temperature, wave conditions, currents, and descriptions
- **Image Gallery**: Visual representation of beaches
- **User Reviews & Feedback**: Community-driven beach reviews

### Advanced Features

- **Beach Management Dashboard**: Administrative tools for updating beach conditions
- **Notification Center**: Centralized alert and update management
- **Search & Filter**: Advanced search with location and safety filters
- **Offline Mode**: Continue browsing with cached data when offline
- **Cross-platform**: Available on Android, iOS, and Web

## 🏗️ Architecture

### Frontend (Flutter)

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── screens/                  # All app screens
│   ├── home_screen.dart      # Main dashboard with beach overview
│   ├── beach_list_screen.dart
│   ├── beach_detail_screen.dart
│   ├── enhanced_beach_detail_screen.dart
│   ├── map_screen.dart       # Google Maps integration
│   ├── login_screen.dart     # Firebase Auth
│   ├── register_screen.dart
│   ├── user_profile_screen.dart
│   ├── beach_management_screen.dart  # Admin features
│   ├── notifications_screen.dart
│   └── beach_feedback_screen.dart
├── models/                   # Data models
│   ├── beach.dart           # Core beach data structure
│   ├── beach_update.dart    # Update tracking
│   └── user_model.dart      # User data model
├── services/                # Business logic layer
│   ├── auth_service.dart    # Firebase Authentication
│   ├── firebase_database_service.dart  # Firebase Realtime DB
│   ├── beach_api_service.dart  # REST API communication
│   └── notification_service.dart  # Push notifications
├── widgets/                 # Reusable UI components
└── data/                   # Local data and fallbacks
```

### Backend (Node.js + Express)

```
server/
├── index.js                 # Express server with API endpoints
├── beachData.js            # Comprehensive Indian beach dataset
├── setup-firebase.js       # Firebase Admin SDK configuration
├── package.json            # Dependencies and scripts
└── README.md               # Backend documentation
```

### Database (Firebase Realtime Database)

- **Real-time Synchronization**: Instant updates across all clients
- **Offline Persistence**: Local caching for offline functionality
- **Scalable Structure**: Optimized for read/write operations

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.0+)
- Node.js (14+)
- Firebase project setup
- Google Maps API key

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/beachsafetyapp.git
   cd beachsafetyapp
   ```

2. **Setup Flutter App**

   ```bash
   flutter pub get
   ```

3. **🔐 Configure Firebase (REQUIRED)**

   **For Security Reasons, Firebase configuration files are not included in this repository.**

   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication and Realtime Database
   - Download configuration files:
     - `google-services.json` → Place in `android/app/`
     - `GoogleService-Info.plist` → Place in `ios/Runner/`
   - Copy `lib/firebase_options.dart.template` to `lib/firebase_options.dart`
   - Replace placeholder values with your actual Firebase configuration
   - Or run: `flutterfire configure` (recommended)

4. **🗺️ Configure Google Maps API**

   **Google Maps API keys are not included for security.**

   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable "Maps SDK for Android" and "Maps SDK for iOS"
   - Copy `android/app/src/main/AndroidManifest.xml.template` to `android/app/src/main/AndroidManifest.xml`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key
   - For iOS: Add your API key to `ios/Runner/AppDelegate.swift`

5. **Setup Backend Server**

   ```bash
   cd server
   npm install
   cp env.template .env
   # Configure your environment variables in .env
   npm run start
   ```

6. **Run the Application**
   ```bash
   flutter run
   ```

### 🔒 Security Note

This repository does **NOT** include:

- Firebase configuration files (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`)
- Google Maps API keys
- Environment variables with sensitive data

You must configure these yourself following the setup instructions above.

## 🛠️ Technical Stack

### Frontend

- **Flutter**: Cross-platform mobile framework
- **Firebase Auth**: User authentication and management
- **Firebase Realtime Database**: Real-time data synchronization
- **Google Maps Flutter**: Interactive mapping functionality
- **HTTP**: REST API communication
- **Shared Preferences**: Local data storage

### Backend

- **Node.js**: Server runtime
- **Express.js**: Web application framework
- **Firebase Admin SDK**: Server-side Firebase integration
- **CORS**: Cross-origin resource sharing
- **dotenv**: Environment configuration

### Database & Services

- **Firebase Realtime Database**: Primary data store
- **Firebase Authentication**: User management
- **Google Maps API**: Location services

## 🌊 Beach Data Coverage

The app includes comprehensive data for beaches across:

- **Tamil Nadu**: Marina Beach, Elliot's Beach
- **Goa**: Calangute, Baga, Anjuna, Palolem, Colva
- **Kerala**: Kovalam, Varkala, Cherai, Marari
- **Andaman & Nicobar**: Radhanagar, Elephant Beach, Corbyn's Cove
- **Odisha**: Puri Beach, Chandrabhaga
- **Maharashtra**: Juhu Beach, Alibaug
- **West Bengal**: Digha Beach, Mandarmani
- **Karnataka**: Gokarna Beach, Udupi Beach

Each beach includes:

- GPS coordinates
- Current temperature
- Wave height measurements
- Ocean current descriptions
- Safety assessments
- Detailed descriptions
- Local attractions and amenities

## 🔒 Safety & Security

- **Firebase Security Rules**: Implemented for data protection
- **Input Validation**: Server-side validation for all API endpoints
- **Authentication**: Secure user authentication with Firebase
- **Error Handling**: Comprehensive error handling and user feedback
- **Data Privacy**: User data protection and privacy compliance

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📱 Screenshots & Demo

---

**Made with ❤️ for safer beach experiences in India** 🇮🇳
