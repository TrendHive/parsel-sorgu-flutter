# Regressions

Bugs that were fixed, recorded by class, with the guard that keeps each one
fixed. A fix is not done until it has a row here and a test or rule that
fails without it (CLAUDE.md, rule 16).

## Startup

**The app hung on the splash screen when location permission was denied.**
Startup awaited the device position, and a refused permission threw before
the app moved on — on the web, where browsers often refuse, the map never
opened. *Guard:* location is now only the map's "my location" button
(`LocateDeviceUseCase`), never awaited at startup; it has a timeout and its
failure is a message.

## Build

**The web build broke after a Flutter upgrade.** `google_fonts` 6.2 used a
`const` map keyed by `FontWeight`, which newer Dart no longer accepts as a
constant; and a `switch` over Dio's error types became non-exhaustive when
Dio added `transformTimeout`. *Guard:* the gate builds the web app in CI on
every push; the interceptor's `switch` is exhaustive with no `default`
(`no_default_cases`), so a new error type is a compile error, not a silent
gap.

## Registry

**Each lookup cost two requests.** Sending `Content-Type: application/json`
on a GET made browsers send a CORS preflight first. *Guard:* `DioClient` sets
no custom headers; documented in `docs/tkgm-api.md`.
