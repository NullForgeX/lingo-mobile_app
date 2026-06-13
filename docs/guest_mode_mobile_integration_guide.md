# Mobile App Guest Mode Integration Guide

This guide is a prompt/specification for the mobile app development agent to integrate Guest Mode and unauthenticated user flows into the Flutter app.

---

## 1. Goal Overview
Refactor the authentication flow so that the app defaults to Guest Mode on first launch (booting directly onto the dashboard `/home` screen) instead of locking the user to `/login`. Users should be able to select language courses, view unit lessons, and practice quizzes offline.

---

## 2. Step-by-Step Instructions

### Step A: Default GoRouter Location to `/home`
- In `lib/core/routes/app_router.dart`:
  - Change `initialLocation` from `/login` to `/home`.

### Step B: Auto-Transition to Guest Mode on Startup
- In `lib/features/auth/presentation/bloc/auth_bloc.dart`:
  - Locate `_onCheckAuthStatus`.
  - Currently, if the backend session retrieval fails and `isGuest` is false, it emits `AuthUnauthenticated()`.
  - **Refactor**: If `getCurrentUser()` fails, automatically write `isGuest = true` to `auth_preferences_box` and emit `AuthGuest()`.
  - *Rationale*: If a user does not have a saved session on the backend, they must automatically be treated as a Guest so they can browse the dashboard cleanly.

### Step C: Local Guest Language Selection
- In `lib/features/curriculum/presentation/bloc/curriculum_bloc.dart`:
  - Locate `SelectLanguageEvent` handler.
  - Currently, it always runs `repository.selectLanguage(event.languageId)`, which hits the backend `/select` endpoint and will fail with `401 Unauthorized` for guests.
  - **Refactor**: Read `isGuest` from `auth_preferences_box`.
  - If `isGuest == true`:
    1. Call the local `repository.getLanguageDetail(event.languageId)` (or cache) to fetch details like name, nativeName, script, and summary.
    2. Write this data to the `guest_dashboard_box` under the keys `preferredLanguage` (e.g. `{'id': event.languageId, 'name': ..., 'nativeName': ..., 'script': ..., 'summary': ...}`).
    3. Emit `LanguageSelectedState` containing a mock/guest `User` entity, bypassing the network select endpoint.

### Step D: Auto-Redirect to Units Screen in Practice Tab
- In `lib/features/curriculum/presentation/screens/languages_screen.dart`:
  - Inside `initState`, read the `AuthBloc` state or `guest_dashboard_box` to see if a preferred language has already been selected.
  - If a preferred language ID exists, run a post-frame callback: `context.go('/units/$prefLanguageId')`.
  - *Rationale*: If a guest or user has already chosen a course language, clicking the "Languages" tab should take them directly to their units and lessons, not back to the list of languages.

### Step E: Fix Back Button Redirection in Units Screen
- In `lib/features/curriculum/presentation/screens/units_screen.dart`:
  - Inside the `AppBar`, define an explicit `leading` back button:
    ```dart
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        context.go('/home');
      },
    ),
    ```
  - *Rationale*: Tapping back in `UnitsScreen` after redirection could trigger an infinite redirect loop if it goes back to `LanguagesScreen`. Going directly to `/home` ensures clean navigation.

### Step F: Add Login Recommendation Banner to Dashboard
- In `lib/features/home/presentation/pages/learner_home_screen.dart`:
  - Add a custom banner widget `_buildLoginRecommendation(BuildContext context)`.
  - Use `BlocBuilder<AuthBloc, AuthState>` to render this banner **only** if the state is `AuthGuest`.
  - Design: A modern alert box stating *"Save Your Progress! Create an account to save your streak and sync your achievements."* with a button titled *"Sign In"* that calls `context.push('/login')`.
  - Place this banner inside the main scrollable Column directly beneath the header widget (`_buildHeader(context)`).

---

## 3. Local Offline Grading Specifications
- In `lib/features/practice/presentation/bloc/practice_bloc.dart`, the local grading logic is already implemented! Keep these checks intact:
  - Exercises in `GET /learning/lessons/:lessonId/runtime` payload now include:
    - `correctOptionIds: string[]` for multiple choice and listening exercises.
    - `acceptedAnswers: string[]` for text-based translation exercises.
  - Local grading performs normalization (lowercase, trim, whitespace collapse) on translation responses and checks against `acceptedAnswers` to score the quiz and save it to the Hive box `guest_attempts_box`.
  - On user login or registration, the attempts saved in `guest_attempts_box` are batched and posted to `POST /learning/attempts/sync` for database synchronization.
