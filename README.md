# Aura

[Repository](https://github.com/ayungavis/aura-app)

A weather activity recommendation app built with SwiftUI. Shows current weather, hourly forecasts, and suggests activities and food based on real-time conditions — powered by on-device Apple Intelligence when available.

## Requirements

- Xcode 17+
- iOS 26.0+
- Apple Intelligence–capable device (iPhone 15 Pro+ / M1+ Mac / iPad with A17 Pro+) for AI recommendations (rule-based fallback on other devices)

## Getting Started

### 1. Clone

```bash
git clone https://github.com/ayungavis/aura-app.git
cd aura-app
```

### 2. Configure API Key

The app requires a TripAdvisor API key for place search and details.

```bash
cp AuraApp/Example.xcconfig AuraApp/Config.xcconfig
```

Edit `AuraApp/Config.xcconfig` and replace the placeholder:

```
TRIPADVISOR_API_KEY = your_actual_key_here
```

Get a key at [tripadvisor.com/developers](https://tripadvisor.com/developers).

`Config.xcconfig` is gitignored — your key stays local.

### 3. Open & Run

```bash
open AuraApp.xcodeproj
```

Select the **AuraApp** scheme and run on a simulator or device. The app requests location access on first launch.

### 4. Build from Terminal

```bash
xcodebuild build -project AuraApp.xcodeproj -scheme AuraApp \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Architecture

The app follows **MVVM (Model-View-ViewModel)** with protocol-oriented dependency injection.

### Navigation Flow

```
SplashScreen (3s) → CurrentWeatherView → ListView → DetailView
```

`AppRouter` (`@Observable`) drives navigation via `NavigationStack` + `NavigationPath`. Routes are defined in `AppDestination`.

### Project Structure

```
AuraApp/
├── App/                    # Entry point, router, root view, config
├── Core/
│   ├── Models/             # Shared data models
│   ├── Services/           # Network services (protocols + implementations)
│   ├── Extensions/         # Swift extensions
│   └── Storages/           # Caching layer
├── Features/
│   ├── CurrentWeather/     # Main weather screen
│   │   ├── Components/     # Reusable UI components
│   │   ├── Models/         # Feature-specific models
│   │   ├── CurrentWeatherView.swift
│   │   ├── CurrentWeatherViewModel.swift
│   │   └── CurrentWeatherMockData.swift
│   ├── ListView/           # Places listing
│   ├── DetailView/         # Place details
│   └── SplashScreen/       # Animated splash
└── Shared/
    ├── Components/         # Cross-feature UI components
    └── Utilities/          # Logger, helpers
```

### MVVM Pattern

Each feature follows the same structure:

```
View (SwiftUI)  →  ViewModel (@MainActor, ObservableObject)  →  Service (Protocol)
```

**View** — renders state, handles user interaction only. Owns the ViewModel via `@StateObject`.

**ViewModel** — holds `@Published` state, calls async service methods, never imports SwiftUI views. All dependencies injected via protocols with default implementations.

**Service** — handles networking/caching, defined by a protocol for testability.

Example dependency chain for the weather screen:

```
CurrentWeatherView
  @StateObject CurrentWeatherViewModel
    ├── WeatherServiceProtocol ← OpenMeteoWeatherService
    ├── LocationManagerProtocol ← LocationManager
    └── RecommendationServiceProtocol ← AIRecommendationService / FallbackRecommendationService
```

### Key Patterns

| Pattern                       | Where                            | Why                                    |
| ----------------------------- | -------------------------------- | -------------------------------------- |
| Protocol-oriented DI          | All ViewModels                   | Testable, swappable implementations    |
| `@MainActor`                  | ViewModels & Services            | Thread safety for UI updates           |
| `defer { isLoading = false }` | All async fetch methods          | Loading state always resets            |
| `async let` parallel fetch    | DetailViewModel, recommendations | Independent API calls run concurrently |
| Three-state rendering         | All feature Views                | `loading → error → content` with retry |
| Progressive loading           | List/Detail Views                | Show stale data during refresh         |
| Disk cache with TTL           | LocalCache                       | 15-min weather cache, 24h default      |

### Recommendation System

Activity and food recommendations adapt to current weather:

```
RecommendationServiceFactory.create()
  ├── AIRecommendationService    (Apple Intelligence devices)
  │   └── Foundation Models @Generable → structured output
  └── FallbackRecommendationService   (all other devices)
      └── WeatherCondition enum → curated maps
```

Both return `[Activity]` and `[Food]` models with SF Symbol icon names. The factory checks `SystemLanguageModel.default.availability` at runtime.

### Data Sources

| Data                           | Source                                | Caching           |
| ------------------------------ | ------------------------------------- | ----------------- |
| Weather (current + hourly)     | Open Meteo API (via OpenMeteoSdk)     | 15-min disk cache |
| Place search                   | TripAdvisor Content API               | 24h disk cache    |
| Place details, photos, reviews | TripAdvisor Content API               | 24h disk cache    |
| Location name                  | CLGeocoder (reverse geocode)          | None              |
| Activity/food recommendations  | Apple Foundation Models or rule-based | None (stateless)  |

### Logging

All network, cache, location, weather, and recommendation events are logged via `AppLogger` using `os.Logger`. Check the Xcode console or Console.app with subsystem filter `com.ayungavis.AuraApp`.

## Dependencies

Managed through Xcode SPM (no `Package.swift`):

- **[OpenMeteoSdk](https://github.com/open-meteo/sdk)** — weather data via FlatBuffers
- **[FlatBuffers](https://github.com/google/flatbuffers)** — serialization (transitive)

## Team

Built by a 2-person team learning Swift and iOS development.

- Wahyu Kurniawan ([@ayungavis](https://github.com/ayungavis))
- M Nurul Akbar ([@babono](https://github.com/babono))
