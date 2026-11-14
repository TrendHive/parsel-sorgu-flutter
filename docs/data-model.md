# Data model

The family store is Cloud Firestore (`parcel-info`, `eur3`). Every collection,
its fields, who may write it, and why. `firestore.rules` is the enforcement;
this page is the explanation. Field names are the mappers' constants in
`lib/infrastructure/**/mapper/`.

## Conventions

- **Stamps.** `created`, `updated`, `refreshed` and `activity.by` are maps
  `{memberId, memberName, at}`. `at` is the server's time
  (`FieldValue.serverTimestamp()`); the rules require
  `memberId == request.auth.uid` and `at == request.time`, so a stamp cannot
  be forged or back-dated.
- **Outlines.** Lists of `{lat, lng}` maps (WGS84, full double precision) —
  Firestore has no nested arrays.
- **Atomicity.** Every change and its `activity` line are one batch.
- **Deny by default.** Anything not listed below is unreadable and unwritable.

## Collections

### `members/{uid}` — sign-in accounts

| Field | Type | |
|---|---|---|
| `name` | string | shown on every change the member makes |
| `username` | string | what the member types to sign in |
| `role` | `admin` \| `member` | only `admin` may delete |

Written only by `tool/add_member.dart` (as the member, after their id is
listed in the rules); the role must match the rules' admin list.

### `officialParcels/{neighbourhoodId-block-parcel}` — registry parcels (read-only)

| Field | Type | |
|---|---|---|
| `neighborhoodId`, `block`, `parcel` | int, string, string | the identity; also the document id |
| `cityName`, `districtName`, `neighborhoodName`, `locality`, `quality`, `sheet`, `landStatus`, `status` | string | as the registry names them |
| `registryAreaSquareMeters` | number \| null | the deed area |
| `outline` | list of `{lat, lng}` | rounded by the registry to ~1 m |
| `attributes` | map of string | every registry property, verbatim |
| `created`, `refreshed` | stamp | first lookup, latest lookup |

Members may create and refresh; nobody may delete. The app never edits one.

### `drawnParcels/{auto}` — the family's real boundaries

| Field | Type | |
|---|---|---|
| `name` | string | 1–200 characters |
| `outline` | list of `{lat, lng}` | 3–2000 corners, exact |
| `officialParcelId` | string \| null | the registry parcel it corrects |
| `owners` | list of `{kind, holderId, numerator, denominator}` | `kind` is `person` or `group`; shares are reduced fractions, total ≤ 1 |
| `ownerKeys` | list of string | `person:<id>` / `group:<id>`, for clean-up queries |
| `note` | string | |
| `measures` | `{areaSquareMeters, perimeterMeters, edgeLengthsMeters}` | computed from `outline` when saved |
| `created`, `updated` | stamp | |

Members create and update; only admin deletes.

### `persons/{auto}` — parcel owners

`name`, `note`, `created`, `updated`. Not sign-in accounts. Deleting one
(admin) also removes their owner lines from every drawing and their place in
every group, in the same batch.

### `groups/{auto}` — owners who hold together

`name`, `memberIds` (person ids), `note`, `created`, `updated`. A group's
share is split equally among `memberIds`. Deleting one (admin) removes its
owner lines from every drawing in the same batch.

### `activity/{auto}` — the change log

`action` (`queried` · `refreshed` · `created` · `updated` · `deleted`),
`target` (`officialParcel` · `drawnParcel` · `person` · `group`), `targetId`,
`label` (the record's name at the time), `by` (stamp). Append-only: no update,
no delete.

## Free-tier budget

Spark allows 50 000 reads, 20 000 writes and 20 000 deletes a day. The map
listens to four collections, so opening it reads every parcel, drawing,
person and group once (then only changes); the offline cache makes later
opens cheaper. A family's few hundred records are far inside the budget.
