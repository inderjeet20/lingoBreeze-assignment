# LingoBreeze – My Vocabulary

A clean, minimal, and modern vocabulary management feature built with Flutter, Node.js, and Firebase.

## Project Structure

- `flutter-app/`: The Flutter application implementing the \"My Vocabulary\" feature.
- `backend/`: Node.js Express API for creating, reading, updating, and deleting vocabulary words in Firestore.

## Features

### Flutter App
- **Clean Architecture**: Organized into `domain`, `data`, and `presentation` layers.
- **State Management**: Uses `Provider` for clean reactive UI.
- **UI/UX**:
  - Empty state with a clear add action.
  - Loading, error, and pull-to-refresh states.
  - Clean card-based vocabulary list.
  - Modal bottom sheet for adding and editing words.
  - Delete confirmation for removing words.
- **Integrations**:
  - `http`: Consumes the Node.js API for all vocabulary operations.

### Backend (Node.js)
- **Framework**: Express.js.
- **Service**: Firebase Admin SDK.
- **Endpoint**:
  - `GET /words`: Retrieves all words from Firestore ordered by creation date.
  - `POST /words`: Saves a new vocabulary entry to Firestore.
  - `PUT /words/:id`: Updates an existing vocabulary entry in Firestore.
  - `DELETE /words/:id`: Deletes a vocabulary entry from Firestore.

## Setup Instructions

### Backend
1. Go to `backend/` folder.
2. Run `npm install`.
3. Create a `.env` file based on `.env.example`.
4. Set `FIREBASE_SERVICE_ACCOUNT` to your Firebase service account JSON.
5. Run `npm start`.

### Flutter App
1. Go to `flutter-app/` folder.
2. Run `flutter pub get`.
3. Run `flutter run`.
4. If you are on a physical device or a non-standard backend host, pass `--dart-define=API_BASE_URL=http://<your-ip>:3000`.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Node.js (Express)
- **Storage**: Firestore
- **State Management**: Provider
- **Design System**: Material 3 with Google Fonts (Inter)

## Estimated AI Contribution
- **UI**: 70%
- **Backend**: 60%
- **Architecture**: Manual guidance with AI-assisted implementation
