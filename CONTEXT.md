# Marine Swarm — Zone Command

Single-file HTML5 swarm-RTS: Liquid-Swarm-style army movement plus beacon capture and per-team upgrades. This glossary pins the language for the game's concepts.

## Language

### HUD

**HUD**:
The DOM overlay shown during play — topbar, upgrade trays, hint box, tooltip, toasts. Distinct from in-world canvas indicators (zone rings, command-point marker), which are not part of the HUD.
_Avoid_: overlay, UI (too broad — UI includes menu screens)

**Topbar**:
The strip across the top of the HUD showing minerals, supply, zones held, the objective, and the pause/sound buttons.

**Tray**:
The row of upgrade buttons at the bottom of the HUD in solo modes (campaign/skirmish).
_Avoid_: toolbar, dock

**Side tray**:
The narrow vertical upgrade column on each screen half in Versus mode (icon-only, 4 upgrades per player).

**Upgrade button**:
One purchasable upgrade in a tray: icon, label (solo only), level pips, and cost. Buying happens on tap; holding opens the hold-tooltip instead.
_Avoid_: ub (code class name, not spoken language)

**Hold-tooltip**:
The inspection panel opened by holding an upgrade button ~420ms: shows the upgrade's description and NOW → NEXT values without buying.

**Affordability pulse**:
A one-shot glow on an upgrade button at the moment it first becomes affordable. Fires once per affordability flip, never loops.

**Supply-capped**:
The state where a team's unit count has reached its supply value, halting reinforcements. Surfaced in the topbar by color (amber near cap, red at cap).

### Game

**Reinforce**:
The upgrade that shortens the spawn interval — faster arrivals, same army ceiling.
_Avoid_: spawn rate (in player-facing text)

**Supply**:
The upgrade (and stat) that raises the maximum army size.
_Avoid_: cap, pop

**Command point**:
The per-team location units flow toward, driven by pointer or keys.
_Avoid_: cursor, target point

**Pad**:
A circular capturable beacon on the battlefield. Mines minerals and reinforces marines for its owner; captured by net unit advantage standing on it. Big pads mine double and reinforce faster.
_Avoid_: zone, beacon (zone survives only in code identifiers and the game's subtitle)

**Cell**:
One square of grid territory on a Grid battlefield. Behaves as a scaled-down pad — mines and reinforces for its owner, painted in the owner's color. Uniform: no big cells.
_Avoid_: zone, sector, tile

**Grid**:
The Skirmish map type where the battlefield is fully tiled with cells instead of dotted with pads. Territory painting replaces discrete beacon capture; a match still ends by elimination.
_Avoid_: zone control (the inspiration, not the feature name)
