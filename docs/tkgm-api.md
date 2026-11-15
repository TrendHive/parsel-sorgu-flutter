# The official registry API (TKGM)

What the app knows about the land registry's parcel query service and the rules
for using it. The runnable reference is the Postman collection in this repo:
[`docs/tkgm-parsel-sorgu.postman_collection.json`](tkgm-parsel-sorgu.postman_collection.json)
— import it into Postman (File > Import) to send each request. There is also a
private Postman workspace ("Parcel Atlas") for the family. Re-check against the
collection when lookups start failing in a way the app does not explain — the
service is not versioned for outside users and can change without notice.

## Endpoints

Base: `https://cbsapi.tkgm.gov.tr/megsiswebapi.v3.1/api/`

| Purpose | Request | Used by the app |
|---|---|---|
| Parcel under a point | `GET parsel/{lat}/{lng}/` | `TkgmParcelService.fetchAt` |
| Parcel by number | `GET parsel/{mahalleId}/{block}/{parcel}` | `TkgmParcelService.fetchByNumber` (Refresh) |
| Neighbourhood list | `GET idariYapi/mahalleListe/{ilceId}` | — (find a `mahalleId`) |

Plain GETs: no token, no custom header, no cookie.

## Response

A parcel query answers one GeoJSON `Feature`:

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

(A full sample is in `test/support/fixtures/tkgm_parcel_duzkoy_114_1.json`.)

- Coordinates are `[longitude, latitude]`, WGS84, **rounded to 5 decimals**
  (about 1 m). An area computed from them differs from `alan` by a few percent
  (162.23 m² against 165.22 m² for the sample), so the app shows `alan` for a
  registry parcel.
- `alan` is Turkish-formatted: `.` groups thousands, `,` is the decimal mark
  (`"98.199,20"` is 98 199.20 m²).
- `durum` `"1"` is a parcel in force; `"0"` a historical one.
- Every property is kept verbatim in the stored record's `attributes`.

## Who may call it

The service refuses browser requests that carry a website origin other than a
first-party one, and answers requests that carry **no** website origin — what a
native app, `curl`, or Postman sends. A browser always stamps the page's origin
on the request and cannot remove it, so:

**lookups work from the desktop and mobile apps and from Postman, not from the
web app.** The web app shows everything already stored and does all drawing and
ownership work. On the web the app does not send a lookup at all: it shows
a notice pointing to the desktop or mobile app (`MapNoticeEnum.useApp`).
Should a browser request be made anyway, its 403 is reported as `RegistryRefusesWebCause`
("query from the desktop or mobile app"), in a native app as
`RegistryQuotaCause`. The app does not add any header to disguise its origin,
and no relay is used (see `docs/roadmap.md`). Verified 2026-11-15: on one
connection within the same minute, a no-origin request got 200 and a foreign
browser-origin request got 403.

## Status codes

| Status | Meaning | App exception |
|---|---|---|
| 200 | the parcel | — |
| 404 | no parcel at that point | `NotFoundException(NoParcelCause)` |
| 403 | daily limit reached, or (in a browser) a third-party origin refused — same text for both ("Günlük sorgu limitini aştınız") | `QuotaExceededException` with `RegistryQuotaCause` in an app, `RegistryRefusesWebCause` on the web |
| 401 / 412 | login required | treated as a bad response |

## Rules for using it

The limit is per connection (IP address) per day and is low. Everything in the
app is arranged so it is spent only on purpose:

1. Never call it for a point inside a stored parcel — the store answers.
2. Never call it on map move, at startup, on a timer or in a loop. A tap on
   ground the store does not cover queries at once (the owner's choice: one
   tap, not two); Refresh is explicit.
3. Refresh asks by number, never by point.
4. A list of numbers on paper is stored with `tool/import_parcels.dart`:
   it skips parcels already stored, keeps every answer in a cache folder,
   spaces its calls and stops at the first refusal.
5. Do not test against the live service casually — every call spends the
   connection's allowance. Use the fixture in tests, and the Postman
   collection for a deliberate manual check.
