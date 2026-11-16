# Architecture

[CLAUDE.md](CLAUDE.md) is the rule list. This file is the reasoning: why the
boundaries sit where they do, and what breaks when one is crossed. When the two
disagree, CLAUDE.md wins and this file needs an edit.

The ideas come from the owner's own layer design (core / core_ui / domain /
domain_ui / application / infrastructure / presentation), tightened with the
Domain-Driven Design and Clean Architecture rules of the `recipely` and
`lgs_reward_hunt` projects, and checked against Flutter's official
architecture guide.

---

## One package, layers as folders

The layers began as seven local packages under `lib/`. That enforced the import
rules through each package's pubspec — a real strength — but cost seven
pubspecs, seven l10n/codegen setups, and broke hot reload: a package nested in
the app's `lib/` has two identities (`package:core/...` and
`package:<app>/core/lib/...`), so the file watcher could not tell which library
a save had changed.

Flutter's own architecture case study keeps one package with layer folders
(`lib/data`, `lib/domain`, `lib/ui`), and so does `lgs_reward_hunt`. Separate
packages pay for themselves when a team ships a layer to several apps; this app
has one. So the layers are folders with the same names, and what the package
graph used to enforce, `tool/check_structure.dart` now enforces: a forbidden
import fails the gate exactly as a missing dependency failed the build.

## The design system belongs to presentation

`core_ui` (app-agnostic base widgets) and `domain_ui` (the app's own widgets,
theme, colours and copy) began as top-level layers. They are UI, and in both
Clean Architecture and Flutter's own case study (its `ui/core` folder) shared
widgets and themes are part of the UI layer — so they now live inside
`presentation/`. What the separate layers gave is kept as a rule the
structure check enforces: the design system never imports a page or the
application layer, and `core_ui` knows nothing of the domain.

## The dependency rule

```
presentation ──► application ──► domain ◄── infrastructure
  (pages ──► domain_ui ──► core_ui)        everything ──► core
main.dart (composition root) sees every layer
```

The domain declares what it needs as ports (`*Interface`); infrastructure
implements them. Before this change `domain` depended on `infrastructure` and
the registry service sat in `application`, so the core of the app could not be
tested without Dio. Inverting it means `domain` and `application` run in plain
`dart test` with fakes — no network, no Firebase, no widget tree.

`main.dart` is the only file allowed to see both infrastructure and
presentation: it builds the services and repositories and registers them in
`getIt` against the domain's ports. A page resolves its Cubit there inside its
`BlocProvider`; nothing else looks anything up.

## Two data sources: an internal store and an external registry

Flutter's architecture guide splits the data layer into **services** — one per
source, stateless wrappers around it — and **repositories**, the single source
of truth that combine services and turn raw data into domain types.

| Source | Service | Nature |
|---|---|---|
| The family store | `FirestoreStoreService` | Ours. Read live by every device, written in atomic batches, cached offline. |
| The official land registry (TKGM) | `TkgmParcelService` | Theirs. Read-only, slow, and rationed — a few lookups per connection per day. |

The order of questions is always **store first, registry last**:

1. A tap on the map is answered from the store (`MapSnapshotReadModel.hitAt`) —
   no network at all.
2. A tap on a spot the store does not cover asks the registry at once; the
   answer is stored, so each parcel costs one lookup ever.
3. A registry answer is saved under its parcel number
   (`neighbourhood-block-parcel`), so the same parcel queried from two phones
   is one record.
4. "Refresh" refetches one stored parcel by number, never by point.

The registry refuses third-party websites, so lookups work from the desktop
and mobile apps only; the web app works on what is stored (`docs/tkgm-api.md`). A 403 becomes a
`QuotaExceededException`; a 404, `NotFoundException(NoParcelCause)`.

## Registry parcels are reference data

A registry parcel says what the state's records say. The family cannot correct
the state's records, so the app does not let anyone edit one: its only write is
"store what the registry answered". Corrections are a second layer — drawn
parcels — that may link to the registry parcel they correct. The map shows both
layers and either can be hidden, so they can be compared.

People, shares and notes belong to drawn parcels: a drawn parcel is the
family's record of what is really theirs.

## Ownership: a family tree and shares

A drawn parcel holds a list of ownership lines; each line is a person with a
share written as a deed writes it (1/4). Shares are integer fractions
(`ShareValueObject`) — three thirds make exactly one — and together may not
exceed the whole parcel.

People form a family tree: each person may name a parent, and may be marked
"share passed to children". A parcel is recorded on whoever it is recorded
on — often an ancestor — and `FamilyRules` works out who holds it today: at
each generation whose shares have passed on, the share is split equally among
the children. Recording a field on a grandfather is enough for every
grandchild's page to show their eighth. An earlier design used flat groups of
people; the tree replaced it because the family's real question is
inheritance: was the land divided as the tree says it should have been, and
who holds more or less than their part. Holdings, totals and owned areas are
derivations on `MapSnapshotReadModel` — computed live, never stored.

## Geometry

Corners are WGS84 latitude/longitude — the registry's own system. Lengths and
areas come from one place, `GeoRules`: the ellipsoid is replaced by its tangent
plane at the polygon's centre, scaled by the meridian and prime-vertical radii
there. At parcel scale that differs from the ellipsoid by far less than a
millimetre — and does not carry the ~0.3% error of a spherical formula.

The registry rounds its corners to five decimals (about a metre), so an area
computed from its outline is off by a few percent; the app shows the
registry's own area figure for a registry parcel and computes only what the
family drew, whose corners are exact.

Drawing snaps a corner to a stored corner within 14 screen pixels, so a drawn
boundary that shares a corner with the registry, or with a neighbour's drawing,
shares it exactly.

Re-dividing two neighbours by their deeds (`GeoRules.redivide`) relies on that
exactness: the two outlines are joined by removing the sides they share (a
corner lying on the other's side within 5 cm counts), and the joined ground is
cut again by a straight line parallel to the old dividing line, found by
bisection on area. The outer boundary — what touches other neighbours — is
kept exactly, and both drawings are reshaped in one batch
(`DrawnParcelRepositoryInterface.reshape`), so the ground is never stored
twice. A registry parcel's real boundaries are the drawings linked to it and
the unlinked ones that cover its ground (`drawingsCorrecting`).

## Errors are values

domain and application never throw. They return `Either<BaseException, T>`.
An exception says what kind of thing failed (`ValidationException`,
`QuotaExceededException`, …); its `BaseCause` says precisely why
(`TooFewCornersCause`, `RegistryQuotaCause`, `EmptyCause('personName')`), each
with a `CauseCode`. The presentation layer turns the cause into Turkish words
in one place, so a message can be reworded without touching the layer that
produced it.

## Every change is signed

Members sign in with fixed accounts created by `tool/add_member.dart`; there is
no sign-up in the app. Firestore's rules list the members' ids, so an account
someone creates outside the tool reads and writes nothing. Every write stamps
who and when (server time), and adds an `activity` line in the same atomic
batch — a change without its log line cannot exist. The main (admin) account is
the only one that may delete.

## Free resources only

Firebase Spark: Hosting, Firestore and Email/Password auth. Map imagery: Esri
World Imagery and OpenStreetMap, both free with attribution. The registry is a
public service. Nothing in the app needs a paid plan or a server of our own.
