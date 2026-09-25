# Submission checklist — Aura 1.0

## 1. Decide before uploading

- [x] **iPhone only.** iPad support is off for 1.0, so no iPad screenshots
      are needed.
- [x] **Apple Intelligence logo removed.** The footer now says "Suggestions by
      Apple Intelligence" as plain text.
- [x] **Tripadvisor replaced with Apple Maps.** The Content API was shut down
      on August 31, 2026. Place search now uses MapKit: no API key, no quota.

## 2. Host the privacy policy

- [ ] Merge `AppStore/privacy-policy.md` to `main` (or publish it anywhere
      public) and use that URL in App Store Connect.

## 3. Screenshots (required: 6.9" iPhone)

Take these on your iPhone. The simulator can't generate card images, so a real
device looks right. Any recent iPhone works; the script scales to 1320 × 2868.

| File in `AppStore/screenshots/raw/` | What to capture |
|---|---|
| `home.png` | Main screen: temperature, summary, hourly row and suggestion cards |
| `places.png` | A suggestion's detail with its list of nearby places |
| `detail.png` | The Apple Maps place card for one of those places |

Three shots is enough for 1.0: place details are Apple Maps' own card now, so
there is no gallery or ratings screen to show.

Tips: pick a sunny daytime moment, charge the battery to 100%, and turn off
Airplane Mode so the status bar looks clean.

Then:
```bash
python3 -m venv .venv && .venv/bin/pip install pillow
.venv/bin/python AppStore/screenshots/compose.py
```
Upload `output/6.9/` to the 6.9" slot, or `output/6.5/` if App Store Connect
asks for 6.5" (1284 × 2778). Captions are in
`SHOTS` at the top of `compose.py`.

## 4. Archive and upload

- [ ] In Xcode, pick **Any iOS Device (arm64)**, then **Product → Archive**.
- [ ] Organizer → **Distribute App → App Store Connect → Upload**.
- [ ] Wait for the processing email, then install from **TestFlight** and try:
      first launch, allowing and denying location, widgets, Generate on iOS 27.

## 5. App Store Connect

- [ ] Create the app: **Apps → + → New App** with bundle ID `com.babono.AuraApp`,
      SKU e.g. `aura-ios-1`.
- [ ] Fill in every field from `AppStore/metadata.md`.
- [ ] App Privacy: answer as in `metadata.md`.
- [ ] Pricing and Availability: price and countries.
- [ ] Select the build, then **Add for Review → Submit**.
