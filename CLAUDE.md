# CLAUDE.md

**Parcel Atlas** — a family's shared map of land parcels. Members sign in with
fixed accounts, look parcels up in the official land registry (TKGM), draw the
real boundaries where the registry is wrong, and record who owns which share.
Everything is stored once and seen live on every device. Flutter (web,
macOS and Android in use; iOS and Windows not built yet) · package `parcel_atlas` · Firebase project `parcel-info`.

**Read before exploring:** this file, then [docs/status.md](docs/status.md)
(where the work stands and what is next), then [architecture.md](architecture.md)
for the reasons behind each rule. [README.md](README.md) is for people running
the app. Never read generated files (`*.g.dart`, `app_localizations*.dart`,
`firebase_options.dart`).

## The gate — work is not done while any step is red

```bash
flutter analyze
dart run tool/check_structure.dart   # layer imports, folders, English-only code
flutter test
```

## Architecture — one package, five layers as folders

```
lib/
  core/            base types, exceptions + causes, constants, validators
  domain/          entities, value objects, read models, rules, ports (*Interface)
  application/     use cases + one Cubit per page, the getIt container
  infrastructure/  services (internal: Firestore · external: TKGM) + repositories
  presentation/    pages, router, app shell, and the design system:
    core_ui/         app-agnostic base widgets (Base*) and values
    domain_ui/       the app's own widgets (ParcelInfo*), theme, colours, l10n
  main.dart        composition root — the only file that sees every layer
```

Allowed imports (enforced by `tool/check_structure.dart`):

| Layer | May import |
|---|---|
| `core` | nothing in the app |
| `domain` | core — and no Flutter |
| `application` | core, domain — never infrastructure, never widgets |
| `infrastructure` | core, domain |
| `presentation` | core, domain, application — never infrastructure |
| `presentation/core_ui` | core only (not domain, not application, not pages) |
| `presentation/domain_ui` | core, domain, `core_ui` (not application, not pages) |

**Folders: `lib/<layer>/<feature>/<kind>/`**, kinds singular: domain
`entity/ value_object/ read_model/ enum/ interface/ rule/ validator/`;
application `usecase/ cubit/`; infrastructure `service/ repository/ mapper/
dto/`. Features: `activity · auth · drawing · input · map · parcel · person`.

## Rules

