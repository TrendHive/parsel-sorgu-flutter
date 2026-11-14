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
| R9 | Parcel information comes from the official source, parselsorgu.tkgm.gov.tr; check its API, it may have changed. | Verified 2026-11-14 — unchanged (`docs/tkgm-api.md`). |
| R10 | Every parcel queried from the API is saved to our own store with all its information, and drawn on the map. | Saved under its parcel number with every property verbatim. |
| R11 | Each time the app opens, everything is loaded from our store; new ones can be added. | Live Firestore listeners with an offline cache; the map shows the store. |
| R12 | The API has a request limit, so we must not send many requests. | Store first, registry last: a tap inside a stored parcel never reaches the registry; a lookup is a deliberate button; Refresh asks by number. 403 is shown as "daily limit reached". |
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
| R23 | Groups — e.g. father and his three siblings receive the same places; add them to a parcel as a group. | Groups are records; a group holds a share, split equally among its members; changing the group updates every parcel. |
| R24 | See all parcels assigned to a person, and to a group: how many m², where, and the totals. | A holdings page per person and per group: each parcel's place, area, share and owned area; totals. |

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
