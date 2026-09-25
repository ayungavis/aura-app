# App Store Connect — Aura 1.0

Paste each block into the matching field. Character limits are in brackets;
every block here is already within its limit.

---

## App Information

**Name** [30]
```
Aura: Weather & Things to Do
```

**Subtitle** [30]
```
Plans that match the sky
```

**Primary category:** Weather
**Secondary category:** Travel

**Content rights:** No third-party content beyond Apple's own services (Apple
Weather and Apple Maps), which are used through Apple's frameworks.

**Age rating:** answer **None/No** to every question. Result: **4+**.

---

## Version 1.0

**Promotional text** [170] (can be edited later without a new review)
```
Check the sky, then get a plan. Aura suggests activities and food that suit today's weather, and finds places to go nearby.
```

**Description** [4000]
```
Aura turns the forecast into a plan.

Open the app and Aura reads the sky where you are: the temperature, the conditions and the next hours ahead. It sums up the day in a few calm lines, then suggests what to do and what to eat for this weather.

WEATHER, AT A GLANCE
• Current conditions and an hour-by-hour forecast
• Scenery that changes with the weather: sun, clouds and rain
• A short, written summary of how the day feels
• Home Screen widgets in two sizes

PLANS THAT FIT THE FORECAST
• Activity ideas that make sense for right now: a beach walk when it's clear, a museum when it rains
• Food suggestions to match: something cold on a hot afternoon, something warm on a rainy night
• Tap any idea to see matching places nearby, then open the Apple Maps card for hours and directions

POWERED BY APPLE INTELLIGENCE
On supported devices, suggestions are written on your device by Apple Intelligence, and you can create an illustration for any idea with Image Playground. On other devices, Aura still gives you weather-based suggestions.

PRIVATE BY DESIGN
• No account, no sign-up
• No ads and no tracking
• Your location is only used to get your weather and nearby places

Weather data by Apple Weather. Places by Apple Maps.
```

**Keywords** [100] (commas, no spaces)
```
forecast,activities,plans,food,restaurants,places,nearby,travel,trip,outdoor,widget,sunny,rain,today
```

**Support URL**
```
https://github.com/ayungavis/aura-app/issues
```

**Marketing URL** (optional)
```
https://github.com/ayungavis/aura-app
```

**Privacy Policy URL**: host `AppStore/privacy-policy.md` publicly first. Once it
is merged to `main`, this URL works:
```
https://github.com/ayungavis/aura-app/blob/main/AppStore/privacy-policy.md
```

**Copyright**
```
2026 <your name or company>
```

**What's New in This Version**: not shown for a first release.

---

## App Privacy (the "nutrition label")

**Do you or your third-party partners collect data from this app?** Yes.

| Data type | Used for | Linked to identity | Used for tracking |
|---|---|---|---|
| Location → **Precise Location** | App Functionality | No | No |

Why: the device's coordinates are sent to Apple (WeatherKit and Apple Maps) to
get the forecast and nearby places, and to Open-Meteo only when WeatherKit is
unavailable.
Nothing else leaves the device: Apple Intelligence text and Image Playground
images are created on the device, and the weather cache stays in the app.

---

## App Review Information

**Sign-in required:** No

**Notes**
```
Aura needs no account. Allow location access when asked; weather, suggestions and nearby places all depend on it. If location is denied, the app shows a screen with a button to open Settings.

Weather comes from Apple WeatherKit, with the Apple Weather mark in the footer of the main screen. The mark links to Apple's data-sources page.

Activity and food suggestions are written with Apple Intelligence (Foundation Models) on supported devices. On devices without Apple Intelligence, the app uses built-in, rule-based suggestions.

Images: on iOS 26 the card illustrations are made automatically with Image Playground. On iOS 27, tap "Generate" on a card to open the system Image Playground sheet. On devices without Image Playground, cards show a symbol instead.

Tapping a card lists nearby places from Apple Maps (MapKit search). Tapping a place opens the Apple Maps place card.
```

**Contact information:** your name, phone and email (App Review only; not shown publicly).

---

## Build settings already in the project

- Display name: **Aura** (the label on the Home Screen)
- `ITSAppUsesNonExemptEncryption = NO`: the app only uses HTTPS, so App Store
  Connect won't ask the export-compliance question for each build.
- Version **1.0**, build **1**. Increase the build number for every upload.
