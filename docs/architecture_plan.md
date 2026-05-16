# Lingo-Abyssinia Mobile App: Architecture Plan

## 1. Architecture Overview
The application follows a **Clean Architecture** combined with a **Feature-First** structure. This approach ensures maximum separation of concerns, testability, and scalability. The app is divided into distinct layers (Domain, Data, and Presentation) within each feature module. This guarantees that business logic remains completely independent from UI and external data sources, making it ideal for AI-assisted iteration and large-team scaling.

## 2. Folder Structure
```text
lib/
├── core/                       # App-wide shared code
│   ├── api/                    # Dio client, interceptors
│   ├── config/                 # Environment variables, app configuration
│   ├── error/                  # Failure classes, exception classes
│   ├── routing/                # GoRouter configuration
│   ├── storage/                # Hive/Isar setup and generic adapters
│   ├── theme/                  # Colors, typography, ThemeData
│   └── utils/                  # Extensions, generic helpers
│
├── features/                   # Feature-first modules
│   ├── auth/                   # Example feature: Authentication
│   │   ├── domain/             # Entities, Repositories, Use Cases
│   │   ├── data/               # Models, Remote/Local Data Sources, Repos Impl
│   │   └── presentation/       # BLoC, Pages, Widgets
│   │
│   ├── platform/               # Example feature: Bootstrapping/Routing
│   └── course/                 # Example feature: Language Courses
│
├── injection_container.dart    # get_it service locator setup
└── main.dart                   # App entry point
```

## 3. Layer Responsibilities
*   **Domain:** The innermost layer containing pure Dart. Contains **Entities** (business objects), **Repository Interfaces** (data contracts), and **Use Cases** (business rules).
*   **Data:** The external gateway layer. Contains **Models** (DTOs that parse JSON), **Data Sources** (Remote via Dio, Local via Hive), and **Repository Implementations** (concrete classes fulfilling the Domain contracts).
*   **Presentation:** The UI layer. Contains **BLoC** (state management), **Pages** (full screens), and **Widgets** (reusable UI components).

## 4. Dependency Direction
Dependencies always point **inward** toward the Domain layer.
*   The **Presentation** layer depends on the **Domain** layer (Use Cases).
*   The **Data** layer depends on the **Domain** layer (implements Repository interfaces, converts Models to Entities).
*   The **Domain** layer depends on *nothing*. It contains no references to Flutter, Dio, Hive, or BLoC.

## 5. State Management Strategy
*   **Primary State Management:** **BLoC (Business Logic Component)**.
*   **Usage:** Each feature screen will have a dedicated BLoC or Cubit. 
*   **Events/States:** UI triggers BLoC `Events`. The BLoC executes Use Cases and yields `States` (e.g., `Loading`, `Loaded`, `Error`).
*   **Global State:** Core states like `AuthBloc` (authenticated/unauthenticated) sit high in the widget tree to reactively trigger `go_router` redirects.

## 6. Dependency Injection Strategy
*   **Tool:** **`get_it`**.
*   **Structure:** A central `injection_container.dart` (or multiple feature-specific injection files) registers all singletons and factories.
*   **Registration Order:**
    1. Core external libraries (Dio, Hive).
    2. Data sources.
    3. Repositories.
    4. Use Cases.
    5. BLoCs (registered as Factories, not Singletons, unless app-wide like `AuthBloc`).

## 7. API Layer Structure
*   **Client:** **Dio**.
*   **Interceptors:** A core `AuthInterceptor` is injected into Dio to automatically extract and attach the `lingo_access_token` and `lingo_refresh_token` cookies for authenticated requests, and handle `401/403` status codes for token rotation via `/api/v1/auth/refresh`.
*   **Endpoints:** API endpoints are stored as static constants in a central `ApiConstants` file.

## 8. Repository Pattern Usage
*   The Domain layer defines an abstract class (e.g., `AuthRepository`).
*   The Data layer provides the concrete implementation (e.g., `AuthRepositoryImpl`).
*   The repository is the single source of truth for a feature. It decides whether to fetch data from the `RemoteDataSource` (Dio) or `LocalDataSource` (Hive). It catches specific `Exceptions` and translates them into generic `Failures`.

## 9. Error Handling Strategy
*   **Data Layer:** Catches exceptions (`ServerException`, `CacheException`) thrown by Data Sources.
*   **Domain Layer:** Use Cases return functional error handling types using `dartz` or `fpdart` (e.g., `Future<Either<Failure, Entity>>`).
*   **Presentation Layer:** BLoCs map `Left(Failure)` to `ErrorState` and `Right(Entity)` to `SuccessState`. UI reacts by showing SnackBars or error views.

