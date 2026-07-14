# The world fills the play band, not the window

The battlefield's view transform (`fitView`) and its aspect ratio at build time (`mapDims`)
are computed from the **play band** — the viewport strip between the topbar and the upgrade
tray — not from the full window. HUD chrome heights are measured live from the DOM (with a
throwaway upgrade button standing in when a def is built while the tray is still empty),
stored in `S.band`, and re-measured after `buildTrays` and on resize. Consequences a future
reader should expect: the map is letterboxed vertically below the topbar; on phones the map
gets *wider* in world units than the raw window aspect would suggest; the menu's demo battle
(no HUD) uses a zero band; Versus insets only the top, since it hides `#tray` and its side
trays deliberately overlay the map's flanks.

This exists because HUD-over-map hid real gameplay: on a phone-height screen the tray covered
the bottom row of Grid cells (invisible *and* untappable — the tray eats pointer events), and
bottom-edge pads crowded it in every mode.

Rejected alternatives: auto-hiding/collapsing the tray (changes the upgrade-buying
interaction on every device to fix a layout problem); shrinking grids on short screens (cell
count is gameplay — campaign grid missions and the Gauntlet finale are tuned against it);
transparent/tap-through tray (still occludes; misfires between "tap cell" and "buy upgrade").

Guardrail: `mapDims` runs at def-build time, so anything that changes tray height (new tray
content, CSS padding) silently changes map aspect on small screens. That's accepted — map
width already varies per device aspect by design (grid column count derives from it) — but
keep the band measurement honest rather than hardcoding heights. Canonical language in
CONTEXT.md (Play band / Rotate gate / Side panel).
