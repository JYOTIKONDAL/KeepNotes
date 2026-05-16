# Keep Notes

A **Google Keep–style** notes app built with Flutter. Create, edit, pin, and delete notes with all data stored **locally on the device** using the [Isar](https://isar.dev/) database.

The project follows **MVVM** architecture with clear separation between UI, business logic, and persistence.

---

## Features

- **Notes list** — View all notes sorted with pinned items first, then by last updated
- **Create & edit** — Title and body with a clean editor screen
- **Pin notes** — Keep important notes at the top of the list
- **Delete** — Remove notes from the list or editor (with confirmation)
- **Offline-first** — No network required; notes live in a local Isar database
- **Reactive UI** — List updates automatically when the database changes
- **Light & dark theme** — Follows system theme (Material 3)
- **Pull to refresh** — Reconnects the notes stream on the home screen

---

## Tech stack

| Area | Technology |
|------|------------|
| Framework | [Flutter](https://flutter.dev/) (Dart SDK ^3.10) |
| Architecture | MVVM |
| State management | [Provider](https://pub.dev/packages/provider) + `ChangeNotifier` |
| Local database | [Isar](https://isar.dev/) 3.x |
| Date formatting | [intl](https://pub.dev/packages/intl) |
| Unit tests | [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) + [mocktail](https://pub.dev/packages/mocktail) |

---

## Project structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # MaterialApp, theme, routing root
├── core/                     # DI, theme, navigation, constants, utils
├── domain/                   # Entities & repository contracts
├── data/                     # Isar models, IsarService, repository impl
└── presentation/             # ViewModels, screens, widgets

test/
├── presentation/viewmodels/  # ViewModel unit tests (mocked repository)
├── data/repositories/        # Repository tests (in-memory Isar)
└── helpers/                  # Fixtures & mocks
```

For layer responsibilities, data flow, and design decisions, see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

Other project docs:

- **[AI_LOG.md](AI_LOG.md)** — AI-assisted development history
- **[REVIEW_LOG.md](REVIEW_LOG.md)** — Code review notes and checklist

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, compatible with Dart ^3.10)
- Android Studio / Xcode (for device or emulator runs)
- A code editor (VS Code, Android Studio, or Cursor)

### Install dependencies

```bash
flutter pub get
```

### Generate Isar code

The `NoteModel` collection requires a generated part file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Re-run this command whenever you change fields on `lib/data/models/note_model.dart`.

### Run the app

```bash
flutter run
```

### Analyze

```bash
flutter analyze
```

---

## Running tests

Unit tests cover **ViewModels** (with mocked `NoteRepository`) and **NoteRepositoryImpl** (with a temporary Isar database).

```bash
flutter test
```

Run a specific suite:

```bash
flutter test test/presentation/viewmodels/
flutter test test/data/repositories/
```

---

## How it works

1. **`main.dart`** bootstraps the app and wraps it in `AppProviders` (dependency injection).
2. **`HomeScreen`** displays notes from `NotesListViewModel`, which listens to `NoteRepository.watchNotes()`.
3. Tapping **+** or a note opens **`NoteEditorScreen`** via `AppRouter`, with its own `NoteEditorViewModel`.
4. **`NoteRepositoryImpl`** reads and writes `NoteModel` records through **`IsarService`**.
5. Domain layer uses the **`Note`** entity; the data layer maps to/from Isar’s **`NoteModel`**.

---

## Configuration

| Constant | File | Purpose |
|----------|------|---------|
| App name | `lib/core/constants/app_constants.dart` | Display name (`Keep Notes`) |
| Isar DB name | `lib/core/constants/app_constants.dart` | Local database instance name |

Android `applicationId` is `com.example.keep_notes` — change it in `android/app/build.gradle.kts` before publishing.

---

## Platform notes

### Android (AGP 8+)

Older versions of `isar_flutter_libs` may not declare an Android `namespace`. This project includes a workaround in `android/build.gradle.kts`. If you see Gradle namespace errors, ensure that file is present.

### iOS

Standard Flutter iOS setup. Open `ios/Runner.xcworkspace` in Xcode for signing and device deployment.

---

## Roadmap ideas

- Google Sign-In gate before home screen
- Search and note labels
- Rich text / images
- Cloud sync and backup
- Isar encryption for sensitive notes

---

## License

This project is for personal and educational use. Add a license file if you plan to distribute it.
