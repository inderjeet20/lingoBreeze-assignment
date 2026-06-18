# LingoBreeze – My Vocabulary

A clean, minimal, and modern vocabulary management feature built with Flutter, Node.js, and Firebase.

## Project Structure

- `flutter-app/`: The Flutter application implementing the \"My Vocabulary\" feature.
- `backend/`: Node.js Express API for retrieving vocabulary words.

## Features

### Flutter App
- **Clean Architecture**: Organized into `domain`, `data`, and `presentation` layers.
- **State Management**: Uses `Provider` for clean reactive UI.
- **UI/UX**:
  - Empty state with call-to-action.
  - Loading, error, and pull-to-refresh states.
  - Modern card-based list view.
  - Modal Bottom Sheet for adding words.
- **Integrations**:
  - `cloud_firestore`: Direct write access to Firebase.
  - `http`: Consumes the Node.js API to retrieve words.

### Backend (Node.js)
- **Framework**: Express.js.
- **Service**: Firebase Admin SDK.
- **Endpoint**:
  - `GET /words`: Retrieves all words from Firestore ordered by creation date.

## Setup Instructions

### Backend
1. Go to `backend/` folder.
2. Run `npm install`.
3. Create a `.env` file based on `.env.example` if you want a custom port.
4. Run `npm start`.

### Flutter App
1. Go to `flutter-app/` folder.
2. Run `flutter pub get`.
3. Run `flutter run`.
4. If you are on a physical device or a non-standard backend host, pass `--dart-define=API_BASE_URL=http://<your-ip>:3000`.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Node.js (Express)
- **Storage**: In-memory API data for local development
- **State Management**: Provider
- **Design System**: Material 3 with Google Fonts (Inter)
