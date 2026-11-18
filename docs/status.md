# Status

Where the project stands and what comes next — the handoff for whoever picks
the work up (a person or another assistant session). Read CLAUDE.md first,
then this page. Keep it current: update it at the end of every working
session. This repository is public — never write passwords, keys, account
ids beyond `firestore.rules`, or the family's personal data here.

_Last updated: 2026-11-18 (spouse link, split direction, undo, merge, side lengths, fixes — on branch `feat/person-spouse`, not merged)._

## Released

Version 2.4.0 is live on https://parcel-info.web.app (the only environment).

**Update every installed app before anyone merges parcels.** 2.4.0 archives
merged pieces (`mergedInto`); Android and macOS builds older than 2.4.0 do
not know that field and show the archived pieces as live drawings lying
over the merged parcel (their overlap check then refuses edits nearby).
Undo is safe with old builds: it refuses any record changed since.

- Sign-in with fixed accounts; several family accounts exist.
- Map with two layers (registry parcels, read-only; family-drawn real
  boundaries), satellite/street imagery to zoom level 24, "my location".
- Registry lookups from the desktop and mobile apps: one tap on unknown
  ground, Refresh by number, and a search by neighbourhood / block / parcel.
  On the website a lookup sends nothing and points to the app; stored
  parcels work everywhere.
- Drawing: copy the registry outline, drag corners, "+" edge chips with live
  lengths, crosshair mode, undo/redo, keyboard shortcuts. Corners snap to
  stored corners and sides; a drawing that overlaps another is refused.
- Split a drawing in two by a cut line, or into equal-area pieces (per child
  of a sole owner, or by number).
- A family tree of owners (parent link, "share passed to children"),
  deed-style shares that pass down the tree, holdings pages with totals,
  "Assign owner" on a registry parcel with a walk-down-the-tree picker, and
  colouring of the map by a generation of the tree.
- Change history; every change signed with member and server time.
- App icon and the name "Parsel Atlası" on every platform.

## Platforms

| Platform | State |
|---|---|
| Web | Released (2.4.0). No registry lookups, by the registry's choice. |
| macOS | Builds and runs signed with the owner's team; sign-in and lookups verified by the owner. Run with `flutter run -d macos` or build in Xcode. Must be signed with a provisioning profile — an ad-hoc build cannot sign in (`docs/regressions.md`). Not packaged for download yet. |
| Android | Release APK signed with the upload keystore (kept outside the repository, referenced by the gitignored `android/key.properties`). Distributed to the family testers through Firebase App Distribution. |
| iOS | Not built. The owner has a paid developer account. |
| Windows | Not built (needs a Windows machine or CI runner). |

## Verified

- Gate green: `flutter analyze` 0 issues, `tool/check_structure.dart`
  clean, 60 tests, web release build; CI green on every pull request.
- By the owner, by hand: sign-in and registry lookups in the macOS app; the
  family tree; a drawn boundary.
- By the assistant on the live site: it loads, the stored parcels show, the
  search and colour buttons are there and the colour menu lists the
  generations.

## Not verified — try these first

The logic below is unit-tested; nobody has clicked through the screens:

- search by number (dialog, a stored number, an unknown number in the app);
- colouring by generation and its legend with real ownership data;
- "Assign owner" on a registry parcel (onto its real boundary) and the tree picker;
- colouring by owner on both layers, and the legend;
- the owner picker as an opening tree, "Assign owner" on a real boundary
  (sole owner, or co-owner through the details);
- the comparison page (add from either panel, the bar on the map);
- "Divide with neighbour by deed" on two real neighbours with deeds;
- side snapping and the overlap refusal while drawing;
- split in two (cut line, preview, confirm) and split equally;
- the website's "use the app" notice on a tap, Refresh and search;
- `tool/import_parcels.dart` end to end (it compiles and reads the cached
  answers; its sign-in and store writes have not run).

## Open — asked for and not finished

1. **The parcels from the owner's handwritten list.** All 21 registry
   answers were fetched and are cached outside the repository. They are
   **not stored yet**: storing is signed by a member, so the owner runs
   `tool/import_parcels.dart` once with their password. One number on the
   paper disagrees with the registry on area and needs the owner's check
   before it is trusted. The paper also names an owner per parcel; those
   are not assigned yet (use "Assign owner" after the import).
