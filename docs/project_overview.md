# Lingo-Abyssinia Mobile App: Project Overview

## 1. Project Summary
Lingo-Abyssinia is a comprehensive mobile language learning application designed to facilitate structured language education. The application connects learners with educational content while providing robust management tools for administrators and content creators through a secure, role-based architecture.

## 2. Core Business Problem
Traditional language learning can be unstructured and difficult to track. Lingo-Abyssinia solves this by providing a unified, accessible platform that not only guides learners through a structured curriculum but also offers a clear separation of concerns for content creators and system administrators to efficiently manage the educational ecosystem.

## 3. Target Users
*   **Learners:** Individuals seeking to learn new languages through structured modules and tracking.
*   **Content Managers:** Educational professionals and content creators who design, upload, and manage language courses.
*   **System Admins:** Technical and administrative staff responsible for platform maintenance and user management.

## 4. Main App Features
*   Secure user registration and authentication.
*   Dynamic, role-based platform routing and bootstrapping.
*   Language learning modules and interactive lessons.
*   User profile and progress tracking.
*   Content management dashboards (for authorized roles).
*   Automated session management and token rotation.

## 5. User Roles
*   **Learner:** The primary end-user consuming educational content.
*   **Content Manager:** Users with elevated privileges to create and modify lessons.
*   **System Admin:** Users with full administrative access to manage the platform and user accounts.

## 6. Functional Requirements
*   **Authentication:** Users must be able to securely register, log in, and log out using email and password.
*   **Session Management:** The app must automatically refresh user sessions using refresh tokens without disrupting the user experience.
*   **Bootstrapping:** The app must fetch initial platform configurations and recommended dashboards based on the user's role upon startup.
*   **Content Delivery:** The app must fetch, display, and track progress on language courses.

## 7. Non-Functional Requirements
*   **Performance:** The app should have fast load times and smooth transitions (minimum 60 FPS).
*   **Usability:** A highly intuitive, accessible, and responsive user interface.
*   **Efficiency:** Minimal battery and data consumption during active learning sessions.
*   **Reliability:** Graceful error handling for network timeouts or API rate limits.

## 8. Technical Requirements
*   **Architecture:** Clean Architecture pattern (Domain, Data, and Presentation layers) to ensure scalability and testability.
*   **API Communication:** Robust HTTP client implementation with interceptors to manage secure cookies (`lingo_access_token` and `lingo_refresh_token`).
*   **State Management:** Predictable state management solution (e.g., BLoC, Riverpod, or Redux) to separate UI from business logic.
*   **Platform:** Cross-platform framework (Flutter or React Native) targeting both iOS and Android.

## 9. App Flow Overview
1.  **Launch:** Splash Screen displays while the app initializes.
2.  **Bootstrap:** App calls `/api/v1/platform/bootstrap` to determine session state and configuration.
3.  **Auth Routing:** 
    *   *Unauthenticated:* Directed to the Login / Registration flow.
    *   *Authenticated:* Directed to the appropriate dashboard.
4.  **Dashboard:** Role-specific landing page (Learner Dashboard, Content Manager Dashboard, or Admin Dashboard).
5.  **Core Flow:** Users navigate through courses, lessons, and profile settings.

## 10. Authentication Flow
*   **Login/Register:** User submits credentials to `/api/v1/auth/login` or `/register`.
*   **Tokens:** Backend returns a success response and sets HTTP-only cookies for access and refresh tokens.
*   **Rotation:** When the access token expires, the app silently calls `/api/v1/auth/refresh` using the refresh token cookie to obtain a new access token.
*   **Logout:** App calls `/api/v1/auth/logout` to revoke the session and clear local states.

## 11. Offline/Online Behavior
*   **Online Mode:** Full access to all features, real-time progress syncing, and content updates.
*   **Offline Mode:** Users can access previously cached lessons and profile data. Progress made offline is queued locally and synchronized with the backend once the connection is restored. Critical actions (like authentication) require an active connection.

## 12. API Integration Overview
The app integrates with the Lingo-Abyssinia REST API (v1), specifically handling:
*   **System Routes:** `/healthz`, `/readyz` for status checks.
*   **Platform Routes:** `/api/v1/platform/bootstrap` for session and role detection.
*   **Auth Routes:** `/api/v1/auth/register`, `/login`, `/refresh`, `/logout`, and `/me`.

## 13. Notification Requirements
*   **Push Notifications:** Reminders to complete daily lessons to maintain streaks.
*   **In-App Alerts:** Notifications regarding new course availability, platform updates, or critical account security alerts.

## 14. Security Considerations
*   **Token Handling:** Secure storage and transmission of authentication tokens via secure HTTP-only cookies.
*   **Data Protection:** TLS/SSL encryption for all API communications.
*   **Rate Limiting:** UI must handle `429 Too Many Requests` gracefully, providing user feedback without crashing.
*   **Access Control:** Strict client-side route guarding based on the user's role payload.

## 15. Scalability Considerations
*   **Modular Codebase:** Clean Architecture ensures new features (e.g., new languages or game mechanics) can be added without modifying core logic.
*   **Data Pagination:** Implementation of infinite scrolling or pagination for large lists (e.g., course catalogs or user lists) to minimize memory usage.

## 16. Future Expansion Possibilities
*   **Gamification:** Integration of leaderboards, achievement badges, and learning streaks.
*   **Social Features:** Community forums, chat capabilities, and peer-to-peer language exchange.
*   **Live Tutoring:** Integration with video/audio APIs for live language practice sessions.
*   **Expanded Content:** Support for additional regional dialects and languages.

## 17. Constraints and Assumptions
*   **Backend Dependency:** The app relies heavily on the availability and uptime of the NestJS backend.
*   **Device Compatibility:** Assumes users are operating on modern iOS and Android devices supporting current cross-platform SDKs.
*   **Network:** Assumes users have an active internet connection for the initial setup and content downloading phases.
