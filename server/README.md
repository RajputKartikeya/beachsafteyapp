# BeachSafe India Server

This is the backend server for the BeachSafe India app. It provides APIs for beach information and safety data across India.

## Features

- RESTful API endpoints for beach data
- Support for searching beaches by name or location
- Real-time updates via Firebase Realtime Database integration
- Connection between Node.js server and Firebase for synchronized data

## Setup

### Prerequisites

- Node.js (v14+)
- npm or yarn

### Installation

1. Clone the repository
2. Install dependencies

```bash
npm install
```

3. Configure your Firebase credentials

   - Go to Firebase Console > Project Settings > Service Accounts
   - Generate a new private key
   - Create a `.env` file based on `.env.example`
   - Add your Firebase service account JSON as the `FIREBASE_SERVICE_ACCOUNT` value

4. Start the server

```bash
# Development mode with auto-restart
npm run dev

# Production mode
npm start
```

## Firebase Integration

This server integrates with Firebase Realtime Database to provide real-time updates to connected clients. Here's how it works:

1. On server startup, it syncs local beach data to Firebase if it doesn't exist yet
2. All API endpoints read from Firebase instead of local data
3. Any changes made through the API are immediately reflected in Firebase
4. Flutter clients can connect directly to Firebase for real-time updates

### Benefits

- Reduced server load since clients can get real-time updates directly from Firebase
- Offline capabilities for the app through Firebase caching
- Synchronized data across server and app instances
- Enhanced performance and reliability

## API Endpoints

### Get All Beaches

```
GET /api/beaches
```

Returns an array of all beaches.

### Get a Specific Beach

```
GET /api/beaches/:id
```

Returns details for a specific beach.

### Search Beaches

```
GET /api/beaches/search?query=
```

Returns beaches that match the search query.

### Update Beach Data

```
PUT /api/beaches/:id
```

Updates a specific beach's data in Firebase.

## Development

### Project Structure

- `index.js` - Main server entry point and API routes
- `beachData.js` - Initial beach data used for seeding Firebase

## Connecting Flutter App with Firebase

1. The Flutter app should include the Firebase SDK
2. Configure the app with the same Firebase project credentials
3. Use the provided Firebase Database service to get real-time updates
4. The app can fallback to REST API if needed for compatibility

## Response Format

Each beach object contains the following information:

- id: Unique identifier
- name: Beach name
- location: City and state
- temperature: Current temperature in Celsius
- waveHeight: Wave height in meters
- oceanCurrents: Current strength description
- isSafe: Boolean indicating if the beach is safe for swimming
- latitude: Geographical latitude
- longitude: Geographical longitude
- description: Detailed description of the beach
