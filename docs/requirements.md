# Requirements

What the owner asked for, in their words' meaning, with the decision taken for
each. This is the product's memory: when a question comes up later ("why can't
I edit an official parcel?"), the answer is here. Add to it whenever a new
requirement is agreed; never delete one — mark it superseded instead.

Collected 2026-11-14 – 2026-11-15.

## Who and where

| # | Requirement | Decision |
|---|---|---|
| R1 | Family members reach the app through a website. | Flutter web on Firebase Hosting (`parcel-info.web.app`). |
| R2 | It should also run on mobile, Windows and macOS — the project started multi-platform. | Web, Android, iOS, macOS, Windows. Linux is out: Firebase has no Linux support. |
| R3 | Only free resources. | Firebase Spark (Hosting, Firestore, Auth); Esri World Imagery and OpenStreetMap tiles; the public registry. No server of our own, no paid plan. |
| R4 | Ease of use is what matters most. | Turkish UI, large controls, one panel per parcel, as few steps as possible. |
| R5 | The parcels are mostly in one area ("Düzköy", "İspir", Erzurum). | The map opens there before anything is stored, then on the stored parcels. |

## Accounts

| # | Requirement | Decision |
|---|---|---|
| R6 | Sign-in, but with fixed accounts. | No sign-up in the app. Accounts are created with `tool/add_member.dart`; Firestore's rules list them. |
| R7 | The owner needs a main user to use and test with. | An admin role. Only admin may delete. The owner creates it with the tool and types their own password. |
| R8 | Every change shows who made it. | Every record carries created/updated stamps (member + server time); an activity log lists every change. |

## Official parcels (from the registry)

| # | Requirement | Decision |
|---|---|---|
| R9 | Parcel information comes from the official land registry (TKGM) service; check the API, it may have changed. | Documented in `docs/tkgm-api.md`; the runnable reference is the Postman collection (`docs/tkgm-parsel-sorgu.postman_collection.json`). |
| R10 | Every parcel queried from the API is saved to our own store with all its information, and drawn on the map. | Saved under its parcel number with every property verbatim. |
| R11 | Each time the app opens, everything is loaded from our store; new ones can be added. | Live Firestore listeners with an offline cache; the map shows the store. |
| R12 | The API has a request limit, so we must not send many requests. | Store first, registry last: a tap inside a stored parcel never reaches the registry; Refresh asks by number. (The separate "query" button was superseded by R37.) |
| R13 | Tap a parcel to update it. | "Refresh" refetches that one parcel from the registry. |
| R14 | Information from the registry changes only through the API — members never edit it; it is used for analysis and as a source to copy into drawings. | Registry parcels are read-only (rules enforce it); no edit, no delete. |

## Drawn parcels (the family's real boundaries)

| # | Requirement | Decision |
|---|---|---|
| R15 | Official boundaries are sometimes drawn wrong; we draw the real ones on top and assign them. | A second layer of drawn parcels, optionally linked to the registry parcel it corrects. |
| R16 | Two layers on screen, each can be switched on and off. | "Official" and "Real" layer toggles. |
| R17 | Drawings look the same on every device and can be checked from any device. | Stored in Firestore, read live. |
| R18 | Drawing must be easy; a very good interface for it. | Draggable numbered corners, "+" handles on edges to insert, crosshair mode for precise placement, undo/redo, live edge lengths and area, satellite imagery. |
| R19 | We can copy the real (official) parcel and update its shape. | "Draw real boundary" starts from a copy of the registry outline; move only the wrong corners. |
| R20 | Calculations must be done using the references and saved correctly. | Ellipsoidal (WGS84) area, perimeter and edge lengths in one place; corners snap to reference corners; measurements stored with the drawing; area compared with the registry's figure. |

## People, groups, shares

| # | Requirement | Decision |
|---|---|---|
| R21 | Create people and assign parcels to them; it must be saved. | People are records; ownership lines live on drawn parcels. |
| R22 | Several people per parcel, each with a share. | Ownership lines with deed-style fractions (1/4), exact arithmetic, total may not exceed 1. |
| R23 | Groups — e.g. father and his three siblings receive the same places; add them to a parcel as a group. | Superseded by R39 (family tree). |
| R24 | See all parcels assigned to a person, and to a group: how many m², where, and the totals. | A holdings page per person: each parcel's place, area, the share that reaches them (and from which ancestor), owned area; totals. |

## Engineering

