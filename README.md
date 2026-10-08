<p align="center">
  <img width="220" alt="Trending" src="https://github.com/user-attachments/assets/acd5f306-41c1-49e7-b22f-b1c3822eaac7" />
  <img width="220" alt="Favorites" src="https://github.com/user-attachments/assets/39a7eea0-106f-4ae6-907b-954550b45273" />
  <img width="220" alt="Details" src="https://github.com/user-attachments/assets/f0813100-9690-494a-bfe9-afbd84b81841" />
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
