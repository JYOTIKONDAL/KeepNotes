# Keep Notes — Architecture

This document describes the **MVVM** structure, layers, and data flow for the Keep Notes Flutter app.

## Overview

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | UI (Views), state & user actions (ViewModels) |
| **Domain** | Business entities and repository contracts |
| **Data** | Isar persistence, models, repository implementations |
| **Core** | DI, constants, shared utilities |

State management uses **Provider** with `ChangeNotifier` ViewModels.

Persistence uses **Isar** (local NoSQL database).

## Project structure

```
lib/
├── main.dart                          # App entry (bootstrap)
├── core/
│   ├── constants/app_constants.dart   # App name, DB instance name
│   ├── di/app_providers.dart          # Provider / DI wiring
│   └── utils/date_formatter.dart      # Note date formatting
├── domain/
│   ├── entities/note.dart             # Domain Note entity
│   └── repositories/note_repository.dart
├── data/
│   ├── models/
│   │   ├── note_model.dart            # Isar @collection model
│   │   └── note_model.g.dart          # Generated (build_runner)
│   ├── datasources/local/
│   │   └── isar_service.dart          # Opens / holds Isar instance
│   └── repositories/
│       └── note_repository_impl.dart  # CRUD via Isar
└── presentation/
    ├── viewmodels/
    │   ├── base_view_model.dart
    │   ├── notes_list_view_model.dart
    │   └── note_editor_view_model.dart
    └── views/
        ├── screens/
        │   └── note_editor_screen.dart
        └── widgets/
            ├── note_list_tile.dart
            └── empty_notes_view.dart
```

## MVVM mapping

| MVVM | Implementation |
|------|----------------|
| **Model** | `Note` entity + `NoteRepository` + Isar `NoteModel` |
| **View** | `NoteEditorScreen`, widgets (`NoteListTile`, `EmptyNotesView`) |
| **ViewModel** | `NotesListViewModel`, `NoteEditorViewModel` (extend `BaseViewModel`) |

Views observe ViewModels via `context.watch` / `Provider`. ViewModels call the repository; they do not talk to Isar directly.

## Data flow

### List notes (reactive)

```
NoteEditorScreen / Home (View)
        ↓ watch / listen
NotesListViewModel
        ↓ watchNotes()
NoteRepository (interface)
        ↓
NoteRepositoryImpl → IsarService → Isar.noteModels.watch()
        ↓ map to List<Note>
UI updates via notifyListeners()
```

### Create / update note

```
NoteEditorScreen
        ↓ save()
NoteEditorViewModel.save()
        ↓
NoteRepository.saveNote(Note)
        ↓
NoteRepositoryImpl → Isar writeTxn → put(NoteModel)
```

### Delete note

```
NoteEditorScreen or list tile
        ↓
NoteEditorViewModel.delete() / NotesListViewModel.deleteNote()
        ↓
NoteRepository.deleteNote(id)
        ↓
Isar.noteModels.delete(id)
```

## Dependency injection

`AppProviders` registers:

1. `IsarService` — singleton database accessor  
2. `NoteRepository` → `NoteRepositoryImpl` (via `ProxyProvider`)  
3. `NotesListViewModel` — created at app root, `init()` starts `watchNotes()`  

`NoteEditorViewModel` is provided per route via `AppProviders.noteEditorProvider()`.

## Domain vs data models

- **`Note`** (`domain/entities/note.dart`) — plain Dart class used by ViewModels and UI.  
- **`NoteModel`** (`data/models/note_model.dart`) — Isar collection with `@collection`.  
- **`NoteModelMapper`** extension — `toEntity()` / `fromEntity()` between layers.

Repository implementations always map `NoteModel` ↔ `Note` before returning to the domain layer.

## Isar code generation

`note_model.g.dart` is **generated** and must not be edited by hand.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Regenerate after changing fields on `NoteModel`.

## Android build (AGP 8+)

`isar_flutter_libs` 3.1.0 does not declare an Android `namespace`. The root `android/build.gradle.kts` applies a subproject workaround for library plugins missing a namespace.

## Planned / missing pieces

- `app.dart` and `home_screen.dart` for a wired `main.dart` entry  
- Unit/widget tests for ViewModels and repository  
- Search, labels, and sync (out of scope for base structure)

## Key dependencies

| Package | Role |
|---------|------|
| `isar` / `isar_flutter_libs` | Local database |
| `path_provider` | App documents directory for Isar files |
| `provider` | DI and ViewModel exposure |
| `intl` | Date formatting in list UI |
