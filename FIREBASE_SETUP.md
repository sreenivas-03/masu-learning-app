# Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter your project name (e.g., "masu-learning-app")
4. Follow the setup wizard

## Step 2: Enable Firestore Database

1. In your Firebase project, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location for your database

## Step 3: Get Firebase Configuration

1. In your Firebase project, go to "Project settings" (gear icon)
2. Scroll down to "Your apps" section
3. Click "Add app" and select your platform (Android/iOS/Web)
4. Copy the configuration values

## Step 4: Update Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
// Replace these values with your actual Firebase config
apiKey: 'your-actual-api-key',
appId: 'your-actual-app-id',
messagingSenderId: 'your-actual-sender-id',
projectId: 'your-actual-project-id',
```

## Step 5: Test the App

Run the app:
```bash
flutter run
```

## Features

This app demonstrates:
- **Counter**: Saves counter value to Firebase (persists even after app uninstall)
- **Notes**: Stores notes permanently in Firestore
- **Real-time sync**: Data is stored in the cloud and accessible from any device

## Data Structure

The app creates two collections in Firestore:
- `app_data/counter`: Stores the counter value
- `notes`: Stores user notes with timestamps

## Security Rules

For development, Firestore is in test mode. For production, set up proper security rules in the Firebase Console. 