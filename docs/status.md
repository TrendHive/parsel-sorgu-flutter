# Status

Where the project stands and what comes next — the handoff for whoever picks
the work up (a person or another assistant session). Read CLAUDE.md first,
then this page. Keep it current: update it at the end of every working
session. This repository is public — never write passwords, keys, account
ids beyond `firestore.rules`, or the family's personal data here.

_Last updated: 2026-11-15 (after the owner's first use)._

## Released

Version 2.0.1 is live on https://parcel-info.web.app (the only environment):
2.0.0 plus the responsive layout, the app icon and the docs.

- Sign-in with fixed accounts; the main (admin) account exists.
- Map with two layers (registry parcels, read-only; family-drawn real
  boundaries), satellite/street imagery, "my location".
- Registry lookups store-first, one tap; Refresh by parcel number. Lookups
  work from the desktop and mobile apps only — the registry refuses
  third-party websites (`docs/tkgm-api.md`).
- Drawing: copy the registry outline, drag corners, "+" edge chips with live
  lengths, snapping, crosshair mode, undo/redo; save with name, owners and
  shares, note.
- A family tree of owners; deed-style shares that pass down the tree;
  holdings pages with totals.
- Change history; every change signed with member and server time.
- Firestore rules: member allowlist, signed stamps, read-only registry
  records, admin-only deletes, append-only log.

## Verified

- Gate green: `flutter analyze` 0 issues (infos included),
  `tool/check_structure.dart` clean, 21 tests pass, web release build.
- CI (`.github/workflows/ci.yml`) green on every pull request so far.
- Hot reload works with the single-package layout (measured: 164 ms).
- Sign-in page renders in production.

## Not yet verified on production

- The full journey signed in: tap → registry query → draw → save →
  holdings → history. Needs a member to sign in (an assistant must never
  type a member's password; ask the member to sign in in the browser).
- macOS, Windows, Android and iOS builds (configured, not yet run).

## Next steps, in order

1. Sign in on production and walk the full journey above; fix what breaks
   (the `bug-fix` skill).
2. Enter the family tree in the app (the
   owner provides the names; they are not stored in this repository).
3. Add the remaining family sign-in accounts with `tool/add_member.dart`
   (the owner runs it), committing the rules change through a pull request.
4. Create a deploy key so merges to `main` publish automatically: a Google
   service account with "Firebase Hosting Admin" on `parcel-info`, its JSON
   stored as the repository secret `FIREBASE_SERVICE_ACCOUNT_PARCEL_INFO`.
5. The items in `docs/roadmap.md` (widget tests per page first).

## How work is done here

- Flow: feature branch from `dev` → PR to `dev` (CI "Gate" must pass) →
  squash merge → release branch cut from `main` with `dev` squashed in →
  PR to `main` → deploy (`pr-flow`, `deploy` skills). `main` and `dev` are protected and cannot be deleted.
- The owner has allowed the assistant to merge pull requests once CI is
  green.
- Everything in the repository is English; Turkish only in
  `lib/domain_ui/values/l10n/app_tr.arb` (rule 13, enforced).
- Decisions and their reasons: `docs/requirements.md` (what was asked),
  `docs/research.md` (standards), `architecture.md` (design).