1. **One public declaration per file, named after the file** (`share_value_object.dart` → `ShareValueObject`). Exceptions: a `sealed` family; a Cubit's `part` state; a `*Fields` record typedef beside its value object.
2. **Errors are values.** domain/application never throw; they return `Either<BaseException, T>`. An exception carries a `BaseCause` with a `CauseCode`; the UI turns the cause into words (`ExceptionCopy`). Never a sentence in an exception.
3. **Ports** are `*Interface` in `interface/`, declared in domain, implemented in infrastructure.
4. **Domain types extend their base** in `core/base/`: `BaseEntity` (equal by id), `BaseValueObject<T>` (equal by value, `validators`), `BaseReadModel` (a snapshot, equal by props). Behaviour lives on the type that owns the data.
5. **One Cubit per page**, `application/<feature>/cubit/<page>_cubit.dart` + `<page>_state.dart` as a `part`. Cubits orchestrate; they never compute. They cancel their subscriptions in `close()`.
6. **State is `sealed`**, one variant per thing the page shows.
7. **Two data sources, two kinds of service.** Internal: the family store (Firestore) — `FirestoreStoreService`. External: the official registry (TKGM) — `TkgmParcelService`. Repositories are the single source of truth and combine them; nothing above infrastructure knows which one answered.
8. **The registry is rationed.** It allows a few lookups per connection per day. Never call it for a point the store already covers, never on map move or in a loop; a tap on uncovered ground queries at once, and Refresh refetches one parcel by number. It refuses third-party websites, so lookups work only from the desktop and mobile apps (`docs/tkgm-api.md`); never disguise a request as the registry's own site. On the web the app sends nothing and points the member to the desktop or mobile app (`MapCubit` `registryReachable`).
9. **Registry parcels are read-only.** Only a registry answer changes them; members cannot edit or delete them (Firestore rules refuse it too). People, shares and notes live on drawn parcels — "Assign owner" on a registry parcel records the owner on its real boundary (linked, or covering its ground), and only when nobody drew it stores a drawing with the registry's outline.
10. **Every write is signed and logged.** A repository write stamps `created`/`updated` with the member and server time and adds one `activity` line per record in the same atomic batch; a line about a drawing or person remembers the record's `before` under a shared `changeId`, so the change can be undone (`UndoChangeUseCase`; a transaction refuses it unless each record's `updated` is still the change's own time).
11. **Geometry is computed in one place** — `GeoRules` (WGS84 ellipsoid, local tangent plane). Shares are exact fractions (`ShareValueObject`), never doubles. Drawings share boundaries, never ground: corners snap to stored corners and sides, an overlap deeper than half a metre is refused on save (assigning an owner is never refused over geometry), side lengths are geodesic (Vincenty), a merge joins neighbours and archives the absorbed pieces (`mergedInto`), a split turns the drawing into its first piece and creates the rest in one batch, and a re-division by deed reshapes both neighbours in one batch. Who holds what today follows from the family tree (`FamilyRules`): a share recorded on an ancestor whose shares passed on is split equally among the children, generation by generation; a spouse link (`spouseId`, one side only) shows a couple's children under both but never changes inheritance.
12. **`getIt` only in `main.dart` and a page's `BlocProvider`.** Everything else takes dependencies through its constructor.
13. **English everywhere except the language files.** Code, comments, docs, commits: English. Turkish lives only in `lib/presentation/domain_ui/values/l10n/app_tr.arb` (and `app_en.arb` for English). No string literal a user reads is written in a widget.
14. **Comments sit above a declaration** — one `///` block naming members as `[x]`; no comments inside bodies.
15. **No magic values.** Numbers and strings that mean something are named: `CoreConstants`, `*Rules`, `BaseDimens`/`ParcelInfoDimens`, `ParcelInfoColor`.
16. **A bug fix ships a test that fails without it**, named after the symptom.
17. **Docs move with the code.** A change to structure, data model, rules or commands updates CLAUDE.md, architecture.md and README.md in the same change.

## Commands

```bash
flutter run -d chrome                         # hot reload works (one package)
flutter gen-l10n                              # after editing an .arb
dart run build_runner build -d                # after editing a @JsonSerializable DTO
dart run tool/add_member.dart <username> "<Name>" [--admin]   # create a family account
dart run tool/import_parcels.dart <username> <neighbourhoodId> <block>/<parcel> ...   # store parcels by number
flutter build web --release && firebase deploy               # publish (the deploy skill)
```

## One environment: production

There is exactly one environment — the Firebase project `parcel-info`,
served at `parcel-info.web.app`. No flavors, no staging project, no dev
backend. The `dev` branch is only the integration branch: it deploys nowhere;
a merge to `main` is a release and publishes to production.

## Firebase (free Spark plan only)

Hosting (`parcel-info.web.app`), Firestore (`eur3`) and Email/Password auth.
Accounts are fixed: there is no sign-up in the app; `tool/add_member.dart`
creates them and regenerates the member list in `firestore.rules`. Never add a
paid service.

## Docs, skills and agents

`docs/requirements.md` (what the owner asked, with each decision) ·
`docs/research.md` (Flutter/Dart standards and where we deviate) ·
`docs/data-model.md` · `docs/tkgm-api.md` (+ `docs/tkgm-parsel-sorgu.postman_collection.json`, the runnable reference) · `docs/regressions.md` ·
`docs/roadmap.md`. Skills in `.claude/skills/` (architecture-rules, new-page,
i18n-copy, bug-fix, registry-quota, add-member, deploy, pr-flow); agents in
`.claude/agents/` (flutter-developer, code-reviewer).

## Git and CI — the `pr-flow` skill

`main` (releases) and `dev` (integration) are protected: they change only
through pull requests whose "Gate" check is green (`.github/workflows/ci.yml`:
format, analyze with infos fatal, structure, tests, web build). Branch from
`dev`; a merge to `main` deploys. The pre-commit hook runs the fast half
(enable once: `git config core.hooksPath .githooks`). Commit messages in
English, conventional (`feat(map): …`). Never commit secrets, service-account
keys or family data.
