# LeaveList

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios-lightgrey)
![State Management](https://img.shields.io/badge/state-riverpod-6236FF)
![License](https://img.shields.io/badge/license-private-lightgrey)
![Status](https://img.shields.io/badge/status-active-success)

**Never walk out the door without everything you need.**

LeaveList is a location-aware checklist app for people who are, admittedly, a little forgetful. Pin the places you regularly leave from — home, office, the gym, a friend's place — attach a packing checklist to each one, and get a clear, visual go/no-go signal before you head out the door.

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [Product Overview](#product-overview)
- [Core Features](#core-features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [State Management](#state-management)
- [Local Persistence](#local-persistence)
- [Getting Started](#getting-started)
- [Code Generation](#code-generation)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

---

## Problem Statement

It's an easy, universal mistake: you leave home or the office and realize — too late — that you forgot your ID card, charger, umbrella, or keys. LeaveList exists to close that gap between *"I'm about to leave"* and *"do I actually have everything?"* by turning a mental checklist into a visual, location-anchored habit.

## Product Overview

1. **Pin a place.** Drop a pin on the map for any address you leave from and tag it with a category (Home, Work, Others).
2. **Build a checklist.** Attach the items you must not forget for that specific place — laptop, ID card, umbrella, bottle, keys, and more.
3. **Check off before you leave.** Tap the pin, tick off each item, and once everything is checked, LeaveList tells you:

   > **"You can go now, without worry."**

No item left unchecked, no anxious pat-down of your pockets at the door.

## Core Features

| Feature | Description |
|---|---|
| 📍 **Interactive map** | Google Maps-based view for dropping and managing address pins. |
| 🏷️ **Categorized addresses** | Classify each address as Home, Work, or Other for quick recognition. |
| ✅ **Per-address checklists** | Every pin owns its own independent checklist of items to carry. |
| 🎉 **Completion feedback** | Animated confirmation once every item on a checklist is checked. |
| 📇 **Address list view** | A dedicated tab listing every saved address with quick access to its checklist. |
| 🧭 **Guided empty states** | First-time users are walked through adding their first address, not just shown a blank screen. |
| 💾 **Offline-first storage** | All addresses and checklists are persisted locally — the app works fully without network access. |

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`) |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) (`Notifier` / `NotifierProvider`) |
| Routing | [go_router](https://pub.dev/packages/go_router) |
| Local persistence | [Hive](https://pub.dev/packages/hive) / [hive_flutter](https://pub.dev/packages/hive_flutter) |
| Maps | [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) |
| Iconography | [hugeicons_pro](https://pub.dev/packages/hugeicons_pro) |
| Code generation | [build_runner](https://pub.dev/packages/build_runner) + [hive_generator](https://pub.dev/packages/hive_generator) |

## Architecture

LeaveList follows a **feature-first**, layered architecture that keeps UI, state, and data access cleanly separated:

```
Presentation (UI)  →  Provider / Notifier (State)  →  Service (Domain)  →  Local Storage (Data)
```

- **UI layer** — Stateless/Consumer widgets under `ui/`, responsible only for rendering and dispatching user intent.
- **State layer** — Riverpod `Notifier`s under `provider/` own immutable state objects and expose intent methods (`addPin`, `removePin`, `setChecklistItems`, …).
- **Service layer** — `HomeService` / `HomeServiceImpl` under `data/` abstract away persistence so notifiers never talk to Hive directly.
- **Data layer** — `LocalStorageService` wraps Hive box lifecycle (initialization, adapter registration, typed box access) behind a single, boring API.

This separation means the persistence engine (currently Hive) or the state management library could be swapped without touching the UI.

## Project Structure

```
lib/
├── core/                     # App-wide, feature-agnostic building blocks
│   ├── constants/            # Design tokens: sizes, icons, assets, storage box names
│   ├── extensions/           # Convenience extensions (e.g. Hive box helpers)
│   ├── routes/                # go_router route definitions
│   ├── services/             # LocalStorageService — Hive setup & box access
│   ├── theme/                 # Colors, typography, ThemeData
│   └── utils/                 # Misc utilities (e.g. widget-to-bitmap for map markers)
├── features/
│   ├── splash/                # App splash screen
│   └── home/
│       ├── data/              # HomeService contract + Hive-backed implementation
│       ├── models/            # AddressModel, ChecklistItem, MapPin, mappers
│       ├── provider/           # HomeNotifier, TodoNotifier, BootstrapNotifier + state
│       └── ui/                 # HomeScreen, HomeMapView, AddressScreen
├── shared/
│   ├── buttons/                # Reusable button components
│   ├── widgets/                 # Bottom sheets, app bar, bottom nav, map pin widget
│   └── wrapper/                  # Screen scaffolding wrapper
└── main.dart                     # App bootstrap — Hive init → runApp
```

## State Management

State is managed with **Riverpod 3** using the `Notifier` API:

- `homeProvider` (`HomeNotifier` / `HomeState`) — owns the list of map pins and the currently selected pin.
- `todoProvider` (`TodoNotifier` / `TodoState`) — owns each address's checklist items.
- `bootstrapProvider` (`BootstrapNotifier`) — loads persisted addresses on app start and merges them into initial state.

Notifiers optimistically update in-memory state first, then persist asynchronously via `HomeService` — keeping the UI responsive even if disk I/O is slow, with persistence failures logged rather than surfaced as blocking errors.

## Local Persistence

All data lives on-device via **Hive**, a fast, key-value NoSQL store:

| Box | Contents |
|---|---|
| `addresses` | `AddressModel` — id, label, type (home/office/other), latitude, longitude |
| `checklists` | `CheckList` — per-address list of `ChecklistItem` (id, label, item type) |

Both boxes are opened **once**, eagerly, during `LocalStorageService.init()` before `runApp` is called — avoiding repeated/concurrent `openBox` calls and the box-identity errors that come with them. Every screen then reads from the already-open box synchronously.

> No account, no backend, no cloud sync — your lists stay on your device.

## Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `^3.12.2`
- A configured Google Maps API key for Android/iOS (required by `google_maps_flutter`)

### Setup

```bash
# 1. Clone the repository
git clone <repo-url>
cd leavelist

# 2. Install dependencies
flutter pub get

# 3. Generate Hive adapters (required before first run)
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

## Code Generation

`AddressModel` and `ChecklistItem` are Hive-annotated (`@HiveType` / `@HiveField`) and rely on generated `TypeAdapter`s. Whenever a model changes, regenerate adapters with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Roadmap

- [ ] Persist checklist check/uncheck state per address (currently ephemeral per session by design)
- [ ] Geofencing-based reminders — nudge the user automatically on leaving a pinned location
- [ ] Reordering and editing existing checklist items
- [ ] Settings tab (currently a placeholder)
- [ ] Light/dark theme toggle
- [ ] Cloud backup / multi-device sync (optional, privacy-preserving)

## Contributing

This is currently a personal/solo project. Issues and pull requests are welcome if you'd like to suggest improvements or report bugs — please keep changes scoped and include a clear description of the problem being solved.

---

<p align="center">Built with Flutter — so you never leave without your keys again.</p>
