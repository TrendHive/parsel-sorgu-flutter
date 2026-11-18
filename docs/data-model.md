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
| `owners` | list of `{personId, numerator, denominator}` | shares are reduced fractions, total ≤ 1 |
| `ownerIds` | list of string | the same person ids, flat, for clean-up queries |
| `note` | string | |
| `measures` | `{areaSquareMeters, perimeterMeters, edgeLengthsMeters}` | computed from `outline` when saved; lengths are geodesic (Vincenty) from this version on |
| `mergedInto` | string, absent normally | the drawing this piece was merged into; an archived piece is on no map or total, kept so the merge can be undone |
| `created`, `updated` | stamp | |

Members create and update; only admin deletes.

### `persons/{auto}` — parcel owners and their family tree

| Field | Type | |
|---|---|---|
| `name` | string | |
| `parentId` | string \| null | the person's parent in the tree |
| `spouseId` | string \| null | the person's husband or wife; stored on one side only, read from both; changes nobody's inheritance |
| `passesToChildren` | bool | the person's shares are split equally among their children |
| `note` | string | |
| `created`, `updated` | stamp | |

Not sign-in accounts. Deleting one (admin) also removes their owner lines
from every drawing and unlinks their children and spouse, in the same batch.

### `activity/{auto}` — the change log

`action` (`queried` · `refreshed` · `created` · `updated` · `deleted`),
`target` (`officialParcel` · `drawnParcel` · `person`), `targetId`,
`label` (the record's name at the time), `by` (stamp). Append-only: no update,
no delete.

A line about a drawing or a person also carries what undo needs: `changeId`
(shared by every line one save wrote — a split's pieces, a person's delete and
its clean-up), `path` (the record's full store path) and `before` (the record
as it was just before the change, or null when the change created it). A line
written by undoing a change has `undo: true`. Registry lookups, and lines from
before undo existed, have none of these and cannot be undone.

## Free-tier budget

Spark allows 50 000 reads, 20 000 writes and 20 000 deletes a day. The map
listens to three collections, so opening it reads every parcel, drawing
and person once (then only changes); the offline cache makes later
opens cheaper. A family's few hundred records are far inside the budget.
