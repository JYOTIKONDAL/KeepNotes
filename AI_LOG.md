# AI Development Log

Chronological log of AI-assisted development for **Keep Notes**. This log serves as an audit trail demonstrating the collaborative boundary between human engineering oversight and AI code generation.

---

## Entry 1: Project Architecture Scaffolding
* **Prompt:** "Create a modern, clean architecture folder structure for a production-ready Flutter app."
* **AI Response:** Suggested a strict Clean Architecture layout split into `domain`, `data`, and `presentation` layers.
* **Assessment:** **Accepted.** This structural template cleanly isolates our pure business logic from Flutter UI rendering layers.

## Entry 2: Choosing State Management
* **Prompt:** "What is the best state management approach for a localized, lightweight CRUD notes app using MVVM?"
* **AI Response:** Suggested utilizing the `provider` and `ProxyProvider` packages for simple dependency injection and view state updates.
* **Assessment:** **Accepted.** Heavy tools like BLoC or Riverpod would introduce unnecessary boilerplate for a simple local CRUD application. Provider keeps the code lean, fast, and testable.

## Entry 3: Isar Model Definition
* **Prompt:** "Write an Isar database model class for a Note entity."
* **AI Response:** Provided a `NoteModel` class using `@collection` annotations.
* **Assessment:** **Accepted.** The generated model layout for fields like `id`, `title`, and `content` was structurally sound.

## Entry 4: REJECTED / REWORKED — Leak in Architectural Boundaries
* **Prompt:** "How should I pass data from my Isar database layer to my Flutter UI widgets?"
* **AI Response:** The AI generated code where the UI view layer directly imported `isar` and read raw `NoteModel` items out of the reactive stream.
* **Assessment:** **REJECTED.** This approach violates the MVVM architecture guidelines outlined in our project specifications. The presentation layer must never have a direct dependency on the data layer or a specific storage technology (Isar).
* **Action Taken:** I forced the AI to refactor the implementation. I introduced an abstract `NoteRepository` interface in the domain layer and built a `NoteModelMapper` extension in the data layer to map database-specific `NoteModel` objects into pure UI-safe `Note` entities before exposing them to the UI.

## Entry 5: Build Runner Errors
* **Prompt:** "My `dart run build_runner build` is failing because of missing generated files for Isar."
* **AI Response:** Suggested running the generator command with the `--delete-conflicting-outputs` flag.
* **Assessment:** **Modified.** The AI correctly identified the command, but failed to recognize that the build runner was failing primarily because `main.dart` still had compile-time syntax errors (like invalid `.fromSeed` properties). I manually fixed the syntax errors in `main.dart` first, then executed the build runner cleanly.

## Entry 6: REJECTED / REWORKED — Android Gradle Plugin 8+ Namespace Crash
* **Prompt:** "Fix this Android build error: 'Namespace not specified ... isar_flutter_libs-3.1.0+1/android/build.gradle'"
* **AI Response:** The AI suggested downgrading my global Flutter SDK version or editing the Gradle cache files inside my local machine's `.pub-cache` directory directly.
* **Assessment:** **CRITICALLY REJECTED.** Editing dependencies inside `.pub-cache` is dangerous anti-pattern. It creates an untracked environment state that will break continuous integration (CI/CD) pipelines and crash builds on other developers' systems.
* **Action Taken:** I rejected the workaround and instead authored a clean subproject configuration block inside `android/build.gradle.kts` using `pluginManager.withPlugin("com.android.library")` to inject the namespace dynamically at compile time across external dependencies.

## Entry 7: ViewModel Core Logic Setup
* **Prompt:** "Write a base class for my view models to handle loading states uniformly."
* **AI Response:** Provided a `BaseViewModel` extending `ChangeNotifier` with error states.
* **Assessment:** **Accepted.** Standard MVVM boilerplate that successfully prevents UI code duplication.

## Entry 8: Note Sorting Streams
* **Prompt:** "How can I keep my notes UI in sync with the Isar database reactively?"
* **AI Response:** Provided a stream listener calling `watchNotes()` with `sortByUpdatedAtDesc()`.
* **Assessment:** **Accepted.** Leveraging Isar's native streams prevents us from writing manual data-refresh logic.

## Entry 9: UI Components Generation
* **Prompt:** "Generate standard Flutter widgets for `NoteEditorScreen` and `NoteListTile` using Material 3."
* **AI Response:** Provided clean layout code for the text fields and cards using standard Material 3 parameters.
* **Assessment:** **Accepted.** This significantly accelerated development velocity by delegating routine layout configurations to the model.

## Entry 10: Code Review Documentation Strategy
* **Prompt:** "Create a review checklist template evaluating an app against strict Flutter MVVM guidelines."
* **AI Response:** Generated a comprehensive markdown checklist tracking layer separation, dependency constraints, and disposal rules.
* **Assessment:** **Accepted.** Perfect addition for our pre-merge testing routines.