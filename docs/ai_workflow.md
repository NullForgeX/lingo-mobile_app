# Lingo-Abyssinia Mobile App: AI Development Workflow

This document establishes the operational rules and constraints for AI-assisted development on the Lingo-Abyssinia Flutter project. Strict adherence to this workflow ensures predictable, scalable, and maintainable project evolution.

## 1. AI Development Principles
*   **Incremental Progress:** Build one verifiable vertical slice at a time.
*   **Predictability:** Never guess architecture; strictly follow `architecture_plan.md`.
*   **Traceability:** Every code change must be tied to an active task in the `progress_tracker.md`.
*   **Minimal Intrusion:** Only modify files explicitly related to the current task scope.

## 2. Feature-by-Feature Development Workflow
1.  **Define Scope:** Identify the single feature from the Pending Features list.
2.  **Analyze Context:** Read relevant domain, data, and presentation files.
3.  **Execute Logic (Domain):** Create entities, repositories (interfaces), and use cases.
4.  **Execute Data (Data):** Create models, remote/local data sources, and repository implementations.
5.  **Execute UI (Presentation):** Create BLoC, Pages, and Widgets.
6.  **Wire Dependencies:** Update `injection_container.dart`.
7.  **Update Tracker:** Mark feature complete in `progress_tracker.md`.

## 3. Task Scoping Rules
*   **One Feature at a Time:** Do not parallelize unrelated features (e.g., do not build "Login" and "Course List" simultaneously).
*   **Granularity:** Break down features into Domain -> Data -> Presentation steps. Do not attempt full-stack feature generation in a single monolithic prompt/response.

## 4. File Modification Rules
*   **Target Specificity:** Only open and edit files strictly necessary for the current step.
*   **Explain Purpose:** Add a brief comment or docstring to newly generated files explaining their specific role within the Clean Architecture.
*   **Do Not Touch Unrelated Modules:** Never refactor or alter code outside the current feature's directory unless it is a core utility required by the new feature.

## 5. Refactoring Rules
*   **No Unprompted Refactoring:** Do not refactor existing logic simply for aesthetic reasons while working on a new feature.
*   **Isolation:** If refactoring is necessary (e.g., extracting a core widget), it must be treated as a distinct, standalone task logged in the progress tracker.

## 6. Progress Tracking Rules
*   **Mandatory Updates:** The `progress_tracker.md` must be updated at the start and end of every active feature.
*   **Blocker Logging:** Any API missing endpoints, missing design tokens, or logic conflicts must be logged immediately in the tracker before proceeding.

## 7. Prompt Engineering Rules
*   **Context Provision:** Prompts must explicitly state the current layer (Domain/Data/Presentation) and the target feature folder.
*   **Constraint Reminders:** Prompts must remind the AI to adhere to `architecture_plan.md` and `design_system.md`.

## 8. Code Review Workflow
*   **Self-Verification:** Before declaring a task "Done", the AI must verify that imports are correct, BLoC events are correctly mapped, and no magic numbers violate the design system.
*   **Linting:** Code must pass standard Flutter lint rules (`flutter analyze`) without warnings.

## 9. Testing Workflow
*   **Unit Tests First (Optional but Recommended):** For complex Use Cases or BLoCs, generate unit tests simulating `Right` (success) and `Left` (failure) paths.
*   **Mock Dependencies:** Always use mocked repositories (via `mockito` or `mocktail`) when testing Use Cases or BLoCs.

## 10. Documentation Update Workflow
*   **Living Documents:** If a new core utility, theme token, or architectural pattern is introduced, immediately update the corresponding `.md` file in the `docs/` directory.

## 11. Architecture Protection Rules
*   **Strict Boundary Enforcement:** 
    *   `Domain` must never import `Data` or `Presentation`.
    *   `Domain` must never import `Flutter` material/cupertino libraries.
    *   `Presentation` must never access `DataSources` directly (must use BLoC -> UseCase -> Repository Interface).

## 12. Dependency Management Rules
*   **No Unauthorized Packages:** Do not add third-party packages to `pubspec.yaml` without explicit user permission. Rely on the approved tech stack (Dio, get_it, go_router, BLoC, Hive).

## 13. Git Workflow Strategy
*   **Atomic Commits:** (If applicable) Commit after each layer of a feature is complete (e.g., `feat(auth): add domain layer for login`).
*   **Branching:** Use feature branches (e.g., `feature/auth-login`) extending from `main`.

## 14. AI Context Management
*   **Context Window Optimization:** Close out old files. Only keep the immediate UseCase, Repository, and Model open in context when working on a specific data flow.
*   **Reference Documents:** Keep `architecture_plan.md` and `design_system.md` pinned in the AI's contextual awareness.

## 15. Rules for Editing Existing Files
*   **Targeted Edits:** Use precise line replacements rather than overwriting entire files.
*   **Preserve Existing Logic:** Ensure new additions do not break existing Use Cases or BLoC states.

## 16. Rules for Generating New Features
*   **Template Matching:** Follow the exact folder structure defined in `architecture_plan.md` Section 19.
*   **Naming Conventions:** Strictly adhere to `snake_case` for files and `PascalCase` for classes.

## 17. Rules for Avoiding Duplicate Logic
*   **Prefer Existing Code:** Before generating a new HTTP interceptor, error failure class, or UI widget (like a standard button), check the `core/` directory to see if one already exists.
*   **Extraction:** If logic is written twice across different features, extract it to `core/utils/` or `core/widgets/`.

## 18. Rules for Maintaining Consistency
*   **UI System:** All UI elements must use `Theme.of(context)` or `CustomColors` defined in `design_system.md`. No hardcoded HEX colors or arbitrary padding values.

## 19. Feature Completion Checklist
- [ ] Domain logic (Entities, Repositories, Use Cases) implemented.
- [ ] Data layer (Models, Data Sources, ReposImpl) implemented.
- [ ] Presentation layer (BLoC, UI Pages) implemented.
- [ ] Dependency Injection (`get_it`) wired up.
- [ ] UI strictly follows `design_system.md`.
- [ ] `progress_tracker.md` updated.

## 20. Definition of Done
A feature is "Done" only when:
1.  All code is generated and accurately placed in the Clean Architecture folders.
2.  There are no syntax errors or static analysis warnings.
3.  The feature is registered in the DI container and accessible via `go_router`.
4.  The `progress_tracker.md` has been updated to reflect 100% completion for this specific task.
