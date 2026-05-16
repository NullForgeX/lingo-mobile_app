# Lingo-Abyssinia Mobile App: Design System

## 1. Color Palette
The color system uses semantic naming to support seamless switching between Light and Dark modes.

| Role | Light Mode Hex | Dark Mode Hex | Description |
| :--- | :--- | :--- | :--- |
| **Primary** | `#2563EB` (Blue 600) | `#3B82F6` (Blue 500) | Main brand color, primary actions, active states. |
| **Secondary** | `#10B981` (Emerald 500) | `#34D399` (Emerald 400) | Accents, success indicators, progress bars. |
| **Background** | `#F8FAFC` (Slate 50) | `#0F172A` (Slate 900) | Base app background. |
| **Surface** | `#FFFFFF` (White) | `#1E293B` (Slate 800) | Cards, modals, bottom sheets. |
| **Text Primary** | `#0F172A` (Slate 900) | `#F8FAFC` (Slate 50) | Headings and primary body text. |
| **Text Secondary** | `#64748B` (Slate 500) | `#94A3B8` (Slate 400) | Subtitles, captions, disabled text. |
| **Error** | `#EF4444` (Red 500) | `#F87171` (Red 400) | Destructive actions, validation errors. |
| **Border** | `#E2E8F0` (Slate 200) | `#334155` (Slate 700) | Dividers, outlined buttons, input borders. |

## 2. Typography System
*   **Primary Font:** `Inter` (Google Fonts). Chosen for its excellent readability on mobile screens and modern, clean aesthetic.
*   **Flutter Implementation:** Utilize `GoogleFonts.interTextTheme()` applied to the app's root `ThemeData`.

## 3. Font Hierarchy
Implemented via Flutter's standard `TextTheme`.

| Role | Weight | Size | Letter Spacing | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Display Large (H1)** | Bold (700) | 32sp | -0.5px | Major screen titles, Hero metrics. |
| **Headline Medium (H2)**| SemiBold (600)| 24sp | 0px | Section headers, Modal titles. |
| **Title Medium (H3)** | Medium (500) | 16sp | 0.15px | Card titles, List item headers. |
| **Body Large** | Regular (400) | 16sp | 0.5px | Primary paragraph text. |
| **Body Medium** | Regular (400) | 14sp | 0.25px | Secondary paragraph text, descriptions. |
| **Label Large** | Medium (500) | 14sp | 0.1px | Buttons, Tabs, interactive elements. |
| **Label Small** | Medium (500) | 11sp | 0.5px | Overlines, Tags, tiny captions. |

## 4. Spacing System
Based on a strict **8pt grid system** for consistent rhythm.

| Name | Value | Usage |
| :--- | :--- | :--- |
| `xs` | 4.0 | Between tightly coupled elements (icon + text). |
| `sm` | 8.0 | Between list items or small form fields. |
| `md` | 16.0 | Standard padding (screen edges, card padding). |
| `lg` | 24.0 | Separation between distinct sections. |
| `xl` | 32.0 | Large gaps, bottom padding for scroll areas. |
| `xxl` | 48.0 | Spacing below major headers or isolated elements. |

## 5. Border Radius System
*   `small`: **4px** (Tags, Tooltips, Checkboxes).
*   `medium`: **8px** (Buttons, Input fields, small Images).
*   `large`: **16px** (Standard Cards, Dialogs, Bottom Sheets).
*   `circular`: **999px** (Avatars, FABs, pill-shaped buttons).

## 6. Elevation & Shadow Usage
Shadows should be subtle and primarily used to indicate z-axis hierarchy.
*   **Level 0 (Flat):** 0px (Standard content).
*   **Level 1 (Hover/Cards):** `BoxShadow(blurRadius: 4, spreadRadius: 0, color: Colors.black.withOpacity(0.05), offset: Offset(0, 2))`.
*   **Level 2 (Modals/Nav):** `BoxShadow(blurRadius: 12, spreadRadius: 0, color: Colors.black.withOpacity(0.08), offset: Offset(0, 4))`.
*   *Note:* In Dark Mode, elevation is typically expressed through surface lightening rather than shadows.

