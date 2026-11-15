# The official registry API (TKGM)

What the app knows about the land registry's parcel query service, how it was
verified, and the rules for using it. Re-check this page when lookups start
failing in a way the app does not explain — the service is not versioned for
outside users and can change without notice.

## Source

`parselsorgu.tkgm.gov.tr` — the registry's public parcel query site — is a
Backbone/Leaflet app. Its `app/util/constants.min.js` sets the API host;
`app/modules/requestManager/view/layout.min.js` builds the query URLs. Verified
on 2026-11-14 by reading those files and by recording the site's own network
traffic while querying parcels.

## Endpoints

Base: `https://cbsapi.tkgm.gov.tr/megsiswebapi.v3.1/api/`

| Purpose | Request | Used by the app |
|---|---|---|
| Parcel under a point | `GET parsel/{lat}/{lng}/` | `TkgmParcelService.fetchAt` |
| Parcel by number | `GET parsel/{neighbourhoodId}/{block}/{parcel}` | `TkgmParcelService.fetchByNumber` (Refresh) |
| Parcel by land id | `GET zemin/{id}` | not used |

Plain GETs: no token, no custom header. The site has an optional e-Devlet
login (`auth/getParselSorguTokenInfo`), but parcel queries do not send its
token. The service answers `Access-Control-Allow-Origin: *`, so a browser can
call it directly; with no custom header the request is "simple" and needs no
preflight.

## Response

One GeoJSON `Feature`:

```json
{
  "type": "Feature",
  "geometry": { "type": "Polygon", "coordinates": [[[41.00085, 40.55876], ...]] },
  "properties": {
    "ilId": 47, "ilAd": "Erzurum",
    "ilceId": 408, "ilceAd": "İspir",
    "mahalleId": 130241, "mahalleAd": "Düzköy",
    "adaNo": "114", "parselNo": "1", "pafta": "G46d-16D-4A",
    "alan": "165,22", "nitelik": "İki Katlı Ahşap Ev Ahır Ve Arsası",
    "mevkii": "Köyiçi", "zeminKmdurum": "Ana Taşınmaz",
    "durum": "1", "ozet": "Düzköy-114/1",
    "gittigiParselListe": "", "gittigiParselSebep": ""
  }
}
```

(Values are the registry's data, quoted verbatim; a full sample is in
`test/support/fixtures/tkgm_parcel_duzkoy_114_1.json`.)

- Coordinates are `[longitude, latitude]`, WGS84, **rounded to 5 decimals**
  (about 1 m). An area computed from them differs from `alan` by a few percent
  (162.23 m² against 165.22 m² for the sample), so the app shows `alan` for a
  registry parcel.
- `alan` is Turkish-formatted: `.` groups thousands, `,` is the decimal mark
  (`"98.199,20"` is 98 199.20 m²).
- `durum` `"1"` is a parcel in force; `"0"` a historical one (the site shows a
  warning for it).
- Every property is kept verbatim in the stored record's `attributes`.

## Who may call it

Verified 2026-11-15: the service refuses requests that carry the `Origin` of
a website other than its own. A request from this app's website gets 403 with
the "daily limit" text on its very first call, while the same request with no
`Origin` — what a desktop or mobile app sends — gets 200.

So **lookups work from the desktop and mobile apps and not from the web
app.** The web app shows everything already stored and does all drawing and
ownership work; a 403 in the browser is reported as `RegistryRefusesWebCause`
("query from the desktop or mobile app"), in an app as `RegistryQuotaCause`.
The app does not disguise its requests as the registry's own site, and no
relay is used: getting around the refusal is the owner's decision to make,
not the code's (see `docs/roadmap.md`).

## Status codes

| Status | Meaning | App exception |
|---|---|---|
| 200 | the parcel | — |
| 404 | no parcel at that point | `NotFoundException(NoParcelCause)` |
| 403 | daily query limit reached, or (in a browser) a third-party website refused — same text for both ("Günlük sorgu limitini aştınız") | `QuotaExceededException` with `RegistryQuotaCause` in an app, `RegistryRefusesWebCause` on the web |
| 401 / 412 | the site asks for e-Devlet login | treated as a bad response |

## Rules for using it

The limit is per connection (IP address) per day and is low. Everything in the
app is arranged so it is spent only on purpose:

1. Never call it for a point inside a stored parcel — the store answers.
2. Never call it on map move, at startup, on a timer or in a loop. A tap on
   ground the store does not cover queries at once (the owner's choice: one
   tap, not two); Refresh is explicit.
3. Refresh asks by number, never by point.
4. Do not test against it casually — every `curl` from a developer's machine
   spends that machine's allowance. Use the fixture.
