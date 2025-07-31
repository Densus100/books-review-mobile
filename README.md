# Book Review Mobile App

A cross-platform Flutter application for browsing, reviewing, and managing favorite books. Users can log in, search for books, read and write reviews, and manage their favorite books. The app communicates with a RESTful API backend.

---

## Features

- User authentication (login/logout)
- Browse a list of books
- View detailed information and reviews for each book
- Add reviews
- Mark books as favorites
- Search for books
  

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart 3.7.2 or compatible
- Android Studio, Xcode, or Visual Studio Code (for running on Android/iOS/desktop)
- A running backend API ([books-review-backend](https://github.com/Densus100/books-review-backend), see `lib/services/api_service.dart` for base URL)

## Backend

This app requires a backend RESTful API to function. You can find the backend source code, setup instructions, and API documentation here:

- [books-review-backend](https://github.com/Densus100/books-review-backend)

Make sure to clone and run the backend locally or deploy it, then update the API base URL in `lib/services/api_service.dart` if needed.

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/Densus100/books-review-mobile.git
   cd books-review-mobile/books_review
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

### Project Structure

- `lib/models/` – Data models (Book, Review, User, etc.)
- `lib/screens/` – UI screens (Home, Login, Book Detail, etc.)
- `lib/services/` – API service classes
- `lib/widgets/` – Reusable UI components

### Configuration
- The API base URL is set to `http://10.0.2.2:3000/api/v1` (see `lib/services/api_service.dart`). Change this if your backend runs elsewhere.

## Useful Commands

- Run on Android/iOS:
  ```sh
  flutter run
  ```
- Run tests:
  ```sh
  flutter test
  ```

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
This project is open source.