2. **Fair-division analysis** — the owner's stated goal ("who owes how
   much"): compare what each heir should hold with what their parcels
   cover. Not started; the equal split is only a tool towards it.
3. **Desktop and iOS distribution.** Asked for with "publish mobile and
   desktop versions". Only Android is distributed. Open: a signed,
   notarised macOS download and a Windows build on GitHub Releases; an iOS
   build through TestFlight or App Distribution.
4. **Neighbourhood list in the search dialog**, so a new neighbourhood needs
   no code (roadmap).
5. **Sharper imagery and 3D** — decided against: free resources only.
6. **Lookups on the website** — not possible client-side; decided.

## In progress — branch `feat/person-spouse` (2026-11-18)

Gate green locally; not yet committed, reviewed or merged.

- **Spouse link** (R54): `spouseId` on a person, one side only. The owner
  asked for a wife to be added beside her husband with the same children:
  once released, add her in the app (People → add person → Spouse). The
  data entry is the owner's; inheritance is unchanged by design.
- **Split direction** (R55): the equal split asks for a bearing and shows a
  numbered preview.
- **Undo** (R56): activity lines remember `before` under a `changeId`;
  undo from the saved message or any history line. Verify by hand before
  release — the store side (`ActivityRepository.undo`) has no automated
  test (`fake_cloud_firestore` conflicts with `equatable` 3; no emulator
  set up): edit a drawing and undo it; split and undo as the main account;
  split and try to undo as a member (refused); edit, edit again, try to
  undo the first (refused); delete a person and undo (owner lines, children
  and spouse come back).

- **Merge back** (R57), **side lengths** (R58), **overlap on assign**
  (R59, a regression fix), **large text on phones** (R60). Not verified by
  hand: merging on the map, the owner dialog's "Up to parent", the side
  labels, and the map on a phone with the largest text size.

## Housekeeping still open

- No licence file; the owner has not chosen one.
- The anonymous sign-in provider from the first version is still enabled
  (Firebase console → Authentication → Sign-in method).
- No deploy key: merges to `main` do not publish by themselves (secret
  `FIREBASE_SERVICE_ACCOUNT_PARCEL_INFO`); deploys are run by hand.
- iOS and macOS use two different signing teams of the owner; pick one
  before distributing.
- The Firebase project id and web address (`parcel-info`) and the
  `ParcelInfo*` class prefix keep the old name; the project id cannot be
  renamed, the prefix is a refactor nobody asked for yet.
- The local checkout folder still has the old repository name.
- Android: Flutter warns that the Kotlin Gradle plugin must give way to
  built-in Kotlin in a future version.
- Old App Distribution testers from the Firebase project's earlier use are
  still listed; the owner may want to remove them.

## Code audit (2026-11-15)

Checked: layer imports (enforced, clean), analyzer at zero, formatting,
one declaration per file, English-only code, tests.

- **Unused code removed.** Every file not reachable from `main.dart` was
  deleted with the four packages only they used.
- **Tests:** domain rules (geometry, splitting, overlap, family levels),
  value objects, the snapshot, mappers, the main use cases and the map
  Cubit are covered. Not yet covered: repositories and the Firestore
  service (need an emulator or fakes of Firestore), the refresh and delete
  use cases, the other Cubits, and widget tests for any page or dialog.
- **Security rules** have no automated tests (emulator suite) yet.
- **`tool/import_parcels.dart` duplicates** the registry reading and the
  document layout of the app's mappers, because a plain-Dart tool cannot
  import them (they reach Flutter). Change both together.
- **`GeoRules` has grown** to hold snapping, overlap and splitting; split it
  by concern if it grows again.

## How work is done here

- Flow: feature branch from `dev` → PR to `dev` (CI "Gate" must pass) →
  squash merge → release branch cut from `main` and set to `dev`'s tree →
  PR to `main` → deploy (`pr-flow`, `deploy` skills). `main` and `dev` are protected and cannot be deleted.
- The owner has allowed the assistant to merge pull requests once CI is
  green.
- Everything in the repository is English; Turkish only in
  `lib/presentation/domain_ui/values/l10n/app_tr.arb` (rule 13, enforced).
- Decisions and their reasons: `docs/requirements.md` (what was asked),
  `docs/research.md` (standards), `architecture.md` (design).