## 7. Button Styles
All buttons strictly adhere to a minimum touch target of `48x48px`.
*   **Filled Button:** Primary action. Uses `Primary` color background with `Surface` text. No shadow.
*   **Outlined Button:** Secondary action. Transparent background, `Border` color stroke, `Primary` text.
*   **Text Button:** Tertiary action. No background, no border, `Primary` or `Text Secondary` color.
*   **States:** All buttons include visual feedback for `pressed` (opacity 0.8), `hover/focus` (opacity 0.9), and `disabled` (opacity 0.38, greyed out).

## 8. Input Field Styles
*   **Style:** Filled/Outlined hybrid (Flutter's `OutlineInputBorder`).
*   **Default:** `Surface` fill, subtle `Border` color.
*   **Focused:** Border transitions to `Primary` color, 2px width.
*   **Error:** Border transitions to `Error` color. Error text appears below the field in `Label Small`.
*   **Content:** Floating label, clear contrast for inputted text.

## 9. Card Styles
*   **Base:** `Surface` color, `16px` border radius, Level 1 shadow (or 1px border in flat designs).
*   **Interactive Cards:** Elevate to Level 2 and change border color on tap/focus.
*   **Padding:** Standard `16px` internal padding.

## 10. Icon Usage Guidelines
*   **Library:** Unicons or standard Material Symbols (Rounded style).
*   **Weight:** Consistent stroke weight (e.g., 2px outline).
*   **Sizing:** 24x24px default. 16x16px for inline text. 32x32px for empty states.

## 11. Theme System (Flutter Specific)
*   Do not hardcode colors in widgets.
*   Use `Theme.of(context).colorScheme.primary`.
*   Extend the standard theme using Flutter's `ThemeExtension` for custom semantic colors (e.g., `CustomColors.success`).

## 12. Dark / Light Mode Rules
*   **Avoid pure black/white:** Use `Slate 900` for dark backgrounds and `Slate 50` for light backgrounds to reduce eye strain.
*   **Contrast:** Ensure all text passes WCAG AA guidelines (4.5:1 ratio) in both modes.
*   **Desaturation:** Primary colors may be slightly desaturated in dark mode to prevent visual vibration.

## 13. Component Sizing Rules
*   **Touch Targets:** Minimum interactive area is `48x48` pixels (Material Design standard).
*   **Width:** Forms and buttons should typically span `double.infinity` (constrained by screen padding) on mobile.

## 14. Responsive Layout Rules
*   **Mobile-First:** Design for typical phone widths (320px - 430px).
*   **Tablet/Web scaling:** 
    *   Constrain maximum width of main content to `600px`.
    *   Use `SafeArea` universally.
    *   Switch from `BottomNavigationBar` to `NavigationRail` on wide screens.

## 15. Empty States
*   **Structure:** Centered layout. Large Icon/Illustration (muted) -> Title -> Description -> Primary Call to Action.
*   **Tone:** Helpful and encouraging, guiding the user on what to do next.

## 16. Loading States
*   **Primary (Initial Load):** Skeleton/Shimmer loaders matching the shape of the incoming content (cards, text blocks) are preferred over full-screen spinners.
*   **Secondary (Action Load):** Small inline `CircularProgressIndicator` inside the tapped button (hiding the text).

## 17. Error States
*   **Inline Errors:** Red text below input fields.
*   **Transient Errors:** SnackBar at the bottom of the screen (e.g., "Network connection lost").
*   **Fatal Errors:** Full-screen error state with a clear description and a "Retry" button.

## 18. Accessibility Considerations
*   **Semantics:** Wrap custom interactive widgets in `Semantics` to support VoiceOver/TalkBack.
*   **Scaling:** Support Dynamic Type. UI must not break when system text size is increased to 200%. Avoid fixed heights on text containers.
*   **Contrast:** Rely on the defined Color Palette which enforces WCAG 2.1 AA standards.

## 19. Animation Guidelines
*   **Duration:** Keep micro-interactions (button taps, toggles) under `200ms`. Page transitions between `300ms - 400ms`.
*   **Easing:** Use standard easing curves (e.g., `Curves.easeInOutCubic` or `Curves.fastOutSlowIn`) for natural movement.
*   **Purpose:** Use animations to guide attention, provide feedback, or explain spatial relationships (e.g., Hero transitions for opening a course).

## 20. UI Consistency Rules
*   **Single Source of Truth:** All styling (colors, typography, spacing, radii) must be accessed via the `Theme` or static constants in `lib/core/theme/`. Magic numbers (e.g., `SizedBox(height: 15)`) are strictly prohibited in UI code. Use `SizedBox(height: AppSpacing.md)` instead.
