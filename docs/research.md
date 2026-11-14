# Research: standards this codebase follows

The project is held to the standard of a professional, large-team codebase.
This file records what the official guidance says, how the project applies
it, and — where it deliberately differs — why. Update it when a decision
changes; never silently drift from a row here.

Researched 2026-11-14 – 2026-11-15. Sources were read directly; short quotes
are the sources' own words.

## Sources

| Source | URL |
|---|---|
| Flutter — Guide to app architecture | https://docs.flutter.dev/app-architecture/guide |
| Flutter — Architecture recommendations | https://docs.flutter.dev/app-architecture/recommendations |
| Flutter — Architecture case study (Compass app) | https://docs.flutter.dev/app-architecture/case-study |
| Flutter — Offline-first design pattern | https://docs.flutter.dev/app-architecture/design-patterns/offline-first |
| Flutter — Testing overview | https://docs.flutter.dev/testing/overview |
| Flutter — Adaptive and responsive design | https://docs.flutter.dev/ui/adaptive-responsive (and its general, large-screens, best-practices and SafeArea/MediaQuery pages) |
| Material 3 — Window size classes, touch targets | https://m3.material.io/foundations/layout/applying-layout/window-size-classes · https://m3.material.io/foundations/designing/structure |
| Effective Dart (style, documentation, usage, design) | https://dart.dev/effective-dart |
| Very Good Ventures — layered / feature-first architecture | https://verygood.ventures/blog/very-good-flutter-architecture |
| Code With Andrea — Flutter project structure | https://codewithandrea.com/articles/flutter-project-structure |
| Dart pub workspaces (monorepos) | https://dart.dev/tools/pub/workspaces |
| Owner's reference projects | `recipely` (architecture.md, skills), `lgs_reward_hunt` (CLAUDE.md, tool/check_structure.dart) |

## Flutter architecture recommendations — compliance

Strength as the page gives it: **S** strongly recommend · **R** recommend ·
**C** conditional.

| Recommendation | | How this project applies it |
|---|---|---|
| Clearly defined data and UI layers | S | Seven layer folders; the import table is enforced by `tool/check_structure.dart`. |
| Repository pattern in the data layer | S | One repository per aggregate in `infrastructure/<feature>/repository/`, behind a domain port. |
| Views and view models (MVVM) | S | A page is the view; its Cubit is the view model — one per page, state `sealed`. |
| No logic in widgets | S | Widgets render and forward events; rules live on domain types (`GeoRules`, `ShareValueObject`, `MapSnapshotReadModel`), orchestration in Cubits and use cases. |
| Domain layer (use-cases) | C | Used, because logic does merge repositories: a lookup reads the store snapshot, the registry and the parcel repository; the map joins four live streams. |
| Unidirectional data flow | S | Store → repository stream → use case → Cubit state → widget; widget events → Cubit method → use case → repository. Nothing writes upward. |
| Commands for user events | R | Cubit methods are the commands; busy flags (`querying`) stop a double tap from spending two registry lookups. |
| Immutable data models | S | Entities, value objects and read models are immutable; every edit (e.g. a drawing draft) returns a new instance. |
| freezed / built_value for models | R | **Deviation:** hand-written immutable types on `Equatable` bases. The domain types carry behaviour (geometry, fractions, undo history) rather than being plain records, and the bases give equality without code generation slowing the build. Revisit if plain data models multiply. |
| Separate API models and domain models | C | Always: TKGM DTOs and Firestore document mappers stop at infrastructure; only entities go up. |
| Dependency injection | S | Constructor injection everywhere; `get_it` registered only in the composition root (`main.dart`). **Deviation:** the page suggests `provider`; `get_it` keeps the graph in one explicit place and pages resolve only their Cubit. |
| go_router | R | Used; the redirect follows the session. |
| Standardised naming by role | R | `*Entity`, `*ValueObject`, `*ReadModel`, `*Interface`, `*Repository`, `*Service`, `*Mapper`, `*DTO`, `*UseCase`, `*Cubit`/`*State`, `*Page`/`*Body`. |
| Abstract repository classes | S | Every repository is an `abstract interface class *Interface` in the domain. |
| Test components separately and together | S | Unit tests for rules, value objects, mappers and use cases (with fakes). Widget tests for pages are on the roadmap. |
| Fakes for testing | S | Use-case tests run against `mocktail` fakes of the ports; no Firebase, no network. |

The guide's further rules — repositories as the single source of truth,
services stateless and one per source, repositories unaware of each other —
are architecture.md's "Two data sources" section. One nuance: deleting a
person updates drawings in the same batch. That is done by a shared
`HolderCascadeService` over the store, not by one repository calling
another, so the repositories stay unaware of each other.

