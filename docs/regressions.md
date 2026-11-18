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

## Map

**Zooming in showed "map data not yet available" tiles.** The app asked the
aerial imagery for level 19, which the source does not have for the area; it
answers such requests with a placeholder image, not an error. *Guard:*
`MapRules.satelliteNativeZoom` is the deepest real level (checked against the
source's tile map), and deeper zoom enlarges that level.

**A parcel needed two presses to look up.** A tap on unknown ground only
opened a panel with a query button. *Guard:* `map_cubit_test.dart` — "one tap
on ground nobody looked up queries the registry".

## Registry (web)

**Every lookup from the website said the daily limit was reached.** The
registry refuses third-party website origins with the same 403 and text as
its real limit. *Guard:* documented in `docs/tkgm-api.md`; a browser 403 is
`RegistryRefusesWebCause` with an accurate message, and the web build no
longer implies a quota problem.

## Native apps

**Sign-in on macOS failed with a generic error although the password was
right.** Firebase Auth stores the session in the keychain, which a macOS app
may use only with the `keychain-access-groups` entitlement and a
provisioning profile; an ad-hoc signed build has neither. *Guard:* both
entitlement files carry the entitlement and the project signs automatically
with the owner's team; documented in `docs/status.md` (build with a signed
profile, never ad-hoc).

**The Android build failed before compiling.** Flutter 3.50 needs Gradle
9.3.1 or newer and the project still had the versions it was created with.
*Guard:* the Android versions match a fresh Flutter project's (Gradle 9.5,
AGP 9.3.1, Kotlin 2.4.20); re-check them on every Flutter upgrade.

## Tools

**`add_member` crashed in a terminal that cannot hide typing.** Such a
terminal reports itself as one but refuses to switch echo off. *Guard:* the
tools catch the refusal, warn that the input is visible, and go on.

## Dividing

**An equal split to one owner's children would have taken the other owners'
shares.** *Guard:* the dialog offers "to the children" only for a drawing
with a single owner; several owners can still split by number, which keeps
every owner on every piece.

## Ownership

**"Assign owner" on a registry parcel made a second drawing beside the real
boundary already drawn on it.** Only drawings linked to the parcel by id were
found, so a boundary drawn from scratch was missed. *Guard:*
`drawingsCorrecting` also finds unlinked drawings that cover the parcel's
ground, and assigning links them (tests in `map_snapshot_read_model_test`
and `map_cubit_test`).

**The map jumped after an owner was assigned.** The saved drawing was
selected and framed like a new one. *Guard:* an assignment selects without
moving the camera (`map_cubit_test`).

**Owned land looked the same as unowned land.** Colour came only from the
generation menu. *Guard:* colouring by owner is the default, also on the
registry layer.

**"Assign owner" on a registry parcel was refused as an overlap that was not
there.** The neighbour's real boundary, drawn by hand, crossed the registry's
shared line by a few tens of centimetres; along a 30 m side that thin strip
added up to more than the 2 m² allowed. *Guard:* the overlap check ignores
ground within `MapRules.overlapSliverMeters` (0.5 m) of both drawings' sides,
so only ground reaching deeper counts (`overlap_sliver_test`). And
assigning an owner is never checked for overlap at all — it stores the
registry's own outline, or changes no shape — so recording who owns a
parcel cannot be refused over geometry (`map_cubit_test`).

## Map camera

**A tap on a parcel already on screen zoomed the map onto it.** Every
selection that came back from the store or the registry framed the parcel.
*Guard:* `MapRules.cameraMove` — a parcel wholly in view leaves the camera
alone, one partly in view slides in at the same zoom, only one off screen is
framed (`camera_move_test`).

