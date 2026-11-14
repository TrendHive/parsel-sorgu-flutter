# Parcel Atlas

A family's shared map of land parcels. Members sign in with fixed accounts,
look parcels up in the official Turkish land registry (TKGM), draw the real
boundaries where the registry's are wrong, and record who owns which share —
people and groups alike. Everything is stored once and seen live on every
device. The app speaks Turkish; the code is English.

**Live:** https://parcel-info.web.app

## What it does

- **Two layers on one map** over aerial imagery: the registry's parcels
  (cyan, read-only) and the family's real boundaries (orange). Either can be
  switched off to compare them.
- **Registry lookups that respect the daily limit.** A tap inside a stored
  parcel is answered from the family's store; the registry is asked only on
  an explicit button, and "Refresh" refetches one parcel by its number.
- **Drawing made easy.** Start from a copy of the registry outline and move
  only the wrong corners: drag numbered corners, tap "+" on an edge to add
  one, use the crosshair for precise placement, undo/redo. Corners snap to
  existing corners; every side's length, the area and the difference from the
  deed area are shown live and saved with the drawing.
- **Owners with shares.** People and groups (four siblings who inherit alike)
  hold deed-style shares (1/4) of a real boundary; a group's share is split
  among its members.
- **Holdings.** For every person and group: each parcel, where it is, its
  area, the share and the owned area, with totals.
- **History.** Every change is signed with who and when, and listed.

## Environment

One environment only: production (Firebase project `parcel-info`). The `dev`
branch is for integration and deploys nowhere; merging to `main` releases.

## Platforms

Web (primary), Android, iOS, macOS and Windows. Linux is not supported:
Firebase has no Linux SDK.

## Stack — free resources only

| Need | Service |
|---|---|
| Hosting | Firebase Hosting (Spark) |
| Data | Cloud Firestore (Spark, `eur3`), offline cache on |
| Sign-in | Firebase Auth, e-mail/password, fixed accounts |
| Imagery | Esri World Imagery, OpenStreetMap |
| Parcel data | TKGM parcel query service (public) — see [docs/tkgm-api.md](docs/tkgm-api.md) |

## Getting started

Requirements: Flutter 3.50 (Dart 3.14), the Firebase CLI, access to the
Firebase project `parcel-info`.

```bash
flutter pub get
git config core.hooksPath .githooks   # once per clone: analyze + structure before each commit
flutter run -d chrome                 # hot reload works
```

## Accounts

There is no sign-up in the app. The main (admin) account adds members from a
terminal; the password is typed there, hidden, and never stored anywhere else:

```bash
dart run tool/add_member.dart <username> "<Display name>" --admin   # the main account
dart run tool/add_member.dart <username> "<Display name>"           # a family member
```

The tool creates the sign-in account, writes its profile, adds its id to the
member list in `firestore.rules` and deploys the rules. Sign-in accounts are
not parcel owners: owners are created in the app under "Kişiler".

## The gate

Nothing is merged while any step is red; CI runs the same steps on every push
and pull request.

```bash
flutter analyze                     # zero issues, infos included
dart run tool/check_structure.dart  # layer imports, folders, English-only code
flutter test
```

## Deploying

```bash
flutter build web --release
firebase deploy                     # hosting + Firestore rules/indexes + auth providers
```

## Documentation

| File | For |
|---|---|
| [CLAUDE.md](CLAUDE.md) | The rules of the codebase |
| [architecture.md](architecture.md) | Why the code is shaped the way it is |
| [docs/requirements.md](docs/requirements.md) | Everything the owner asked for, and the decision for each |
| [docs/data-model.md](docs/data-model.md) | The Firestore collections and security rules |
| [docs/tkgm-api.md](docs/tkgm-api.md) | The registry API and how to use it sparingly |
| [docs/regressions.md](docs/regressions.md) | Bugs fixed, and the guard that keeps each fixed |