| # | Requirement | Decision |
|---|---|---|
| R25 | Make the project work again. | Fixed the web build (dependency incompatibilities) and the startup hang when location was denied. |
| R26 | Keep the structure the owner built; improve it from recipely and lgs_reward_hunt (DDD, clean architecture, clean code, skills, docs) — not their look or flow. | Same seven layers and naming, as folders in one package; ports in domain; rules in CLAUDE.md and `tool/check_structure.dart`. |
| R27 | Research and choose the best structure. | One package with layer folders (Flutter's architecture guide); see architecture.md. |
| R28 | Internal and external sources as services, following best practice. | `FirestoreStoreService` (internal), `TkgmParcelService` (external), repositories as single source of truth. |
| R29 | Hot reload must work. | Fixed by the single-package layout. |
| R30 | Update every library and the global Flutter. | Flutter 3.50 / Dart 3.14; every direct dependency on its latest major. |
| R31 | An English project name; the app stays Turkish. | Parcel Atlas (`parcel_atlas`); the title users see is Turkish, from the language file. |
| R32 | Turkish only in the language file; everything else English, comments included. | Rule 13 in CLAUDE.md; enforced by `tool/check_structure.dart`. |
| R33 | README, CLAUDE.md, skills, agents and docs, written as the project grows. | CLAUDE.md, architecture.md, README.md, `docs/`, `.claude/skills`, `.claude/agents`. |
| R34 | Document what the owner explains so it is permanent. | This file. |
| R35 | `main` and `dev` protected and undeletable; a Recipely-style flow with pull requests and checks on every push. | Both branches: pull request required, "Gate" check required, no deletion, no force-push, admins included. CI on every push and pull request. |
| R36 | Only one environment: production. | One Firebase project (`parcel-info`); no flavors or staging; `dev` deploys nowhere, `main` releases. |

## Added 2026-11-15, after first use

| # | Requirement | Decision |
|---|---|---|
| R37 | A tap on a parcel nobody has queried should query it directly — not a second press. | A tap on ground the store does not cover goes straight to the registry and the answer is stored. |
| R38 | The map must go much deeper for fine drawing, without "map data not yet available". | Zoom to level 24; imagery is requested only at levels that exist (18 for the free aerial source there) and enlarged beyond. |
| R39 | Instead of groups, a family tree: fathers and children linked (a grandfather, his sons, their children), because later the app must compare whether land was divided correctly among siblings and who owes what. | People have a parent and a "share passed to children" flag; a share recorded on an ancestor reaches the heirs in equal parts, generation by generation. Groups removed. |
| R40 | High-quality, unblurred imagery everywhere; 3D would be ideal. | Open. The free aerial source stops at level 18 for the area; sharper imagery and 3D need a licensed provider and a different map engine — see the roadmap. Owner's decision. |
| R41 | Registry lookups must work. | They work from the desktop and mobile apps. The registry refuses third-party websites, so the web app cannot look parcels up; whether to route around that is the owner's decision (roadmap). |
| R42 | Check whether `domain_ui` belongs inside presentation. | Yes — `core_ui` and `domain_ui` moved into `presentation/`; five layers remain, and the structure check keeps the design system below the pages. |
| R43 | An English repository name. | Renamed to `parcel-atlas`. |
| R44 | The app's name must not show as `parcel_info` anywhere a person sees it. | The app, its window and its file are "Parsel Atlası" on every platform; Windows and Linux binaries are `parcel_atlas`. Code identifiers keep the `ParcelInfo` prefix. |
| R45 | Look a parcel up by entering its block and parcel number. | Search button on the map: neighbourhood (from the stored parcels, or its code), block, parcel. A stored number is answered from the store; an unknown one costs one lookup. |
| R46 | Colour the land by owner, and by a chosen level of the family tree. | By default the map colours by owner: one colour per recorded owner, brown for land several people share, light grey for a drawing nobody owns yet, with a legend. A registry parcel takes the colour of its real boundaries' owners, so this works with only the registry layer on. The palette button switches to colouring by a generation of the tree. |
| R47 | Assign owners on registry parcels, choosing step by step down the tree without going to the bottom. | "Assign owner" on a registry parcel records the owner on its real boundary — a drawing linked to it, or an unlinked one covering its ground (asked which, when there are several); a boundary that already has owners opens its details instead. Only a parcel nobody drew gets a new drawing with the registry's outline and that owner. The map does not move (the registry record stays read-only, rule 9). People are picked by walking down the tree; a person whose share passed on shows their children as equal holders. |
| R48 | Drawings must not overlap and must fit together without gaps. | Corners snap to stored corners and, failing that, onto the nearest stored side; a drawing that would cover more than 2 m² of another is refused. |
| R49 | Split a chosen parcel in two; split equally, automatically, for example among a father's sons — without being complicated. | "Split in two": two taps set a cut line, the pieces are previewed with their areas. "Split equally": one tap gives each child of an owner an equal-area piece as sole owner, or a typed number of pieces keeps the owners. The original drawing becomes the first piece, so nothing is deleted. |
| R50 | In the owner picker the heads of the family (the two grandfathers) come first; the tree may open and close. | The picker is a tree that opens and closes in place: people with children and no parent first, people on their own last. No names are written in the code — the tree's shape decides. |
| R51 | Assign owners on drawn real boundaries too, so they can be compared. | "Assign owner" on a real boundary: the chosen person becomes sole owner of an unowned one; on one that has owners, the details open with the person added for their share to be typed (co-owner). |
| R52 | A comparison area: add parcels to it and compare by owner, by size. | "Add to comparison" on both panels; a bar on the map opens the comparison page: per owner, real against deed area and the difference; per parcel, the same with its owners. A registry parcel stands for its real boundaries; a deed split among several boundaries is divided in proportion to their areas. The list lives on the map until cleared. |
| R53 | Two neighbouring parcels wrongly divided: show what the correct division would look like, as real boundaries, with sizes. | "Divide with neighbour by deed" on a real boundary, then a tap on the neighbour: the two are joined along their shared side and cut again parallel to the old line so each gets its deed's part of the joined ground. The new shapes and areas (against deed and today) are previewed; saving reshapes both in one batch, keeping names and owners. Both need different registry parcels. |
