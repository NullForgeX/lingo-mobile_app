# Hive Data Storage & Caching Documentation

This document describes how **Hive** (a lightweight, fast, key-value database written in pure Dart) is integrated and utilized in the **Lingo-Abyssinia** mobile application.

---

## 1. Overview & Architecture

Hive is used for offline-first support, guest user progress tracking, curriculum caching, and persistent settings storage. By utilizing Hive, the app achieves:
- **Instant load times** by displaying cached data before fetching network updates.
- **Robust offline support** enabling users to complete downloaded lessons and cache progress without internet access.
- **Guest Mode continuity**, allowing users to save their progress locally and later synchronize it automatically when they register or log in.

---

## 2. Initialization & Setup

Hive is initialized in the main entry point of the app: [main.dart](file:///c:/Users/Nami/Desktop/programs/Lingo-Abyssinia/lingo-mobile_app/lib/main.dart).

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local data storage
  await Hive.initFlutter();
  
  // Open Hive boxes for guest data, cache, and preferences
  await Hive.openBox('guest_attempts_box');
  await Hive.openBox('guest_dashboard_box');
  await Hive.openBox('auth_preferences_box');
  await Hive.openBox('curriculum_cache_box');
  await Hive.openBox('auth_dashboard_box');
  await Hive.openBox('auth_attempts_box');

  await di.init();
  runApp(const LingoApp());
}
```

By opening all boxes at launch, we ensure they are available synchronously elsewhere in the app via `Hive.box('box_name')`.

---

## 3. Storage Boxes & Data Structures

The application utilizes six specific Hive boxes:

### 3.1. `auth_preferences_box`
Contains critical application state and persistent user preferences.
- **Key: `'isGuest'` (`bool`)**: Determines whether the app is currently in Guest Mode. Used across multiple Blocs to route users or toggle offline behavior.
- **Key: `'preferredLanguageId'` (`String?`)**: Stores the ID of the user's selected language.

### 3.2. `guest_attempts_box`
Stores lesson and exercise attempts completed by a Guest user.
- **Structure**: A collection of serialized map objects.
- **Key Fields per Attempt**:
  ```json
  {
    "lessonId": "string",
    "lessonTitle": "string",
    "score": 4,
    "maxScore": 5,
    "passed": true,
    "xpEarned": 14,
    "startedAt": "ISO-8601 String",
    "completedAt": "ISO-8601 String",
    "answers": [
      {
        "exerciseId": "string",
        "isCorrect": true,
        "selectedOptionIds": ["string"], // MC questions
        "response": "string"             // Text input questions
      }
    ]
  }
  ```

### 3.3. `guest_dashboard_box`
Caches the guest user's profile and progress.
- **Key: `'dashboard'` (`Map<String, dynamic>`)**: Stores local user statistics.
- **Structure**:
  ```json
  {
    "streak": {
      "currentDays": 3,
      "lastActiveDate": "YYYY-MM-DD"
    },
    "xp": {
      "totalXp": 120,
      "lessonCompletionXp": 120,
      "assessmentXp": 0,
      "badgeXp": 0
    },
    "progress": [
      {
        "lessonId": "string",
        "lessonTitle": "string",
        "languageName": "Amharic",
        "completionPercentage": 100.0
      }
    ],
    "recentAttempts": [
      {
        "id": "attempt_id",
        "lessonId": "string",
        "lessonTitle": "string",
        "scoreSummary": {
          "percentage": 100.0
        },
        "startedAt": "ISO-8601 String"
      }
    ],
    "preferredLanguage": {
      "id": "amharic",
      "name": "Amharic",
      "nativeName": "አማርኛ"
    },
    "dailyLearningGoalMinutes": 15
  }
  ```

### 3.4. `curriculum_cache_box`
Caches lesson curriculum metadata, runtimes, and downloaded components.
- **Keys**:
  - `'lessons_$unitId'` (`List<dynamic>`): List of lessons associated with a Unit.
  - `'lesson_detail_$lessonId'` (`Map<String, dynamic>`): Information about a specific lesson.
  - `'lesson_runtime_$lessonId'` (`Map<String, dynamic>`): Runtime questions/exercises for a lesson.
  - `'downloaded_units'` (`List<String>`): A list of Unit IDs that have been fully cached for offline use.

### 3.5. `auth_dashboard_box`
Stores a cached version of the authenticated user's dashboard fetched from the API.
- **Key: `'dashboard'` (`Map<String, dynamic>`)**: Structure mirrors the backend user dashboard payload. It is loaded when the app starts offline to prevent empty screens.

### 3.6. `auth_attempts_box`
Temporarily caches completed attempts of an authenticated user while offline.
- **Structure**: Same schema as `guest_attempts_box`. It accumulates attempts when remote submissions fail, ready to be synchronized when online.

---

## 4. Key Workflows & Operations

### 4.1. Guest-to-Authenticated Synchronization
When a guest user logs in or registers, the application syncs their offline progress to their newly created or signed-in account. This occurs in `_syncAllOfflineAttempts` within [AuthBloc](file:///c:/Users/Nami/Desktop/programs/Lingo-Abyssinia/lingo-mobile_app/lib/features/auth/presentation/bloc/auth_bloc.dart#L176):

1. Reads all elements from `guest_attempts_box` and `auth_attempts_box`.
2. Calls `authRepository.syncOfflineAttempts(attempts)` to upload the JSON payload to the remote server.
3. Upon success, clears `guest_attempts_box` and `auth_attempts_box`.
4. Clears guest preferences and sets `isGuest` to `false` in `auth_preferences_box`.

### 4.2. Offline Caching & Background Downloading
When browsing curriculum units or lessons, the application pre-caches curriculum data:
- **Auto Pre-Caching**: While getting lessons for a unit, the [CurriculumRepositoryImpl](file:///c:/Users/Nami/Desktop/programs/Lingo-Abyssinia/lingo-mobile_app/lib/features/curriculum/data/repositories/curriculum_repository_impl.dart#L100) automatically triggers an asynchronous background process `_preCacheUnitLessons` to fetch and store details and runtimes for all lessons inside `curriculum_cache_box`.
- **Manual Download**: Users can trigger `downloadUnit(unitId)` which explicitly downloads all lessons, details, and exercise runtimes, adding the unit to `'downloaded_units'`.

### 4.3. Offline Attempt Processing
When a user finishes a lesson while offline (or is in Guest Mode), [PracticeBloc](file:///c:/Users/Nami/Desktop/programs/Lingo-Abyssinia/lingo-mobile_app/lib/features/practice/presentation/bloc/practice_bloc.dart#L208) evaluates their answers locally:
1. Calculates score, XP earned, passing status, and generates immediate feedback based on static/cached data.
2. Formats and saves the attempt record into `guest_attempts_box` (if a guest) or `auth_attempts_box` (if logged-in but offline).
3. Updates the dashboard metrics (XP, streak, progress) in the corresponding local dashboard box (`guest_dashboard_box` or `auth_dashboard_box`).

---

## 5. Development Guidelines & Best Practices

1. **Avoid Custom TypeAdapters**: Instead of generating adapters via `hive_generator` (which can create compatibility problems when models evolve), serialize models to JSON (`Map<String, dynamic>` / `List<dynamic>`) before storing them.
2. **Synchronous Reads**: For quick lookups in UI widgets or Blocs, retrieve values directly using synchronous calls (e.g., `Hive.box('auth_preferences_box').get('isGuest')`).
3. **Deep Copies & Casting**: Hive boxes return data as `Map<dynamic, dynamic>` or `List<dynamic>`. Always create deep copies of typed maps or lists before altering them to prevent type-casting errors:
   ```dart
   final dashboard = Map<String, dynamic>.from(box.get('dashboard', defaultValue: <String, dynamic>{}) as Map);
   ```
4. **Data Purging**: When a user logs out, always invoke `clear()` on guest boxes (`guest_attempts_box`, `guest_dashboard_box`) so that a new user starts with a clean slate.
