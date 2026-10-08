
<p align="center">
  <img src="https://github.com/user-attachments/assets/c1a38a9d-b51a-45e8-9e79-ed6a7c87ff7b" width="220" alt="Trending" />
  <img src="https://github.com/user-attachments/assets/ceed66b2-6157-4a64-adc8-f607423257c5" width="220" alt="Details" />
  <img src="https://github.com/user-attachments/assets/09af7efe-30a8-4feb-b4de-f3d674d5c69f" width="220" alt="Search" />
</p>

# CineScope

iOS app for browsing movies and TV shows via [TMDB](https://developers.themoviedb.org). Networking, caching, and image loading live in the `CineScopeCore` Swift package.

## Features

- Trending feed with adaptive grid and infinite scroll
- Search (movies / series) with a short debounce
- Details: ratings, cast, crew, genres, and related metadata
- Local favorites
- Offline fallback from a disk cache
- Size-aware image loading with memory and disk cache
- Dev and Prod schemes

## Requirements

- Xcode 16+
- iOS 17+
- Optional: [SwiftLint](https://github.com/realm/SwiftLint)
- Optional: TMDB v4 read access token

## Setup

1. Open `CineScope.xcodeproj`
2. Select **CineScope Dev**
3. Run on a simulator or device

Without a token, Dev uses bundled fixtures.

### API token

```bash
./Scripts/setup-secrets.sh
```

Then set `TMDB_ACCESS_TOKEN` in `Config/Secrets.xcconfig`. That file is gitignored.

You can also set `TMDB_ACCESS_TOKEN` in the scheme environment variables for Debug.

## Schemes

| Scheme | Notes |
| --- | --- |
| CineScope Dev | Fixtures unless a token is present |
| CineScope Prod | Live API (token required) |

## Package

```bash
cd Packages/CineScopeCore
swift test
```

### XCFramework

```bash
./Scripts/build-xcframework.sh
```

Output: `Artifacts/CineScopeCore.xcframework`.

## Architecture

```
CineScope (SwiftUI)
  └─ ViewModels
       └─ CineScopeCore
            ├─ TMDBClient (Live / Fixture)
            ├─ MediaRepository
            ├─ FavoritesStore
            └─ ImagePipeline
```
