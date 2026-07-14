# iOS device-test shell

A minimal WKWebView wrapper so the game can be pushed to an iPhone/iPad from
Xcode for play-testing. The game itself is untouched: the target bundles the
repo's `marine-swarm.html` **by reference** — edit the game, hit Run, the
build picks it up. No build step, no dependencies, no third-party code.

## First-time setup (once)

1. Open `ios/MarineSwarm.xcodeproj` in Xcode.
2. Select the **MarineSwarm** target → *Signing & Capabilities* → pick your
   personal **Team** (your Apple ID; add it under Xcode → Settings → Accounts
   if it isn't there). Xcode fixes the bundle id suffix automatically if it
   collides.
3. Plug in the iPhone/iPad, unlock it, tap **Trust**.
4. On the device: Settings → General → VPN & Device Management → trust your
   developer certificate (first install only).

## Every session after that

Select the device in the run-destination dropdown and press **Run** (⌘R).

Notes:
- Landscape-only, fullscreen, status bar and home indicator hidden — matches
  the game's rotate-gate policy (phones are landscape-only by design).
- `localStorage` (profiles, campaign progress, Gauntlet runs) persists inside
  the app container across builds, but is deleted if you delete the app.
- A free personal team's install expires after 7 days — just Run again.
- Safari on the Mac can inspect the running WebView (Develop menu → device)
  once Web Inspector is enabled on the device (Settings → Safari → Advanced).