## Effective Dart — compliance

| Guideline | How |
|---|---|
| Names: `UpperCamelCase` types, `lowercase_with_underscores` files, `lowerCamelCase` members and constants | Followed; enforced by `flutter_lints`. |
| Format with `dart format` | CI fails on unformatted code. |
| `///` doc comments; first sentence a summary; `[name]` for in-scope identifiers | Rule 14 in CLAUDE.md; `comment_references` lint. |
| Curly braces for all flow control | Followed. |
| Avoid `dynamic`; annotate return and parameter types | `strict-casts`, `strict-inference`, `strict-raw-types`, `always_declare_return_types`, `type_annotate_public_apis`. |
| Avoid positional boolean parameters | Lint on. |
| Prefer `final` fields and locals | Lints on. |
| Override `hashCode` with `==` | Done once, in the bases. |
| PREFER relative import paths | **Deviation:** package imports everywhere (`always_use_package_imports`). A `../../..` hides which layer it crossed; the layer is the thing reviewed. |
| AVOID catches without `on` clauses | **Deviation at boundaries only:** a repository or service is where any throw becomes a `BaseException`; narrowing its catch would let one escape into the app. Domain and application code never catch. |
| AVOID classes with only static members | **Deviation for named values:** `CoreConstants`, `GeoRules`, `MapRules`, `ParcelRules` are namespaces of constants and pure functions, matching the owner's existing `CoreConstants`/`BaseDimens` style. |

## Responsive and adaptive layout

Flutter defines responsive as fitting the UI into the space, and adaptive as
being usable in it. What the guidance asks, and how the app does it:

| Guidance | How |
|---|---|
| Branch layout on the window size, never on the device type or orientation | `WindowSizeClassEnum` (Material 3: compact < 600, medium < 840, expanded < 1200, large < 1600, extra-large) is the only thing layout branches on. |
| Read the window with `MediaQuery.sizeOf`, not `MediaQuery.of` | Done — it rebuilds only on a size change. `LayoutBuilder` where a widget sizes itself to its parent. |
| Never lock orientation | No orientation lock on any platform. |
| Neither text nor boxes take the full width on a large screen | Content pages sit in `ParcelInfoReadableWidth` (840 px); panels and dialogs are capped at 440 px; sign-in is capped too. |
| Navigation and panels change with the space | The details panel rises from the bottom up to medium and sits at the side from expanded; in a compact window the top bar folds people, history and sign out into one menu. |
| Wrap the body in `SafeArea` | Bars and panels over the map sit in `SafeArea`; the map itself runs edge to edge under them. |
| Touch first; mouse and keyboard as accelerators | Every action is a labelled button; while drawing, Ctrl/Cmd+Z, Shift+Ctrl/Cmd+Z, Delete/Backspace and Escape are shortcuts for the same buttons. Enter signs in. |
| Touch targets at least 48 dp (Material) | Buttons and fields are 48 px high; drawing corners are drawn at 30 px but hit at 48 px; edge chips are 36 px high. |
| Keep state across resizes | All state is in Cubits, so resizing or rotating rebuilds the layout without losing a drawing in progress. |

Not yet verified on real devices: the phone layouts on Android/iOS hardware
and the desktop builds (roadmap).

## Testing (Flutter testing overview)

Many unit and widget tests, tracked by coverage, plus enough integration
tests for the important journeys. Applied: domain and application are pure
Dart and unit-tested; widget tests per page and an integration test of
"sign in → look up → draw → save" are on the roadmap (`docs/roadmap.md`).

## Structure: packages or folders

Owner's original design: seven local packages. Findings:

- Flutter's case study keeps **one package** with layer folders; so do Code
  With Andrea and `lgs_reward_hunt`.
- VGV recommends **per-layer packages** for large teams sharing layers across
  apps; Dart pub workspaces (Dart 3.6+) make that cheaper.
- Packages nested inside the app's `lib/` broke hot reload (each file had two
  package identities).

Decision: one package, the same seven layers as folders, the import rules
enforced by `tool/check_structure.dart`. Rationale in architecture.md.

## Data sources

Flutter's data layer = services (one per source, stateless) + repositories
(single source of truth). Offline-first: repositories merge local and remote
behind one access point. Applied: `FirestoreStoreService` (internal, offline
cache on) and `TkgmParcelService` (external, rationed); repositories answer
from the store first. Details: architecture.md and docs/tkgm-api.md.

## Security (Firestore)

Rules are the real access control; the client only mirrors them. Applied:
an explicit member allowlist, server-time stamps checked in rules,
append-only log, read-only registry records, admin-only deletes, deny by
default. Details: docs/data-model.md.
