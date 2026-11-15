---
name: registry-quota
description: Rules for any code or testing that touches the official land registry (TKGM) API in Parcel Atlas — the daily per-connection limit, store-first lookups, refresh by number, and never testing against the live API casually. Use whenever TkgmParcelService, ParcelRegistryInterface, QueryParcelAtUseCase or RefreshParcelUseCase is touched, or someone wants to "just try" a lookup.
---

# The registry is rationed

The registry allows a few lookups per connection per day; a 403 means the
allowance is spent until tomorrow. Full reference: `docs/tkgm-api.md`.

- A point inside a stored parcel is answered from `MapSnapshotReadModel` —
  never the registry. `test/application/parcel/query_parcel_at_usecase_test.dart`
  guards it.
- The registry is called only when a member taps ground the store does not
  cover, or presses Refresh. Never on map move, startup, a timer or a loop.
- In a browser the registry refuses third-party websites (403): lookups
  work only from the desktop and mobile apps. Never spoof its origin or add
  a relay without the owner's explicit decision.
- Refresh fetches by `neighbourhoodId/block/parcel`, never by point.
- No custom headers on the GET (no CORS preflight → one request per lookup).
- Test with `test/support/fixtures/tkgm_parcel_duzkoy_114_1.json` and fakes.
  A `curl` from your machine spends that machine's allowance.
- If the API changes, re-verify with the Postman collection
  (`docs/tkgm-parsel-sorgu.postman_collection.json`) and update
  `docs/tkgm-api.md`.
