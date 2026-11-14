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

## Status codes

| Status | Meaning | App exception |
|---|---|---|
| 200 | the parcel | — |
| 404 | no parcel at that point | `NotFoundException(NoParcelCause)` |
| 403 | daily query limit for this connection reached ("Günlük sorgu limitini aştınız") | `QuotaExceededException(RegistryQuotaCause)` |
| 401 / 412 | the site asks for e-Devlet login | treated as a bad response |

## Rules for using it

The limit is per connection (IP address) per day and is low. Everything in the
app is arranged so it is spent only on purpose:

1. Never call it for a point inside a stored parcel — the store answers.
2. Never call it automatically, on map move, or in a loop; only on a member's
   explicit "query the registry" or "Refresh".
3. Refresh asks by number, never by point.
4. Do not test against it casually — every `curl` from a developer's machine
   spends that machine's allowance. Use the fixture.
