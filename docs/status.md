# Status

Where the project stands and what comes next — the handoff for whoever picks
the work up (a person or another assistant session). Read CLAUDE.md first,
then this page. Keep it current: update it at the end of every working
session. This repository is public — never write passwords, keys, account
ids beyond `firestore.rules`, or the family's personal data here.

_Last updated: 2026-11-15 (after the owner's first use)._

## Released

Version 2.1.0 is live on https://parcel-info.web.app (the only environment).

- Sign-in with fixed accounts; the main (admin) account exists.
- Map with two layers (registry parcels, read-only; family-drawn real
  boundaries), satellite/street imagery to zoom level 24, "my location".
- One tap on unknown ground queries the registry; a stored parcel never
  does; Refresh by parcel number.
- Drawing: copy the registry outline, drag corners, "+" edge chips with live
  lengths, snapping, crosshair mode, undo/redo, keyboard shortcuts.
- A family tree of owners (parent link, "share passed to children");
  deed-style shares that pass down the tree; holdings pages with totals.
- Change history; every change signed with member and server time.
- Responsive layout by Material window size classes.

## Verified

- Gate green: `flutter analyze` 0 issues, `tool/check_structure.dart`
  clean, 43 tests, web release build; CI green on every pull request.
- On production, signed in: the family tree was entered through the app
  (seven people, three generations) — sign-in, rules, writes and the live
  tree all work. A boundary drawn by the owner is stored and shown.
- Hot reload works with the single-package layout.

## Known limits

- **Registry lookups do not work in the web app** — settled by design. The
  registry refuses browser requests that carry another website's origin, and a
  browser cannot omit that origin, so only a non-browser client (native app,
  `curl`, Postman) gets through (`docs/tkgm-api.md`). Decided split: the
  desktop/mobile apps do the lookups; the web app does drawing and viewing.
  The runnable API reference is the Postman collection
  (`docs/tkgm-parsel-sorgu.postman_collection.json`).
- **Imagery.** The free aerial source has no data past level 18 for the
  family's area; deeper zoom enlarges it, so it softens. Sharper imagery and
  3D need a licensed provider / another map engine; the owner decided
  against any paid service, so this stays as it is.
- **Native builds.** The bundle id is `com.parcelatlas.app` on iOS, macOS
  and Android (registered in the Firebase project; not in use on the App
  Store or Google Play as of 2026-11-15). The macOS build still needs its
  provisioning profile: open `macos/Runner.xcworkspace` in Xcode once so
  Xcode registers the id and creates it. Windows,
  Android and iOS builds have not been run yet.

## Code audit (2026-11-15)

Checked: layer imports (enforced, clean), analyzer at zero, formatting,
one declaration per file, English-only code, tests.

- **Unused code removed.** Every file not reachable from `main.dart` (35
  files from the original scaffold: unused bases, storage, device/package
  utilities, info/error dialogs, spare widgets) was deleted, with the four
  packages only they used (`flutter_secure_storage`, `device_info_plus`,
  `package_info_plus`, `flutter_svg`).
- **Tests:** domain rules, value objects, the snapshot, mappers and the main
  use cases and the map Cubit are covered. Not yet covered: repositories and
  the Firestore service (need an emulator or fakes of Firestore), the
  remaining use cases (refresh, save/delete drawing, delete person), the
  other Cubits, and widget tests for pages.
- **Security rules** have no automated tests (emulator suite) yet.

## Next steps, in order

1. Create the macOS provisioning profile, then query parcels from the app.
2. Web lookups: see `docs/roadmap.md`.
3. Fair-division analysis on the family tree (roadmap).
4. Remaining tests listed in the audit; a rules test suite.
5. Add the other family sign-in accounts with `tool/add_member.dart`.
6. A deploy key so merges to `main` publish automatically (secret
   `FIREBASE_SERVICE_ACCOUNT_PARCEL_INFO`).

## How work is done here

- Flow: feature branch from `dev` → PR to `dev` (CI "Gate" must pass) →
  squash merge → release branch cut from `main` with `dev` squashed in →
  PR to `main` → deploy (`pr-flow`, `deploy` skills). `main` and `dev` are protected and cannot be deleted.
- The owner has allowed the assistant to merge pull requests once CI is
  green.
- Everything in the repository is English; Turkish only in
  `lib/presentation/domain_ui/values/l10n/app_tr.arb` (rule 13, enforced).
- Decisions and their reasons: `docs/requirements.md` (what was asked),
  `docs/research.md` (standards), `architecture.md` (design).
