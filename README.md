# Product Catalog

A production-quality Flutter product catalog application demonstrating clean architecture, BLoC state management, offline support, and responsive adaptive layouts.

---

## 1. Setup and Run Instructions

**Requirements:**
- Flutter 3.32.4 (or later 3.x)
- Dart SDK 3.8.1+
- Xcode (for iOS) or Android Studio (for Android)

**Steps:**

```bash
# 1. Clone or navigate to the project
cd /path/to/product_catalog

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or simulator
flutter run

# 4. Run tests
flutter test

# 5. Analyze code
flutter analyze
```

**Deep link example (iOS Simulator):**
```bash
xcrun simctl openurl booted "productcatalog://products/1"
```

**Build release:**
```bash
flutter build apk --release          # Android
flutter build ios --release          # iOS
```

---

## 2. Architecture Overview

The app follows **Clean Architecture** with three clearly separated layers:

### Layer Structure

```
lib/
  core/              # Cross-cutting: DI, networking, utilities, constants
  data/              # Data layer: models, datasources (remote/local), repository impl
  domain/            # Domain layer: entities, repository interfaces, use cases
  features/          # Presentation layer: cubits, widgets, screens per feature
  design_system/     # Shared UI: theme, reusable components
  app/               # App wiring: router, MaterialApp
```

### State Management (Bloc/Cubit)

- `ProductListCubit` manages the product list screen state with statuses: initial, loading, loadingMore, loaded, error, empty. Handles pagination (append-on-scroll), search (debounced 500ms), category filtering.
- `ProductDetailCubit` fetches a single product by ID with loading/loaded/error states.
- `ThemeCubit` manages light/dark/system theme mode, provided at the root.

### Navigation (GoRouter 15.x)

```
/                       -> ProductListScreen
/products/:id           -> ProductDetailScreen (phone only; tablet renders inline)
/showcase               -> ShowcaseScreen
```

Deep links are handled by GoRouter's path parameter extraction. On tablets (width >= 768px), `ProductDetailScreen` is rendered in the right pane of a master-detail layout without pushing a route.

### Dependency Injection (GetIt)

All dependencies are registered in `core/di/injection_container.dart` using `GetIt`. Cubits are registered as factories (new instance per creation). Repository, use cases, and data sources are singletons.

### Offline Support (Hive)

Two Hive `Box<String>` instances (`product_cache`, `cache_meta`) store JSON-serialised responses with timestamps. Cache keys follow predictable patterns (`products_page_{skip}_{limit}`, `product_{id}`, `search_{query}_{category}`). Entries expire after 1 hour. When data is served from cache, a yellow banner informs the user.

---

## 3. Design System Rationale

### Material 3

The app uses Material 3 (`useMaterial3: true`) with a blue/indigo seed color (`#2563EB`) generating a full `ColorScheme`. This provides adaptive colors for both light and dark themes without manual override of every surface color.

### Color Tokens (`app_colors.dart`)

All colors are declared as constants on `AppColors`. This creates a single source of truth and prevents magic color literals scattered throughout the codebase. Colors are semantically named (primary, secondary, success, warning, error, surface variants, text variants) rather than by shade value.

### Typography (`app_text_styles.dart`)

Text styles follow the Material 3 type scale (Display, Headline, Title, Body, Label). They are defined once and referenced by name, making global typography changes trivial.

### Spacing (`app_spacing.dart`)

Spacing uses an 8-point grid system with named constants (xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, xxxl=32) to ensure visual consistency.

### Component API Choices

- `ProductCard`: accepts a `Product` entity and `VoidCallback onTap`. Hero animation is embedded directly in the card, wrapping `CachedNetworkImage` to enable seamless list-to-detail transitions.
- `CategoryChip`: stateless, controlled component with `isSelected` prop. Uses `AnimatedContainer` for smooth selection transitions.
- `AppButton`: variants (primary/secondary/text) are expressed via an enum and named constructors, keeping call sites readable.
- `SkeletonLoader`/`ProductCardSkeleton`: uses the `shimmer` package to produce a shimmer effect matching the `ProductCard` dimensions exactly.

### Theming

`AppTheme` provides static `lightTheme` and `darkTheme` `ThemeData` instances. The root `MaterialApp.router` receives both; `ThemeCubit` controls the active `ThemeMode`. `AnimatedTheme` is used inside the `App` widget so theme transitions are animated automatically.

---

## 4. Limitations and Known Shortcuts

1. **No Hive type adapters / code generation**: Products are cached as JSON strings in a `Box<String>` rather than using generated `TypeAdapter` classes. This is simpler and avoids build_runner runs but is slower for large datasets.

2. **No persistent theme preference**: The selected theme mode is held in-memory by `ThemeCubit` and resets to system default on restart. A real app would persist it via `SharedPreferences` or Hive.

3. **Scroll position not persisted across navigation**: `PageStorageKey` is used to preserve scroll within a single session, but navigating away and back on phone (full push) resets scroll. A Cubit-held `ScrollController` or Router shell route would fix this.

4. **No authentication or cart**: The app is read-only catalog browsing without user accounts, shopping cart, or checkout flow.

5. **No pull-to-refresh on detail screen**: Refresh is only available on the list screen via `RefreshIndicator`.

6. **Image caching via `CachedNetworkImage`**: Disk cache management (max size, eviction) uses package defaults, not custom configuration.

7. **Error boundary**: Individual widget errors propagate to screen-level error states. A production app would benefit from a global `FlutterError` handler and crash reporting (e.g. Firebase Crashlytics).

8. **No localization (l10n)**: Strings are hard-coded as English constants in `app_constants.dart`. An `AppLocalizations` setup would be the next step for internationalisation.

---

## 5. AI Tools Usage

This application was built with the assistance of **Claude Sonnet 4.6** (Claude Code, Anthropic). The AI was used to:

- Generate the complete project scaffolding, directory structure, and all source files from an architectural specification.
- Implement all layers (data, domain, presentation) simultaneously, maintaining consistent naming conventions and import paths across the codebase.
- Write unit tests (Bloc tests with `bloc_test`/`mocktail`, model parsing tests) and widget tests for `ProductCard` and `CategoryChip`.
- Identify and fix compilation errors reported by `flutter analyze` in a single feedback loop (CardTheme -> CardThemeData, unused imports, unnecessary casts, type mismatches).
- Fix widget test layout overflow issues by adjusting test container dimensions.

The human provided the full architectural specification and reviewed/approved each batch of generated files. The architecture, dependency choices, component APIs, and feature scope were specified by the human; Claude translated them into working Dart code.
