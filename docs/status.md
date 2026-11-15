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

- **Registry lookups do not work in the web app.** The registry refuses
  third-party websites (`docs/tkgm-api.md`). They work from a desktop or
  mobile build. Decision pending with the owner (`docs/roadmap.md`).
- **Imagery.** The free aerial source has no data past level 18 for the
  family's area; deeper zoom enlarges it, so it softens. Sharper imagery and
  3D need a licensed provider / another map engine (roadmap, owner's call).
- **macOS build** is configured and signed with the iOS team, but needs a
  provisioning profile: open `macos/Runner.xcworkspace` in Xcode once (or
  build with `-allowProvisioningUpdates`) so Xcode creates it. Windows,
  Android and iOS builds have not been run yet.

## Code audit (2026-11-15)

Checked: layer imports (enforced, clean), analyzer at zero, formatting,
one declaration per file, English-only code, tests.

- **Unused legacy files** from the original scaffold, kept until the owner
  decides (nothing imports them): `core/base/base_usecase.dart`,
  `base_local_repository.dart`, `base_remote_repository.dart`,
  `base_service.dart`, `core/storage_with_map/`,
  `core/exception/internal_server_exception.dart`,
  `infrastructure/storage/fcm_token_manager.dart`,
  `infrastructure/utility/device_utils.dart`, `package_utils.dart`,
  `domain/logger/logger.dart`, `domain_ui/dialog/info/`,
  `domain_ui/dialog/error/`, `domain_ui/widgets/button/parcel_info_text_button.dart`.
  Removing them would also drop `flutter_secure_storage`,
  `device_info_plus`, `package_info_plus` and `flutter_svg`.
- **Tests:** domain rules, value objects, the snapshot, mappers and the main
  use cases and the map Cubit are covered. Not yet covered: repositories and
  the Firestore service (need an emulator or fakes of Firestore), the
  remaining use cases (refresh, save/delete drawing, delete person), the
  other Cubits, and widget tests for pages.
- **Security rules** have no automated tests (emulator suite) yet.

## Next steps, in order

1. Owner decisions in `docs/roadmap.md` (web lookups; imagery / 3D) and on
   the unused legacy files above.
2. Create the macOS provisioning profile, then query parcels from the app.
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