## 10. Environment Configuration
*   **Tool:** `flutter_dotenv` or native compile-time variables (`--dart-define`).
*   **Environments:** Dev, Staging, and Prod.
*   **Usage:** Environment files hold variables like `BASE_API_URL`. A singleton `AppConfig` class provides typed access to these variables across the app.

## 11. Routing/Navigation Architecture
*   **Tool:** **`go_router`**.
*   **Approach:** Declarative, path-based routing (`/login`, `/learner/dashboard`).
*   **Guards/Redirects:** A `redirect` callback within the router listens to the `AuthBloc` stream. If a user is unauthenticated and tries to access `/learner/dashboard`, they are instantly redirected to `/login`. If bootstrapping (`/api/v1/platform/bootstrap`) assigns a specific dashboard, the router pushes to that path.

## 12. Theme Architecture
*   **Centralization:** Colors, typography, and standard Flutter `ThemeData` (light and dark mode) are defined in `lib/core/theme/`.
*   **Usage:** UI components strictly use `Theme.of(context)` for styling instead of hardcoded values to ensure a cohesive, easily adaptable design system.

## 13. Local Storage Strategy
*   **Tool:** **Hive** (or Isar for relational queries).
*   **Usage:** Used as the `LocalDataSource` in the Data layer.
*   **Data Stored:** User session tokens, cached course data, and offline progress.

## 14. Caching Strategy
*   **Policy:** Cache-first for static learning content (lessons, vocabulary) to enable offline capabilities. Network-first for volatile data (profile progress, leaderboards).
*   **Implementation:** The Repository checks network connectivity. If online, fetch from Remote, save to Hive, and return. If offline or remote fails, read from Hive.

## 15. Authentication Architecture
*   **Flow:** Email/Password login.
*   **Session State:** Controlled by an application-wide `AuthBloc`.
*   **Token Rotation:** Seamlessly handled by the Dio Interceptor. If an API call fails with `401`, the interceptor calls `/api/v1/auth/refresh`, updates the stored cookies, and retries the original request without UI interruption.

## 16. Logging/Debugging Strategy
*   **Tool:** `logger` package or `talker_flutter`.
*   **Usage:** Avoid standard `print()`. Use specific log levels (Debug, Info, Warning, Error).
*   **Network:** Add `LogInterceptor` to Dio in debug mode to trace requests, headers, and responses. BLoC transitions are logged using `BlocObserver`.

## 17. Testing Strategy
*   **Unit Tests:** Essential for Use Cases (Domain), Repository Implementations (Data), and BLoCs (Presentation). Mock dependencies using `mockito` or `mocktail`.
*   **Widget Tests:** For critical reusable UI components in `core/` and specific complex screens.
*   **Integration Tests:** End-to-end flows like the Registration -> Bootstrapping -> Dashboard sequence.

## 18. Naming Conventions
*   `snake_case` for files and folders (e.g., `auth_repository_impl.dart`).
*   `PascalCase` for classes (e.g., `AuthRepositoryImpl`).
*   `camelCase` for variables and functions.
*   Suffixes applied to architectural components: `...Repository`, `...DataSource`, `...UseCase`, `...Model`, `...Bloc`, `...Event`, `...State`, `...Page`.

## 19. Feature Module Structure
A typical feature folder (e.g., `course/`):
```text
course/
├── domain/
│   ├── entities/course.dart
│   ├── repositories/course_repository.dart
│   └── usecases/get_courses.dart
├── data/
│   ├── models/course_model.dart
│   ├── datasources/course_remote_data_source.dart
│   ├── datasources/course_local_data_source.dart
│   └── repositories/course_repository_impl.dart
└── presentation/
    ├── bloc/course_bloc.dart
    ├── bloc/course_event.dart
    ├── bloc/course_state.dart
    ├── pages/course_list_page.dart
    └── widgets/course_card.dart
```

## 20. Example Feature Implementation Flow
**Task: Display a list of courses.**
1.  **Domain:** Create `Course` entity and `CourseRepository` interface. Create `GetCoursesUseCase` which calls `repository.getCourses()`.
2.  **Data:** Create `CourseModel` (with `fromJson`). Create `CourseRemoteDataSource` which executes the Dio GET request. Create `CourseRepositoryImpl` which binds the data source and maps `CourseModel` to `Course` entity.
3.  **DI:** Register data source, repository, use case, and BLoC in `injection_container.dart`.
4.  **Presentation (BLoC):** Create `CourseBloc`. On `FetchCoursesEvent`, execute `GetCoursesUseCase`. Emit `CourseLoading`, then `CourseLoaded(courses)` or `CourseError(message)`.
5.  **Presentation (UI):** Create `CourseListPage`. Use `BlocBuilder<CourseBloc, CourseState>` to show a `CircularProgressIndicator`, an `ErrorWidget`, or a `ListView` of `CourseCard` widgets based on the emitted state.
