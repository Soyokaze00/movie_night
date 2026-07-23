# 🎬 MovieNight

A Flutter app for tracking movies and anime — think MyAnimeList, but covering both in one place. Browse trending titles, rate what you've watched, track episode progress, and organize everything into personal lists. No accounts, no server — everything lives locally on your device.

## Features

- **Browse & discover** — trending/popular movies on the home screen, genre-based discovery for movies and TV/anime
- **Unified search** — one search bar covers both movies and anime (TMDB's multi-search)
- **Personal library** — six status categories: Favorites, Watching, On Hold, Completed, Dropped, Plan to Watch
- **Ratings** — 10-star rating per title
- **Episode tracking** — for TV/anime, track episodes watched via +/- buttons, direct number entry, or a draggable slider; status auto-updates as you go (e.g. auto-marks Completed on the last episode)
- **Real per-title recommendations** — "You May Also Like" pulls from TMDB's actual recommendations endpoint for that specific title, not a generic popular list
- **Local profile** — name + avatar, no login required
- **Stats** — titles tracked, episodes watched, average rating, rewatch count, recently updated, top rated
- **Content filtering** — layered filtering (TMDB's adult flag, keyword exclusion, title/overview text matching, minimum vote count, BBFC certification limits on movie discovery) to reduce exposure to explicit/exploitative content. See [Limitations](#limitations-known-gaps) — this is not airtight, particularly in search.

## Tech Stack

| | |
|---|---|
| Framework | [Flutter](https://flutter.dev) / Dart |
| State management | [Provider](https://pub.dev/packages/provider) |
| Movie/TV data | [TMDB API](https://www.themoviedb.org/documentation/api) |
| Local storage | SQLite via `sqflite` (mobile/desktop) + `sqflite_common_ffi_web` (web) |
| Images | `cached_network_image` |
| Env config | `flutter_dotenv` |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your PATH
- A free [TMDB API key](https://www.themoviedb.org/settings/api)

### Setup

```bash
git clone https://github.com/Soyokaze00/movie_night.git
cd movie_night
flutter pub get
```

Create a `.env` file in the project root:

```
TMDB_API_KEY=your_api_key_here
```

### Running

```bash
flutter run -d chrome        # web
flutter run                  # connected device/emulator
```

**Running on web for the first time?** SQLite needs a one-time setup step to fetch the browser worker files it depends on:

```bash
dart run sqflite_common_ffi_web:setup
```

This creates `web/sqflite_sw.js` and `web/sqlite3.wasm` — without this, the app will hang on a loading screen in Chrome.

## Project Structure

```
lib/
├── data/
│   ├── models/         # Movie model
│   └── services/       # TMDB API client, local SQLite service
├── providers/           # MovieProvider — app-wide state management
├── screens/              # Home, Search, Detail, Lists, Discover, Profile, etc.
└── widgets/              # Reusable UI (movie cards, list tiles, nav drawer)
```

## Local Database

All user data (favorites, ratings, episode progress, profile) lives in an on-device SQLite database — nothing is sent to a server.

| Table | Purpose |
|---|---|
| `library_entries` | Status, favorite flag, score, episode progress, dates, rewatch count per title |
| `custom_lists` / `custom_list_items` | User-created lists (schema ready; UI not yet built) |
| `user_profile` | Local name + avatar |

## Limitations / Known Gaps

- **Custom lists** have a working database/provider layer but no screen to create or view them yet.
- **Content filtering is imperfect**, especially in search — TMDB's search endpoint doesn't support certification or keyword-exclusion filters, so filtering there relies only on text matching and a minimum vote-count heuristic, which can both over- and under-filter.
- **No accounts or cloud sync** — data is local to the device/browser it was entered on.
- Profile's "recently updated" / "top rated" lists only include titles the app has actually fetched full details for (this session, or during a bounded startup hydration step) — very large libraries may not show everything immediately.

## License

No license specified.
