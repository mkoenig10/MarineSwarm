# Marine Swarm — iOS wrapper

A bare WKWebView shell for playtesting the game natively on an iPhone.
The game itself stays `../marine-swarm.html` — this project bundles that
file **by reference** at build time (no copy, no drift; every build packs
the current version). No dependencies, no package manager, two source
files.

Decisions baked in (agreed 2026-07-13):

- **Personal playtesting only** — free Apple ID signing, no App Store /
  TestFlight concerns. Free-ID builds expire after **7 days**; just hit
  Run in Xcode again to re-install.
- **Landscape-locked** (both directions). Map layouts are computed from
  screen aspect at battle start, and Versus splits left/right — rotation
  mid-game is untested by design.
- **Edge-to-edge**: status bar hidden, home indicator auto-hides, system
  edge gestures deferred (first swipe shows the indicator, second acts).
  No safe-area insets — add `env(safe-area-inset-*)` CSS in the game only
  if playtesting shows the notch covering something that matters.
- **Saves are disposable**: the game's localStorage runs under a `file://`
  origin, which persists in practice but is the least-guaranteed corner of
  WKWebView storage. Real saves live on the desktop. If persistence proves
  flaky, the upgrade path is a custom `WKURLSchemeHandler` origin.

## One-time setup

1. Install **Xcode** from the Mac App Store (~12 GB; the Command Line
   Tools alone are not enough). Launch it once to finish component
   installation, then point the toolchain at it:
   `sudo xcode-select -s /Applications/Xcode.app`
2. Open `ios/MarineSwarm.xcodeproj`.
3. Select the **MarineSwarm** target → *Signing & Capabilities* → check
   *Automatically manage signing* and pick your **Team** (add your Apple
   ID under Xcode → Settings → Accounts if it's not there). If the bundle
   ID `com.matt.marineswarm` collides for your ID, change one letter.
4. Plug in the iPhone, unlock it, tap **Trust This Computer**. On iOS 16+
   also enable *Settings → Privacy & Security → Developer Mode* (the
   phone reboots).
5. Pick the phone in Xcode's device dropdown and hit **Run** (⌘R).
6. First launch is blocked until you trust the cert on the phone:
   *Settings → General → VPN & Device Management → your Apple ID → Trust*.

After setup, redeploying a game change is: hit Run again (~20–30 s).

## First-playtest checklist

- [ ] Menu music/gunfire plays after the first tap (WebAudio unlock).
- [ ] Touch-drag steers the swarm smoothly; no scroll bounce, no pinch
      zoom, no text-selection callouts.
- [ ] Notch side: does it cover any topbar text or battlefield that
      matters? (If yes → safe-area CSS in the game file.)
- [ ] Bottom tray buttons reachable without triggering the home swipe
      (edge gestures are deferred; confirm it feels right).
- [ ] Hold-to-inspect tooltip works on upgrade buttons (420 ms hold).
- [ ] **Saves survive relaunch**: create a profile, win something, kill
      the app from the app switcher, relaunch — profile + progress intact.
- [ ] Perf: toggle the debug overlay (Pause menu) during a big Endless
      wave; watch FPS at high unit counts.
- [ ] Versus on one phone: two-finger left/right halves both steer.
